//
//  ExchangeRateResult.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/23/25.
//

import Foundation

enum ExchangeRateResult {
    case success(ExchageRateResponseDTO)
    case failure(NetworkError)
}
