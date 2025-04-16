//
//  ExchageRateRepositoryInterface.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/16/25.
//

import Foundation

import RxSwift

protocol ExchangeRateRepositoryInterface {
    func fetchExchageRateData() async throws -> ExchangeRate
    func rxFetchExchageRateData() -> Observable<ExchageRateResponseDTO>
}
