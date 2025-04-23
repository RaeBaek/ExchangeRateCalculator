//
//  CurrentViewSaveUseCaseImpl.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/23/25.
//

import Foundation

final class CurrentViewSaveUseCaseImpl: CurrentViewSaveUseCase {
    private let repository: CurrencyRepository
    
    init(repository: CurrencyRepository) {
        self.repository = repository
    }
    
    func saveView(view: String, code: String?) {
        repository.saveCurrentView(view: view, code: code)
    }
}
