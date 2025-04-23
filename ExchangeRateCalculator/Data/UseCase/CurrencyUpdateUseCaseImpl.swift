//
//  CurrencyUpdateUseCaseImpl.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/23/25.
//

import Foundation

final class CurrencyUpdateUseCaseImpl: CurrencyUpdateUseCase {
    private let repository: CoreDataRepository
    
    init(repository: CoreDataRepository) {
        self.repository = repository
    }

    func updateCurrencyData(with exchangeRate: ExchangeRate) {
        repository.updateCurrency(with: exchangeRate)
    }
}
