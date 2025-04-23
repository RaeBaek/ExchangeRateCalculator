//
//  NetworkError.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/23/25.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidStatusCode(Int)
    case decodingError(Error)
    case unknown(Error)
}
