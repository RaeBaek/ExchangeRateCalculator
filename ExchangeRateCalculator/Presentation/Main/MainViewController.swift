//
//  MainViewController.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/14/25.
//

import UIKit

import Then

import RxSwift
import RxCocoa

final class MainViewController: UIViewController {

    private let mainView = MainView()
    private let mainViewModel: MainViewModel
    
    private let disposeBag = DisposeBag()
    
    init(mainViewModel: MainViewModel = MainViewModel()) {
        self.mainViewModel = mainViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        bind()
    }
    
    private func bind() {
        let input = MainViewModel.Input(viewDidLoad: Observable.just(()), refreshTrigger: Observable.just(()))
        let output = mainViewModel.transform(input: input)
        
        output.rates
            .asDriver(onErrorDriveWith: .empty())
            .map { $0.rates.sorted { $0.key < $1.key }}
            .drive(mainView.tableView.rx.items(cellIdentifier: MainTableViewCell.identifier, cellType: MainTableViewCell.self)) { _, item, cell in
                cell.setCell(item.key, item.value)
            }
            .disposed(by: disposeBag)
        
        output.errorMessage
            .asDriver(onErrorJustReturn: "에러")
            .drive { message in
                
            }
            .disposed(by: disposeBag)
    }
    
    private func setUpTableView() {
        mainView.tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }

}

extension MainViewController: UITableViewDelegate {
    
}
