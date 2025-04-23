//
//  CurrencyRepositoryImpl.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/23/25.
//

import Foundation

final class CurrencyRepositoryImpl: CoreDataRepository {
    private let coreDataService = CoreDataService.shared
    
    func updateCurrency(with exchangeRate: ExchangeRate) {
        coreDataService.updateCurrency(with: exchangeRate)
    }
    
    func loadBookmarkCodes() -> Set<String> {
        coreDataService.loadBookmarkedCodes()
    }
    
    func toggleBookmark(for code: String) {
        coreDataService.toggleBookmark(for: code)
    }
    
    func saveCurrentView(view: String, code: String?) {
        coreDataService.saveCurrentView(view: view, code: code)
    }
}
