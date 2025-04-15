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
    }
    
    struct Output {
        let rates: PublishRelay<ExchageRateResponseDTO>
        let errorMessage: PublishRelay<String>
    }
    
    private let exchageRateService: ExchangeRateAPIService
    private let disposeBag = DisposeBag()
    
    init(exchageRateService: ExchangeRateAPIService = ExchangeRateAPIService()) {
        self.exchageRateService = exchageRateService
    }
    
    func transform(input: Input) -> Output {
        let rates = PublishRelay<ExchageRateResponseDTO>()
        let errorMessage = PublishRelay<String>()
        
        let trigger = Observable.merge(input.viewDidLoad,
                                       input.refreshTrigger)
        
        trigger
            .withUnretained(self)
            .flatMapLatest { owner, _ in
                owner.exchageRateService.rxFetchExchageRates()
                    .catch { error in
                        errorMessage.accept(error.localizedDescription)
                        return .empty()
                    }
            }
            .bind(to: rates)
            .disposed(by: disposeBag)
        
        return Output(rates: rates,
                      errorMessage: errorMessage)
    }
}
