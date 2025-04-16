//
//  Extension+UITableViewCell.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/15/25.
//

import UIKit

extension UITableViewCell: ReusableProtocol {
    static var identifier: String {
        String(describing: self)
    }
}
