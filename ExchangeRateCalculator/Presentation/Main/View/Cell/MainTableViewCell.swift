//
//  MainTableViewCell.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/15/25.
//

import UIKit

import SnapKit

import Then

final class MainTableViewCell: UITableViewCell {
    
    let labelStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 4
    }
    
    let countryCodeLabel = UILabel().then {
        $0.textColor = .label
        $0.font = .systemFont(ofSize: 16, weight: .medium)
    }
    
    let countryNameLabel = UILabel().then {
        $0.textColor = .secondaryLabel
        $0.font = .systemFont(ofSize: 14, weight: .regular)
    }
    
    let exchangeRateLabel = UILabel().then {
        $0.textColor = .secondaryLabel
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.textAlignment = .right
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView() {
        [labelStackView, exchangeRateLabel].forEach {
            contentView.addSubview($0)
        }
        
        [countryCodeLabel, countryNameLabel].forEach {
            labelStackView.addArrangedSubview($0)
        }
    }
    
    private func setConstraints() {
        labelStackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
        
        exchangeRateLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.leading.lessThanOrEqualTo(labelStackView.snp.trailing).offset(16)
            $0.width.equalTo(120)
        }
    }
    
    func setCell(_ item: CurrencyCellModel) {
        countryCodeLabel.text = item.code
        countryNameLabel.text = item.name
        exchangeRateLabel.text = item.rate
    }
    
}
