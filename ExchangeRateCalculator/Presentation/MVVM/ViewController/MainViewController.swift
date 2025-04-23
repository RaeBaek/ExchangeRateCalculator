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

final class MainViewController: BaseViewController {

    private let mainView = MainView()
    private let mainViewModel: MainViewModel
    
    private let bookMarkButtonTapped = PublishRelay<IndexPath>()
    
    private let disposeBag = DisposeBag()
    
    init(DIContainer: DIContainerInterface) {
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
        
        setNavigationBar(NavigationBarTitle.mainView.rawValue)
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mainViewModel.saveCurrentView(view: "Main")
    }
    
    override func bind() {
        super.bind()
        
        let input = MainViewModel.Input(viewDidLoad: Observable.just(()),
                                        searchText: mainView.countrySearchBar.rx.text.orEmpty,
                                        bookmarkButtonTapped: bookMarkButtonTapped)
        let output = mainViewModel.transform(input: input)
        
        output.filteredRates
            .bind(to: mainView.tableView.rx.items(cellIdentifier: MainTableViewCell.identifier, cellType: MainTableViewCell.self)) { row, item, cell in
                cell.setCell(item)
                
                cell.bookMarkButtonTapped
                    .map { IndexPath(row: row, section: 0) }
                    .bind(with: self) { owner, indexPath in
                        owner.bookMarkButtonTapped.accept(indexPath)
                    }
                    .disposed(by: cell.disposeBag)
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
                owner.navigationController?.pushViewController(ExchangeRateCalculatorViewController(currencyModel: model, DIContainer: DIContainer()), animated: true)
            }
            .disposed(by: disposeBag)
    }
}
