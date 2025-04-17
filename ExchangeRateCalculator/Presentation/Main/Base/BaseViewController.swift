//
//  BaseViewController.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/17/25.
//

import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func bind() {
        
    }
    
    func setNavigationBar(_ title: NavigationBarTitle.RawValue) {
        self.navigationItem.title = title
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
    }
}
