//
//  ExchangeRateUseCaseInterface.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/16/25.
//

import Foundation

import RxSwift

protocol ExchangeRateUseCaseInterface {
    func fetchExchangeRateData() async throws -> ExchangeRate
    func rxFetchExchangeRateData() -> Observable<ExchageRateResponseDTO>
}
