//
//  ExchangeRateUseCase.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/15/25.
//

import Foundation

import RxSwift

final class ExchangeRateUseCase: ExchangeRateUseCaseInterface {
    
    private let repository: ExchangeRateRepositoryInterface
    
    init(repository: ExchangeRateRepositoryInterface) {
        self.repository = repository
    }
    
    func fetchExchangeRateData() async throws -> ExchangeRate {
        return try await repository.fetchExchageRateData()
    }
    
    func rxFetchExchangeRateData() -> RxSwift.Observable<ExchageRateResponseDTO> {
        return repository.rxFetchExchageRateData()
    }
}
