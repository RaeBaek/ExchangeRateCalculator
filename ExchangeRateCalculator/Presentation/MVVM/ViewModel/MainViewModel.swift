//
//  MainViewModel.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/15/25.
//

import UIKit
import CoreData

import RxSwift
import RxCocoa

final class MainViewModel {
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let searchText: ControlProperty<String>
        let bookmarkButtonTapped: PublishRelay<IndexPath>
    }
    
    struct Output {
        let filteredRates: PublishRelay<[CurrencyCellModel]>
        let errorMessage: PublishRelay<String>
    }
    
    private var bookMarkCodes = Set<String>()
    
    private let exchangeRateUseCase: ExchangeRateUseCase
    private let bookmarkUseCase: BookmarkUseCase
    private let currentViewSaveUseCase: CurrentViewSaveUseCase
    
    private let disposeBag = DisposeBag()
    
    init(exchangeRateUseCase: ExchangeRateUseCase,
         bookmarkUseCase: BookmarkUseCase,
         currentViewSaveUseCase: CurrentViewSaveUseCase) {
        self.exchangeRateUseCase = exchangeRateUseCase
        self.bookmarkUseCase = bookmarkUseCase
        self.currentViewSaveUseCase = currentViewSaveUseCase
        
        // 초기화 시 호출
        bookMarkCodes = bookmarkUseCase.loadBookmarkeCodes()
        CoreDataService.shared.readAllCurrencyData()
    }
    
    func transform(input: Input) -> Output {
        let rates = PublishRelay<ExchangeRate>()
        let errorMessage = PublishRelay<String>()
        let filteredRates = PublishRelay<[CurrencyCellModel]>()
        
        input.viewDidLoad
            .withUnretained(self)
            .flatMapLatest { owner, _ in
                owner.exchangeRateUseCase.rxFetchExchangeRateData()
                    .catch { error in
                        errorMessage.accept(error.localizedDescription)
                        return .empty()
                    }
            }
            .map { $0.toDomain() }
            .withUnretained(self)
            .do { owner, exchangeRate in
                CoreDataService.shared.updateCurrency(with: exchangeRate)
            }
            .map { $0.1 }
            .bind(to: rates)
            .disposed(by: disposeBag)
        
        // 검색 필터링을 위한 Observable.combineLatest
        Observable.combineLatest(rates.map { $0 }, input.searchText)
            .withUnretained(self)
            .map { owner, value -> [CurrencyCellModel] in
                let (exchangeRate, query) = value
                return owner.makeCurrencyCellModels(from: exchangeRate.rates, query: query)
            }
            .bind(to: filteredRates)
            .disposed(by: disposeBag)
        
        // cell 내의 즐겨찾기 버튼의 이벤트 처리, withLatestFrom(filteredRates)
        input.bookmarkButtonTapped
            .withLatestFrom(filteredRates) { indexPath, models in
                return (indexPath, models)
            }
            .subscribe(with: self) { owner, pair in
                let (indexPath, models) = pair
                filteredRates.accept(owner.handleBookmarkToggle(at: indexPath, in: models))
            }
            .disposed(by: disposeBag)
        
        return Output(filteredRates: filteredRates,
                      errorMessage: errorMessage)
    }
    
    private func makeCurrencyCellModels(from rates: [String: Double], query: String) -> [CurrencyCellModel] {
        let all = rates.map { (key, value) in
            var currencyStatus: CurrencyStatus?
            
            let request = Currency.fetchRequest()
            request.predicate = NSPredicate(format: "code == %@", key)
            
            do {
                if let result = try CoreDataService.shared.fetchData(request).first {
                    let yesterdatRate = Double(result.yesterday ?? "") ?? 0
                    let currentRate = value
                    currencyStatus = abs(currentRate - yesterdatRate) > 0.01 ? (currentRate > yesterdatRate ? .up : .down) : nil
                }
            } catch {
                print("Currency: \(key) 값 없음...")
            }
            return CurrencyCellModel(code: key,
                                     name: CountryName.name[key] ?? "",
                                     rate: String(format: "%.4f", value),
                                     isBookmarked: bookMarkCodes.contains(key),
                                     status: currencyStatus)
        }
        
        let lowercased = query.lowercased()
        let filtered = all.filter { $0.code.lowercased().hasPrefix(lowercased) || $0.name.hasPrefix(query) }
        
        return sortedModels(filtered)
    }
    
    private func handleBookmarkToggle(at indexPath: IndexPath, in models: [CurrencyCellModel]) -> [CurrencyCellModel] {
        var updateModels = models
        let tappedModel = models[indexPath.row]
        
        let updatedBookmark = !tappedModel.isBookmarked
        let updateModel = CurrencyCellModel(code: tappedModel.code,
                                            name: tappedModel.name,
                                            rate: tappedModel.rate,
                                            isBookmarked: updatedBookmark,
                                            status: tappedModel.status)
        
        if updatedBookmark {
            bookmarkUseCase.toggleBookmark(for: updateModel.code)
            bookMarkCodes.insert(updateModel.code)
        } else {
            bookmarkUseCase.toggleBookmark(for: updateModel.code)
            bookMarkCodes.remove(updateModel.code)
        }
        
        updateModels[indexPath.row] = updateModel
        return sortedModels(updateModels)
    }
    
    private func sortedModels(_ items: [CurrencyCellModel]) -> [CurrencyCellModel] {
        items.sorted {
            if $0.isBookmarked != $1.isBookmarked {
                return $0.isBookmarked && !$1.isBookmarked
            }
            return $0.code < $1.code
        }
    }
    
    func saveCurrentView(view: String) {
        currentViewSaveUseCase.saveView(view: view, code: nil)
    }
}
