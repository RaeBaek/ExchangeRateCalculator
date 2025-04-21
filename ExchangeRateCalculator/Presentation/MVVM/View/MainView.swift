//
//  MainView.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/15/25.
//

import UIKit

import SnapKit

import Then

final class MainView: BaseView {
    
    let countrySearchBar = UISearchBar().then {
        $0.placeholder = "통화 검색"
        $0.backgroundImage = UIImage()
    }
    
    let tableView = UITableView().then {
        $0.register(MainTableViewCell.self, forCellReuseIdentifier: MainTableViewCell.identifier)
        $0.rowHeight = 60
    }
    
    let emptyView = UILabel().then {
        $0.text = "검색 결과 없음"
        $0.textAlignment = .center
        $0.textColor = .systemGray
        $0.font = .systemFont(ofSize: 17, weight: .regular)
        $0.isHidden = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureView() {
        super.configureView()
        
        [countrySearchBar, tableView].forEach {
            self.addSubview($0)
        }
        
        self.tableView.addSubview(emptyView)
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        countrySearchBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(countrySearchBar.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide)
        }
        
        emptyView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
