//
//  BookmarkUseCase.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/23/25.
//

import Foundation

protocol BookmarkUseCase {
    func toggleBookmark(for code: String)
    func loadBookmarkeCodes() -> Set<String>
}
