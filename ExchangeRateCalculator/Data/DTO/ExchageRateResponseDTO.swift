//
//  ExchageRateResponseDTO.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/15/25.
//

import Foundation

struct ExchageRateResponseDTO: Codable {
    let timeLastUpdateUtc: String
    let baseCode: String
    let rates: [String: Double]
    
    func toDomain() -> ExchangeRate {
        return ExchangeRate(timeLastUpdateUtc: timeLastUpdateUtc, baseCode: baseCode, rates: rates)
    }
    
    enum CodingKeys: String, CodingKey {
        case timeLastUpdateUtc = "time_last_update_utc"
        case rates
        case baseCode = "base_code"
    }
}
