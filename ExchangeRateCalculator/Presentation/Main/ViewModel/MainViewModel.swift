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
    
    private var container: NSPersistentContainer!
    
    private var bookMarkCodes = Set<String>()
    
    private let useCase: ExchangeRateUseCaseInterface
    private let disposeBag = DisposeBag()
    
    init(useCase: ExchangeRateUseCaseInterface) {
        self.useCase = useCase
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.container = appDelegate.persistentContainer
        
        // 초기화 시 호출
        loadBookmarks()
        readAllData()
    }
    
    // CoreData에 저장되어 있는 즐겨찾기 내용을 bookMarkCodes에 대입
    private func loadBookmarks() {
        let request = Currency.fetchRequest()
        if let results = try? container.viewContext.fetch(request) {
            bookMarkCodes = Set(results.compactMap { $0.value(forKey: Currency.Key.code) as? String })
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
            .bind(to: rates)
            .disposed(by: disposeBag)
        
        // 검색 필터링을 위한 Observable.combineLatest
        Observable.combineLatest(rates.map { $0 }, input.searchText)
            .withUnretained(self)
            .map { owner, value -> [CurrencyCellModel] in
                let (exchangeRate, query) = value
                let all = exchangeRate.rates.map { (key, value) in
                    CurrencyCellModel(code: key,
                                      name: CountryName.name[key] ?? "",
                                      rate: String(format: "%.4f", value),
                                      isBookmarked: owner.bookMarkCodes.contains(key))
                }
                
                let lowercased = query.lowercased()
                let filtered = all.filter { $0.code.lowercased().hasPrefix(lowercased) || $0.name.hasPrefix(query) }
                
                return owner.sortedModels(filtered)
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
                var updateModels = models
                let tappedModel = models[indexPath.row]
                
                let updatedBookmark = !tappedModel.isBookmarked
                let updateModel = CurrencyCellModel(code: tappedModel.code,
                                                    name: tappedModel.name,
                                                    rate: tappedModel.rate,
                                                    isBookmarked: updatedBookmark)
                
                if updatedBookmark {
                    owner.createData(updateModel)
                    owner.bookMarkCodes.insert(updateModel.code)
                } else {
                    owner.deleteData(updateModel)
                    owner.bookMarkCodes.remove(updateModel.code)
                }
                
                updateModels[indexPath.row] = updateModel
                
                let sorted = owner.sortedModels(updateModels)
                filteredRates.accept(sorted)
            }
            .disposed(by: disposeBag)
        
        return Output(filteredRates: filteredRates,
                      errorMessage: errorMessage)
    }
    
    private func sortedModels(_ items: [CurrencyCellModel]) -> [CurrencyCellModel] {
        items.sorted {
            if $0.isBookmarked != $1.isBookmarked {
                return $0.isBookmarked && !$1.isBookmarked
            }
            return $0.code < $1.code
        }
    }
    
    func createData(_ item: CurrencyCellModel) {
        guard let entity = NSEntityDescription.entity(forEntityName: Currency.className, in: self.container.viewContext) else { return }
        let newCurrency = NSManagedObject(entity: entity, insertInto: self.container.viewContext)
        newCurrency.setValue(item.code, forKey: Currency.Key.code)
        newCurrency.setValue(item.name, forKey: Currency.Key.name)
        newCurrency.setValue(item.rate, forKey: Currency.Key.rate)
        
        do {
            try self.container.viewContext.save()
            print("즐겨찾기 저장 성공!")
        } catch {
            print("즐겨찾기 저장 실패...")
        }
    }
    
    func deleteData(_ item: CurrencyCellModel) {
        let request = Currency.fetchRequest()
        request.predicate = NSPredicate(format: "code == %@", item.code)
        
        do {
            let results = try container.viewContext.fetch(request)
            
            for object in results {
                container.viewContext.delete(object)
            }
            
            try container.viewContext.save()
            print("즐겨찾기 삭제 성공!")
        } catch {
            print("즐겨찾기 삭제 실패...")
        }
    }
    
    func readAllData() {
        do {
            let currencies = try container.viewContext.fetch(Currency.fetchRequest())
            
            for currency in currencies as [NSManagedObject] {
                if let code = currency.value(forKey: Currency.Key.code) as? String,
                   let name = currency.value(forKey: Currency.Key.name) as? String,
                   let rate = currency.value(forKey: Currency.Key.rate) as? String {
                    print("code: \(code), name: \(name), rate: \(rate)")
                }
            }
        } catch {
            print("데이터 읽기 실패")
        }
    }
}
