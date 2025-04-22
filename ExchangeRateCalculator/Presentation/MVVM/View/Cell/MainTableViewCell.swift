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
    
    let upDownImage = UIImageView()
    
    let bookmarkButton = UIButton().then {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular)
        let starImage = UIImage(systemName: "star", withConfiguration: imageConfig)
        let starFillImage = UIImage(systemName: "star.fill", withConfiguration: imageConfig)
        
        var config = UIButton.Configuration.plain()
//        config.image = starImage
        config.baseBackgroundColor = .clear
        config.baseForegroundColor = .systemYellow
        $0.configuration = config
        
        $0.setImage(starImage, for: .normal)
        $0.setImage(starFillImage, for: .selected)
        $0.setImage(starFillImage, for: .highlighted)
    }
    
    var bookMarkButtonTapped: ControlEvent<Void> {
        return bookmarkButton.rx.tap
    }
    
    var disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        configureView()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        upDownImage.image = nil
        
        upDownImage.snp.removeConstraints()
        exchangeRateLabel.snp.removeConstraints()
        
        disposeBag = DisposeBag()
    }
    
    private func configureView() {
        [labelStackView, upDownImage, bookmarkButton, exchangeRateLabel].forEach {
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
            $0.size.equalTo(30)
        }
    }
    
    func setCell(_ item: CurrencyCellModel) {
        countryCodeLabel.text = item.code
        countryNameLabel.text = item.name
        exchangeRateLabel.text = item.rate
        bookmarkButton.isSelected = item.isBookmarked
        
        switch item.status {
        case .up:
            upDownImage.image = UIImage(systemName: "arrowtriangle.up.square.fill")
            upDownImage.tintColor = .systemRed
            setUpDownConstraints()
        case .down:
            upDownImage.image = UIImage(systemName: "arrowtriangle.down.square.fill")
            upDownImage.tintColor = .systemBlue
            setUpDownConstraints()
        case .none:
            upDownImage.image = nil
            setRateConstraints()
        }
    }
    
    private func setRateConstraints() {
        exchangeRateLabel.snp.makeConstraints {
            $0.trailing.equalTo(bookmarkButton.snp.leading).offset(-16)
            $0.centerY.equalToSuperview()
            $0.leading.lessThanOrEqualTo(labelStackView.snp.trailing).offset(16)
            $0.width.equalTo(120)
        }
    }
    
    private func setUpDownConstraints() {
        upDownImage.snp.makeConstraints {
            $0.trailing.equalTo(bookmarkButton.snp.leading).offset(-16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(30)
        }
        
        exchangeRateLabel.snp.makeConstraints {
            $0.trailing.equalTo(upDownImage.snp.leading).offset(-16)
            $0.centerY.equalToSuperview()
            $0.leading.lessThanOrEqualTo(labelStackView.snp.trailing).offset(16)
            $0.width.equalTo(120)
        }
    }
}
