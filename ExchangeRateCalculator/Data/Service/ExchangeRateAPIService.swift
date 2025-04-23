//
//  ExchangeRateAPIService.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/15/25.
//

import Foundation

import RxSwift

final class ExchangeRateAPIService {
    private let urlString = "https://open.er-api.com/v6/latest/\(CurrencyName.current)"
    
    func fetchExchageRates() async throws -> ExchageRateResponseDTO {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidStatusCode(-1)
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidStatusCode(httpResponse.statusCode)
        }
        
        do {
            return try JSONDecoder().decode(ExchageRateResponseDTO.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    func rxFetchExchageRates() -> Single<ExchangeRateResult> {
        return Single.create { single in
            Task {
                do {
                    let dto = try await self.fetchExchageRates()
                    single(.success(.success(dto)))
                } catch let error as NetworkError {
                    single(.success(.failure(error)))
                } catch {
                    single(.success(.failure(.unknown(error))))
                }
            }
            return Disposables.create()
        }
    }
}
