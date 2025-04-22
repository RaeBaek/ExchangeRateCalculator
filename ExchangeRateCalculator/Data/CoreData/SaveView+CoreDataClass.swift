//
//  LastView+CoreDataClass.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/21/25.
//
//

import Foundation
import CoreData

@objc(SaveView)
public class SaveView: NSManagedObject {
    public static var className = "SaveView"

    public enum Key {
        static let code = "code"
        static let isLastView = "isLastView"
    }
}
