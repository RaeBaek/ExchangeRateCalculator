//
//  CurrentViewSaveUseCase.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/23/25.
//

import Foundation

protocol CurrentViewSaveUseCase {
    func saveView(view: String, code: String?)
}
