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
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(ExchageRateResponseDTO.self, from: data)
    }
    
    func rxFetchExchageRates() -> Observable<ExchageRateResponseDTO> {
        return Observable.create { observer in
            Task {
                do {
                    let dto = try await self.fetchExchageRates()
                    observer.onNext(dto)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
}
