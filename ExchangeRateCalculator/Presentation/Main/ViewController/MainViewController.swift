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
    
    init(DIContainer: MainDIContainerInterface) {
        self.mainViewModel = DIContainer.makeMainViewModel()
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
        setNavigationBar()
        bind()
    }
    
    private func bind() {
        let input = MainViewModel.Input(viewDidLoad: Observable.just(()),
                                        refreshTrigger: Observable.just(()),
                                        searchText: mainView.countrySearchBar.rx.text.orEmpty)
        let output = mainViewModel.transform(input: input)
        
        output.filteredRates
            .bind(to: mainView.tableView.rx.items(cellIdentifier: MainTableViewCell.identifier, cellType: MainTableViewCell.self)) { _, item, cell in
                cell.setCell(item)
            }
            .disposed(by: disposeBag)
        
        output.filteredRates
            .map { $0.isEmpty == false }
            .observe(on: MainScheduler.instance)
            .bind(to: mainView.emptyView.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.errorMessage
            .asDriver(onErrorJustReturn: "에러")
            .drive { message in
                
            }
            .disposed(by: disposeBag)
        
        mainView.tableView.rx.itemSelected
            .bind(with: self) { owner, indexPath in
                
            }
            .disposed(by: disposeBag)
        
        mainView.tableView.rx.modelSelected(CurrencyCellModel.self)
            .bind(with: self) { owner, model in
                owner.navigationController?.pushViewController(ExchageRateCalculatorViewController(currencyModel: model), animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func setNavigationBar() {
        self.navigationItem.title = "환율 정보"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
    }

}
