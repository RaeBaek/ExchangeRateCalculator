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

final class ExchangeRateCalculatorViewController: BaseViewController {
    
    private let exchangeRateView = ExchangeRateView()
    
    private let viewModel: ExchangeRateCalculatorViewModel
    private let disposeBag = DisposeBag()
    
    init(currencyModel: CurrencyCellModel, DIContainer: DIContainerInterface) {
        self.viewModel = DIContainer.makeExchangeRateCalculatorViewModel(currencyModel: currencyModel)
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
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.saveVurrentView(view: "ExchangeRateCalculator")
    }
    
    override func bind() {
        super.bind()
        
        let input = ExchangeRateCalculatorViewModel.Input(currencyValue: exchangeRateView.amountTextField.rx.text.orEmpty,
                                                          convertButtonTapped: exchangeRateView.convertButton.rx.tap)
        let output = viewModel.transform(input: input)
        
        output.currencyModel
            .bind(with: self) { owner, model in
                owner.exchangeRateView.setView(model)
            }
            .disposed(by: disposeBag)
        
        output.exchangeValue
            .bind(to: exchangeRateView.resultLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.convertError
            .bind(with: self) { owner, _ in
                owner.showAlert("숫자만 입력해주세요.")
            }
            .disposed(by: disposeBag)
    }
    
}
