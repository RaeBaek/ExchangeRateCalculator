//
//  CurrencyUpdateUseCase.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/23/25.
//

import Foundation

protocol CurrencyUpdateUseCase {
    func updateCurrencyData(with exchangeRate: ExchangeRate)
}
