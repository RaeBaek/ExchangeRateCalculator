//
//  FetchExchangeRateUseCase.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/15/25.
//

import Foundation

protocol FetchExchangeRateUseCase {
    func execute() async throws -> ExchangeRate
}
