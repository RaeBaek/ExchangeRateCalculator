//
//  MainDIContainer.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/16/25.
//

import Foundation

final class MainDIContainer: MainDIContainerInterface {
    func makeMainViewModel() -> MainViewModel {
        let repository = ExchangeRateRepository()
        let useCase = ExchangeRateUseCase(repository: repository)
        let viewModel = MainViewModel(useCase: useCase)
        return viewModel
    }
}
