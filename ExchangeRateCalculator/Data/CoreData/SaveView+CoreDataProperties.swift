//
//  LastView+CoreDataProperties.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/21/25.
//
//

import Foundation
import CoreData


extension SaveView {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SaveView> {
        return NSFetchRequest<SaveView>(entityName: "SaveView")
    }

    @NSManaged public var isLastView: String?
    @NSManaged public var code: String?

}

extension SaveView : Identifiable {

}
