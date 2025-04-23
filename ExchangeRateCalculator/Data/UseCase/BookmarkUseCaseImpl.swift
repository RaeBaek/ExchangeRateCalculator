//
//  BookmarkUseCaseImpl.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/23/25.
//

import Foundation

final class BookmarkUseCaseImpl: BookmarkUseCase {
    private let repository: CoreDataRepository
    
    init(repository: CoreDataRepository) {
        self.repository = repository
    }
    
    func toggleBookmark(for code: String) {
        repository.toggleBookmark(for: code)
    }
    
    func loadBookmarkeCodes() -> Set<String> {
        repository.loadBookmarkCodes()
    }
}
