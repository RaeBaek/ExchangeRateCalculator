//
//  ExchangeRateRepositoryImpl.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/15/25.
//

import Foundation

final class ExchangeRateRepositoryImpl: FetchExchangeRateUseCase {
    private let service = ExchangeRateAPIService()
    
    func execute() async throws -> ExchangeRate {
        let dto = try await service.fetchExchageRates()
        
        return dto.toDomain()
    }
}
