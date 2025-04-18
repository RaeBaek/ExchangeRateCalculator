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
        let refreshTrigger: Observable<Void>
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
        
        loadBookmarks()
    }
    
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
        
        var bookmarkedCodes = Set<String>()
        
        let trigger = Observable.merge(input.viewDidLoad,
                                       input.refreshTrigger)
        
        trigger
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
        
        Observable.combineLatest(rates.map { $0 }, input.searchText)
            .map { exchangeRate, query -> [CurrencyCellModel] in
                let all = exchangeRate.rates.map { (key, value) in
                    CurrencyCellModel(code: key, name: CountryName.name[key] ?? "", rate: String(format: "%.4f", value), isBookmarked: bookmarkedCodes.contains(key))
                }
                
                let lowercased = query.lowercased()
                let filtered = all.filter { $0.code.lowercased().hasPrefix(lowercased) || $0.name.hasPrefix(query) }
                
                return filtered.sorted {
                    if $0.isBookmarked != $1.isBookmarked {
                        return $0.isBookmarked && $1.isBookmarked
                    }
                    return $0.code < $1.code
                }
            }
            .bind(to: filteredRates)
            .disposed(by: disposeBag)
        
        input.bookmarkButtonTapped
            .withLatestFrom(filteredRates) { indexPath, models in
                models[indexPath.row]
            }
            .subscribe(with: self) { owner, model in
                if bookmarkedCodes.contains(model.code) {
                    owner.deleteData(model)
                    bookmarkedCodes.remove(model.code)
                } else {
                    owner.createData(model)
                    bookmarkedCodes.insert(model.code)
                }
                
                input.searchText
                    .take(1)
                    .withLatestFrom(rates) { text, rates in
                        return (text, rates)
                    }
                    .subscribe { value in
                        let all = value.1.rates.map { (key, value) in
                            CurrencyCellModel(code: key, name: CountryName.name[key] ?? "", rate: String(format: "%.4f", value), isBookmarked: bookmarkedCodes.contains(key))
                        }
                        
                        let lowercased = value.0.lowercased()
                        let filtered = all.filter { $0.code.lowercased().hasPrefix(lowercased) || $0.name.hasPrefix(value.0) }
                        
                        let sorted = filtered.sorted {
                            if $0.isBookmarked != $1.isBookmarked {
                                return $0.isBookmarked && $1.isBookmarked
                            }
                            return $0.code < $1.code
                        }
                        filteredRates.accept(sorted)
                    }
                    .disposed(by: owner.disposeBag)
            }
            .disposed(by: disposeBag)
        
        return Output(filteredRates: filteredRates,
                      errorMessage: errorMessage)
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
}
