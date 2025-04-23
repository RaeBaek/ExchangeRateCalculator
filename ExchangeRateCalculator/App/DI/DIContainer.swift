//
//  DIContainer.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/16/25.
//

import Foundation

final class DIContainer: DIContainerInterface {
    
    func makeMainViewModel() -> MainViewModel {
        let exchangeRateRepository = ExchangeRateRepositoryImpl()
        let exchangeRateUseCase = ExchangeRateUseCaseImpl(repository: exchangeRateRepository)
        
        let currencyRepository = CurrencyRepositoryImpl()
        let bookmarkUseCase = BookmarkUseCaseImpl(repository: currencyRepository)
        let currentViewSaveUseCase = CurrentViewSaveUseCaseImpl(repository: currencyRepository)
        
        let viewModel = MainViewModel(exchangeRateUseCase: exchangeRateUseCase,
                                      bookmarkUseCase: bookmarkUseCase,
                                      currentViewSaveUseCase: currentViewSaveUseCase)
        return viewModel
    }
    
    func makeExchangeRateCalculatorViewModel(currencyModel: CurrencyCellModel) -> ExchangeRateCalculatorViewModel {
        let currencyRepository = CurrencyRepositoryImpl()
        let currentViewSaveUseCase = CurrentViewSaveUseCaseImpl(repository: currencyRepository)
        
        let viewModel = ExchangeRateCalculatorViewModel(currencyModel: currencyModel,
                                                        currentViewSaveUseCase: currentViewSaveUseCase)
        return viewModel
    }
}
