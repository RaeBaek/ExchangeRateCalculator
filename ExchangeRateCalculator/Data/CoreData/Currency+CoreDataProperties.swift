//
//  Currency+CoreDataProperties.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/21/25.
//
//

import Foundation
import CoreData


extension Currency {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Currency> {
        return NSFetchRequest<Currency>(entityName: "Currency")
    }

    @NSManaged public var code: String?
    @NSManaged public var name: String?
    @NSManaged public var rate: String?
    @NSManaged public var yesterday: String?
    @NSManaged public var lastUpdatedDate: String?
    @NSManaged public var isBookmark: Bool

}

extension Currency : Identifiable {

}
