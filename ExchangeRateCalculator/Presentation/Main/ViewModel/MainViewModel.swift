//
//  MainViewModel.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/15/25.
//

import Foundation

import RxSwift
import RxCocoa

final class MainViewModel {
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let refreshTrigger: Observable<Void>
        let searchText: ControlProperty<String>
    }
    
    struct Output {
        let filteredRates: PublishRelay<[CurrencyCellModel]>
        let errorMessage: PublishRelay<String>
    }
    
    private let useCase: ExchangeRateUseCaseInterface
    private let disposeBag = DisposeBag()
    
    init(useCase: ExchangeRateUseCaseInterface) {
        self.useCase = useCase
    }
    
    func transform(input: Input) -> Output {
        let rates = PublishRelay<ExchangeRate>()
        let errorMessage = PublishRelay<String>()
        let filterdRates = PublishRelay<[CurrencyCellModel]>()
        
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
        
        Observable.combineLatest(rates.compactMap { $0 }, input.searchText)
            .map { exchangeRate, query -> [CurrencyCellModel] in
                let all = exchangeRate.rates.map { (key, value) in
                    CurrencyCellModel(code: key, name: CountryName.name[key] ?? "", rate: String(format: "%.4f", value))
                }
                
                let lowercased = query.lowercased()
                let filtered = all.filter { $0.code.lowercased().hasPrefix(lowercased) || $0.name.hasPrefix(query) }
                return filtered.sorted { $0.code < $1.code }
            }
            .bind(to: filterdRates)
            .disposed(by: disposeBag)
        
        return Output(filteredRates: filterdRates,
                      errorMessage: errorMessage)
    }
}
