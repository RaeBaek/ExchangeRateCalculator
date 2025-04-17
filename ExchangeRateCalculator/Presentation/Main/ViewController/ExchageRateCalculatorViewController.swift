//
//  ExchageRateCalculatorViewController.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/16/25.
//

import UIKit

import Then

import RxSwift
import RxCocoa

final class ExchageRateCalculatorViewController: BaseViewController {
    
    private let exchangeRateView = ExchangeRateView()
    
    private let currencyModel: CurrencyCellModel
    private let viewModel: ExchangeRateCalculatorViewModel
    private let disposeBag = DisposeBag()
    
    init(currencyModel: CurrencyCellModel, viewModel: ExchangeRateCalculatorViewModel = ExchangeRateCalculatorViewModel()) {
        self.currencyModel = currencyModel
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view = exchangeRateView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBar(NavigationBarTitle.exchangeRate.rawValue)
        exchangeRateView.setView(currencyModel)
        
        bind()
    }
    
    override func bind() {
        super.bind()
        
        let input = ExchangeRateCalculatorViewModel.Input(currencyModel: BehaviorSubject(value: currencyModel),
                                                          currencyValue: exchangeRateView.amountTextField.rx.text.orEmpty,
                                                          convertButtonTapped: exchangeRateView.convertButton.rx.tap)
        let output = viewModel.transform(input: input)
        
        output.exchageValue
            .bind(to: exchangeRateView.resultLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.convertError
            .bind(with: self) { owner, _ in
                owner.showAlert()
            }
            .disposed(by: disposeBag)
    }
    
}
