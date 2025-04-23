//
//  ExchangeRateRepositoryImpl.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/15/25.
//

import Foundation

import RxSwift

final class ExchangeRateRepositoryImpl: ExchangeRateRepository {
    
    private let service = ExchangeRateAPIService()
    
    func fetchExchageRateData() async throws -> ExchangeRate {
        let dto = try await service.fetchExchageRates()
        
        return dto.toDomain()
    }
    
    func rxFetchExchageRateData() -> Observable<ExchageRateResponseDTO> {
        return service.rxFetchExchageRates()
    }
}
