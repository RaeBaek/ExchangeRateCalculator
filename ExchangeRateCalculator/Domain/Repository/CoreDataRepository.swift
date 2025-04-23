//
//  CoreDataRepository.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/23/25.
//

import Foundation

protocol CoreDataRepository {
    func updateCurrency(with exchangeRate: ExchangeRate)
    func loadBookmarkCodes() -> Set<String>
    func toggleBookmark(for code: String)
    func saveCurrentView(view: String, code: String?)
}
