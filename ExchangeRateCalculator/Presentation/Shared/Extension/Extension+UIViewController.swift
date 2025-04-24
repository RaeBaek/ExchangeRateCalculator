//
//  Extension+UIViewController.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/17/25.
//

import UIKit

extension UIViewController {
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        self.present(alert, animated: true)
    }
}
