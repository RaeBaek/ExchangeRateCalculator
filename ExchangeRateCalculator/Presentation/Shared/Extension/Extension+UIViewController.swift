//
//  Extension+UIViewController.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/17/25.
//

import UIKit

extension UIViewController {
    func showAlert() {
        let alert = UIAlertController(title: "오류", message: "숫자만 입력해주세요.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        self.present(alert, animated: true)
    }
}
