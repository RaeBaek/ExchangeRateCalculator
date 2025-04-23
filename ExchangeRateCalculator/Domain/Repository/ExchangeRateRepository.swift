//
//  ExchangeRateRepository.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/16/25.
//

import Foundation

import RxSwift

protocol ExchangeRateRepository {
    func fetchExchageRateData() async throws -> ExchangeRate
    func rxFetchExchageRateData() -> Single<ExchangeRateResult>
}
