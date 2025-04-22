//
//  CoreDataService.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/22/25.
//

import CoreData
import UIKit

final class CoreDataService {
    static let shared = CoreDataService(container: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
    
    let container: NSPersistentContainer
    
    private init(container: NSPersistentContainer) {
        self.container = container
    }
    
    func fetchData<T: NSManagedObject>(_ request: NSFetchRequest<T>) throws -> [T] {
        try container.viewContext.fetch(request)
    }
    
    func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("CoreData 저장 실패: \(error)")
            }
        }
    }
    
    func updateCurrency(with exchangeRate: ExchangeRate) {
        let todayDateString = exchangeRate.timeLastUpdateUtc.toDateOnlyString()
        let request = Currency.fetchRequest()
        
        do {
            let savedCurrencies = try fetchData(request)
            
            for (code, rate) in exchangeRate.rates {
                let name = CountryName.name[code]
                
                // 이미 저장되어 있는 경우
                if let existing = savedCurrencies.first(where: { $0.code == code }) {
                    let oldRateString = existing.rate ?? "0"
                    
                    // API가 오늘 날짜로 새로 업데이트 됐지만 아직 앱에 반영이 안됐다면
                    if existing.lastUpdatedDate != todayDateString {
                        existing.yesterday = oldRateString
                        existing.rate = String(format: "%.4f", rate)
                        existing.lastUpdatedDate = todayDateString
                    }
                } else {
                    // 새로 저장할 경우 (앱 최초 실행 등)
                    guard let entity = NSEntityDescription.entity(forEntityName: Currency.className, in: container.viewContext) else { return }
                    let newCurrency = NSManagedObject(entity: entity, insertInto: container.viewContext)
                    newCurrency.setValue(code, forKey: Currency.Key.code)
                    newCurrency.setValue(name, forKey: Currency.Key.name)
                    newCurrency.setValue("0", forKey: Currency.Key.yesterday)
                    newCurrency.setValue(String(format: "%.4f", rate), forKey: Currency.Key.rate)
                    newCurrency.setValue(todayDateString, forKey: Currency.Key.lastUpdatedDate)
                    newCurrency.setValue(false, forKey: Currency.Key.isBookmark)
                }
            }
            saveContext()
        } catch {
            print("Update Currency Data Error: \(error)")
        }
    }
    
    func loadBookmarkedCodes() -> Set<String> {
        do {
            let currencies = try fetchData(Currency.fetchRequest())
            return Set(currencies.compactMap {
                guard $0.isBookmark, let code = $0.code else { return nil }
                return code
            })
        } catch {
            print("Load bookmarks error: \(error)")
            return []
        }
    }
    
    func toggleBookmark(for code: String) {
        let request = Currency.fetchRequest()
        request.predicate = NSPredicate(format: "code == %@", code)
        
        do {
            if let result = try fetchData(request).first {
                result.isBookmark.toggle()
                saveContext()
                print("즐겨찾기 업데이트 성공!")
            }
        } catch {
            print("즐겨찾기 업데이트 실패...")
        }
    }
    
    func readAllCurrencyData() {
        do {
            let currencies = try fetchData(Currency.fetchRequest())
            for currency in currencies {
                print("code: \(currency.code ?? ""), name: \(currency.name ?? ""), rate: \(currency.rate ?? ""), yesterday: \(currency.yesterday ?? ""), lastUpdatedDate: \(currency.lastUpdatedDate ?? ""), isBookmarked: \(currency.isBookmark)")
            }
        } catch {
            print("Currency 데이터 읽기 실패...")
        }
    }
}
