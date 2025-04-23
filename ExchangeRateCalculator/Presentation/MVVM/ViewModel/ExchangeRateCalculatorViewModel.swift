//
//  ExchangeRateCalculatorViewModel.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/16/25.
//

import UIKit

import CoreData

import RxSwift
import RxCocoa

final class ExchangeRateCalculatorViewModel {
    
    struct Input {
        let currencyValue: ControlProperty<String>
        let convertButtonTapped: ControlEvent<Void>
    }
    
    struct Output {
        let currencyModel: BehaviorRelay<CurrencyCellModel>
        let convertError: PublishRelay<Void>
        let exchangeValue: PublishRelay<String>
    }
    
    private let currencyModel: CurrencyCellModel
    
    private let currentViewSaveUseCase: CurrentViewSaveUseCase
    
    private let disposeBag = DisposeBag()
    
    init(currencyModel: CurrencyCellModel,
         currentViewSaveUseCase: CurrentViewSaveUseCase) {
        self.currencyModel = currencyModel
        self.currentViewSaveUseCase = currentViewSaveUseCase
    }
    
    func transform(input: Input) -> Output {
        let currencyModel = BehaviorRelay<CurrencyCellModel>(value: currencyModel)
        let convertError = PublishRelay<Void>()
        let exchangeValue = PublishRelay<String>()
        
        input.convertButtonTapped
            .withLatestFrom(Observable.combineLatest(currencyModel, input.currencyValue))
            .map { model, value -> String in
                guard let rate = Double(model.rate), let value = Double(value) else {
                    convertError.accept(())
                    return "계산 결과가 이곳에 표시됩니다." }
                
                return "\(String(format: "%.2f", value)) \(CurrencyName.current) -> \(String(format: "%.2f", rate * value)) \(model.code)"
            }
            .bind(to: exchangeValue)
            .disposed(by: disposeBag)
        
        return Output(currencyModel: currencyModel,
                      convertError: convertError,
                      exchangeValue: exchangeValue)
    }
    
    func saveVurrentView(view: String) {
        currentViewSaveUseCase.saveView(view: view, code: currencyModel.code)
    }
}
