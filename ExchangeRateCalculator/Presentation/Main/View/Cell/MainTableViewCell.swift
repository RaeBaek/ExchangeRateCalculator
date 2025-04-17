//
//  MainTableViewCell.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/15/25.
//

import UIKit

import SnapKit

import Then

import RxSwift
import RxCocoa

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
    
    let bookmarkButton = UIButton().then {
        $0.setImage(UIImage(systemName: "star"), for: .normal)
        $0.setImage(UIImage(systemName: "star.fill"), for: .selected)
        $0.setImage(UIImage(systemName: "star.fill"), for: .highlighted)
        $0.tintColor = .systemYellow
    }
    
    var bookMarkButtonTapped: ControlEvent<Void> {
        return bookmarkButton.rx.tap
    }
    
    let disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        configureView()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView() {
        [labelStackView, bookmarkButton, exchangeRateLabel].forEach {
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
        
        bookmarkButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(44)
        }
        
        exchangeRateLabel.snp.makeConstraints {
            $0.trailing.equalTo(bookmarkButton.snp.leading).offset(-16)
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
