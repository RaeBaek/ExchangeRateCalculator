//
//  ExchangeRateUseCaseImpl.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/15/25.
//

import Foundation

import RxSwift

final class ExchangeRateUseCaseImpl: ExchangeRateUseCase {
    
    private let repository: ExchangeRateRepository
    
    init(repository: ExchangeRateRepository) {
        self.repository = repository
    }
    
    func fetchExchangeRateData() async throws -> ExchangeRate {
        return try await repository.fetchExchageRateData()
    }
    
    func rxFetchExchangeRateData() -> Observable<ExchageRateResponseDTO> {
        return repository.rxFetchExchageRateData()
    }
}
