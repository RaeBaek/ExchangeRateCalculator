//
//  ExchangeRateView.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/16/25.
//

import UIKit

import SnapKit

import Then

final class ExchangeRateView: BaseView {
    
    let labelStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 4
        $0.alignment = .center
    }
    
    let currencyLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 24, weight: .bold)
        $0.textColor = .label
    }
    
    let countryLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.textColor = .gray
    }
    
    let amountTextField = UITextField().then {
        $0.borderStyle = .roundedRect
        $0.keyboardType = .decimalPad
        $0.textAlignment = .center
        $0.placeholder = "금액을 입력하세요"
    }
    
    let convertButton = UIButton().then {
        var config = UIButton.Configuration.filled()
        config.attributedTitle = AttributedString("환율 계산", attributes: .init( [.font: UIFont.systemFont(ofSize: 16, weight: .medium)]))
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .white
        $0.configuration = config
    }
    
    let resultLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 20, weight: .medium)
        $0.text = "계산 결과가 이곳에 표시됩니다."
        $0.textColor = .label
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setUI()
    }
    
    private func setUI() {
        convertButton.layer.cornerRadius = 8
        convertButton.clipsToBounds = true
    }
    
    func setView(_ model: CurrencyCellModel) {
        currencyLabel.text = model.code
        countryLabel.text = model.name
    }
    
    override func configureView() {
        super.configureView()
        
        [labelStackView, amountTextField, convertButton, resultLabel].forEach {
            self.addSubview($0)
        }
        
        [currencyLabel, countryLabel].forEach {
            labelStackView.addArrangedSubview($0)
        }
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        labelStackView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(32)
            $0.centerX.equalToSuperview()
        }
        
        amountTextField.snp.makeConstraints {
            $0.top.equalTo(labelStackView.snp.bottom).offset(32)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(44)
        }
        
        convertButton.snp.makeConstraints {
            $0.top.equalTo(amountTextField.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(44)
        }
        
        resultLabel.snp.makeConstraints {
            $0.top.equalTo(convertButton.snp.bottom).offset(32)
            $0.horizontalEdges.equalToSuperview().inset(24)
        }
    }
    
}
