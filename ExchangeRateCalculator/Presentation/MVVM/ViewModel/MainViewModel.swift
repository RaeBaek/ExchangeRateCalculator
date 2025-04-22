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
    
//    private var container: NSPersistentContainer!
    
    private var bookMarkCodes = Set<String>()
    
    private let useCase: ExchangeRateUseCaseInterface
    private let disposeBag = DisposeBag()
    
    init(useCase: ExchangeRateUseCaseInterface) {
        self.useCase = useCase
        
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        self.container = appDelegate.persistentContainer
        
        // 초기화 시 호출
        bookMarkCodes = CoreDataService.shared.loadBookmarkedCodes() // loadBookmarks()
        CoreDataService.shared.readAllCurrencyData() // readAllData()
    }
    
    // 즐겨찾기 상태인 통화를 bookMarkCodes에 추가
//    private func loadBookmarks() {
//        do {
//            let currencies = try container.viewContext.fetch(Currency.fetchRequest())
//            bookMarkCodes = Set(currencies.compactMap {
//                guard let isBookmarked = $0.value(forKey: Currency.Key.isBookmark) as? Bool, isBookmarked, let code = $0.value(forKey: Currency.Key.code) as? String else { return nil }
//                return code
//            })
//        } catch {
//            print("Load bookmarks error: \(error)")
//        }
//    }
    
    func savedCurrentView() {
        do {
//            let current = try container.viewContext.fetch(SaveView.fetchRequest())
            let current = try CoreDataService.shared.fetchData(SaveView.fetchRequest())
            
            if let currentValue = current.first {
                currentValue.setValue("Main", forKey: SaveView.Key.isLastView)
                currentValue.setValue(nil, forKey: SaveView.Key.code)
            } else {
                guard let entity = NSEntityDescription.entity(forEntityName: SaveView.className, in: CoreDataService.shared.container.viewContext) else { return }
                let newCurrency = NSManagedObject(entity: entity, insertInto: CoreDataService.shared.container.viewContext)
                newCurrency.setValue("Main", forKey: SaveView.Key.isLastView)
                newCurrency.setValue(nil, forKey: SaveView.Key.code)
            }
            CoreDataService.shared.saveContext()
            print("Save View 저장 완료! (Main)")
        } catch {
            print("Save View 저장 실패...")
        }
    }
    
    func transform(input: Input) -> Output {
        let rates = PublishRelay<ExchangeRate>()
        let errorMessage = PublishRelay<String>()
        let filteredRates = PublishRelay<[CurrencyCellModel]>()
        
        input.viewDidLoad
            .withUnretained(self)
            .flatMapLatest { owner, _ in
                owner.useCase.rxFetchExchangeRateData()
                    .catch { error in
                        errorMessage.accept(error.localizedDescription)
                        return .empty()
                    }
            }
            .map { $0.toDomain() }
            .withUnretained(self)
            .do { owner, exchangeRate in
//                owner.updateCurrencyDataIfNeeded(with: exchageRate)
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
    
//    private func updateCurrencyDataIfNeeded(with exchangeRate: ExchangeRate) {
//        let todayDateString = exchangeRate.timeLastUpdateUtc.toDateOnlyString()
//        let request = Currency.fetchRequest()
//        
//        do {
//            let savedCurrencies = try container.viewContext.fetch(request)
//            
//            for (code, rate) in exchangeRate.rates {
//                let name = CountryName.name[code]
//                
//                // 이미 저장된 경우
//                if let existing = savedCurrencies.first(where: { $0.value(forKey: Currency.Key.code) as? String == code }) {
//                    let oldRateString = existing.value(forKey: Currency.Key.rate) as? String ?? "0"
//                    
//                    // API가 오늘 날짜로 새로 업데이트 됐지만 아직 앱에 반영이 안됐다면
//                    if existing.lastUpdatedDate != todayDateString {
//                        existing.setValue(oldRateString, forKey: Currency.Key.yesterday)
//                        existing.setValue(String(format: "%.4f", rate), forKey: Currency.Key.rate)
//                        existing.setValue(todayDateString, forKey: Currency.Key.lastUpdatedDate)
//                    }
//                } else {
//                    // 새로 저장할 경우 (앱 최초 실행 등)
//                    guard let entity = NSEntityDescription.entity(forEntityName: Currency.className, in: container.viewContext) else { continue }
//                    let newCurrency = NSManagedObject(entity: entity, insertInto: container.viewContext)
//                    newCurrency.setValue(code, forKey: Currency.Key.code)
//                    newCurrency.setValue(name, forKey: Currency.Key.name)
//                    newCurrency.setValue("0", forKey: Currency.Key.yesterday)
//                    newCurrency.setValue(String(format: "%.4f", rate), forKey: Currency.Key.rate)
//                    newCurrency.setValue(todayDateString, forKey: Currency.Key.lastUpdatedDate)
//                    newCurrency.setValue(false, forKey: Currency.Key.isBookmark)
//                }
//            }
//            try container.viewContext.save()
//        } catch {
//            print("Update Currency Data Error...: \(error)")
//        }
//    }
    
    private func makeCurrencyCellModels(from rates: [String: Double], query: String) -> [CurrencyCellModel] {
        let all = rates.map { (key, value) in
            var currencyStatus: CurrencyStatus?
            
            let request = Currency.fetchRequest()
            request.predicate = NSPredicate(format: "code == %@", key)
            
            do {
//                if let result = try container.viewContext.fetch(request).first {
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
//            updateData(updateModel)
            CoreDataService.shared.toggleBookmark(for: updateModel.code)
            bookMarkCodes.insert(updateModel.code)
        } else {
//            updateData(updateModel)
            CoreDataService.shared.toggleBookmark(for: updateModel.code)
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
    
//    private func updateData(_ item: CurrencyCellModel) {
//        let request = Currency.fetchRequest()
//        request.predicate = NSPredicate(format: "code == %@", item.code)
//        
//        do {
//            if let result = try container.viewContext.fetch(request).first {
//                result.setValue(!result.isBookmark, forKey: Currency.Key.isBookmark)
//            }
//            try container.viewContext.save()
//            print("즐겨찾기 업데이트 성공!")
//        } catch {
//            print("즐겨찾기 업데이트 실패...")
//        }
//    }
//    
//    private func readAllData() {
//        do {
//            let currencies = try container.viewContext.fetch(Currency.fetchRequest())
//            
//            for currency in currencies as [NSManagedObject] {
//                if let code = currency.value(forKey: Currency.Key.code) as? String,
//                   let name = currency.value(forKey: Currency.Key.name) as? String,
//                   let rate = currency.value(forKey: Currency.Key.rate) as? String,
//                   let yesterday = currency.value(forKey: Currency.Key.yesterday) as? String,
//                   let lastUpdatedDate = currency.value(forKey: Currency.Key.lastUpdatedDate) as? String,
//                   let isBookmarked = currency.value(forKey: Currency.Key.isBookmark) as? Bool {
//                    print("code: \(code), name: \(name), rate: \(rate), yesterday: \(yesterday), lastUpdatedDate: \(lastUpdatedDate), isBookmarked: \(isBookmarked)")
//                }
//            }
//        } catch {
//            print("Currency 데이터 읽기 실패...")
//        }
//    }
}
