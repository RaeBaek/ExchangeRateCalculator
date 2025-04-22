//
//  ExchangeRateCalculatorViewModel.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/16/25.
//

import UIKit

import CoreData

import RxSwift
import RxCocoa

final class ExchangeRateCalculatorViewModel {
    
    struct Input {
        let currencyValue: ControlProperty<String>
        let convertButtonTapped: ControlEvent<Void>
    }
    
    struct Output {
        let currencyModel: BehaviorRelay<CurrencyCellModel>
        let convertError: PublishRelay<Void>
        let exchangeValue: PublishRelay<String>
    }
    
    private let currencyModel: CurrencyCellModel
    
    private var container: NSPersistentContainer!
    
    private let disposeBag = DisposeBag()
    
    init(currencyModel: CurrencyCellModel) {
        self.currencyModel = currencyModel
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.container = appDelegate.persistentContainer
    }
    
    func savedCurrentView() {
        do {
            let current = try container.viewContext.fetch(SaveView.fetchRequest())
            
            if let currentValue = current.first {
                currentValue.setValue("ExchangeRateCalculator", forKey: SaveView.Key.isLastView)
                currentValue.setValue("\(currencyModel.code)", forKey: SaveView.Key.code)
            } else {
                guard let entity = NSEntityDescription.entity(forEntityName: SaveView.className, in: container.viewContext) else { return }
                let newCurrency = NSManagedObject(entity: entity, insertInto: container.viewContext)
                newCurrency.setValue("ExchangeRateCalculator", forKey: SaveView.Key.isLastView)
                newCurrency.setValue("\(currencyModel.code)", forKey: SaveView.Key.code)
            }
            try container.viewContext.save()
            print("Save View 저장 완료! (Calculator)")
        } catch {
            print("Save View 저장 실패...")
        }
    }
    
    func transform(input: Input) -> Output {
        let currencyModel = BehaviorRelay<CurrencyCellModel>(value: currencyModel)
        let convertError = PublishRelay<Void>()
        let exchangeValue = PublishRelay<String>()
        
        input.convertButtonTapped
            .withLatestFrom(Observable.combineLatest(currencyModel, input.currencyValue))
            .map { model, value -> String in
                guard let rate = Double(model.rate), let value = Double(value) else {
                    convertError.accept(())
                    return "계산 결과가 이곳에 표시됩니다." }
                
                return "\(String(format: "%.2f", value)) \(CurrencyName.current) -> \(String(format: "%.2f", rate * value)) \(model.code)"
            }
            .bind(to: exchangeValue)
            .disposed(by: disposeBag)
        
        return Output(currencyModel: currencyModel,
                      convertError: convertError,
                      exchangeValue: exchangeValue)
    }
}
