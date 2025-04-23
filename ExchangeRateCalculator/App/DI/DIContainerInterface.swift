//
//  DIContainerInterface.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/16/25.
//

import Foundation

protocol DIContainerInterface {
    func makeMainViewModel() -> MainViewModel
    func makeExchangeRateCalculatorViewModel(currencyModel: CurrencyCellModel) -> ExchangeRateCalculatorViewModel
}
