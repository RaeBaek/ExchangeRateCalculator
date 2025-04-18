//
//  Currency+CoreDataClass.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/18/25.
//
//

import Foundation
import CoreData

@objc(Currency)
public class Currency: NSManagedObject {
    public static var className = "Currency"
    
    public enum Key {
        static let code = "code"
        static let name = "name"
        static let rate = "rate"
    }
}
