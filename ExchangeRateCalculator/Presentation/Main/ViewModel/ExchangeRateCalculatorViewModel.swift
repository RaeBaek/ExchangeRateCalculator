//
//  ExchangeRateCalculatorViewModel.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/16/25.
//

import Foundation

import RxSwift
import RxCocoa

final class ExchangeRateCalculatorViewModel {
    
    struct Input {
        let currencyModel: BehaviorSubject<CurrencyCellModel>
        let currencyValue: ControlProperty<String>
        let convertButtonTapped: ControlEvent<Void>
    }
    
    struct Output {
        let convertError: PublishRelay<Void>
        let exchageValue: PublishRelay<String>
    }
    
    private let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let convertError = PublishRelay<Void>()
        let exchangeValue = PublishRelay<String>()
        
        input.convertButtonTapped
            .withLatestFrom(Observable.combineLatest(input.currencyModel, input.currencyValue))
            .map { model, value -> String in
                guard let rate = Double(model.rate), let value = Double(value) else {
                    convertError.accept(())
                    return "계산 결과가 이곳에 표시됩니다." }
                
                return "\(String(format: "%.2f", value)) \(CurrencyName.current) -> \(String(format: "%.2f", rate * value)) \(model.code)"
            }
            .bind(to: exchangeValue)
            .disposed(by: disposeBag)
        
        return Output(convertError: convertError,
                      exchageValue: exchangeValue)
    }
}
