//
//  SceneDelegate.swift
//  ExchangeRateCalculator
//
//  Created by 백래훈 on 4/14/25.
//

import UIKit
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private var container: NSPersistentContainer!

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        configureInitialViewController(window: window)
        
        window.makeKeyAndVisible()
        self.window = window
    }
    
    private func configureInitialViewController(window: UIWindow) {
        // Main DIContainer 생성
        let DIContainer = DIContainer()
        
        let mainViewController = MainViewController(DIContainer: DIContainer)
        let navigationController = UINavigationController(rootViewController: mainViewController)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.container = appDelegate.persistentContainer
        
        // fetchRequest 요청
        let saveRequest = SaveView.fetchRequest()
        let currencyRequest = Currency.fetchRequest()
        
        do {
            // 마지막으로 저장된 Result를 확인
            let saveResult = try container.viewContext.fetch(saveRequest)
            
            // 마지막으로 저장된 Result에 code가 있는지 (계산기 화면에서 끝났다면 있을 것)
            if let saveContent = saveResult.first, let code = saveContent.code {
                // 그 코드가 currencyRequest에 저장되어 있는지 확인
                currencyRequest.predicate = NSPredicate(format: "code == %@", code)
                
                // 있다면 currencyModel 생성 및 네비게이션 push 까지 실행
                if let currency = try container.viewContext.fetch(currencyRequest).first {
                    let currencyModel = CurrencyCellModel(code: currency.code ?? "",
                                                          name: CountryName.name[code] ?? "",
                                                          rate: currency.rate ?? "",
                                                          isBookmarked: currency.isBookmark,
                                                          status: .none)
                    
                    window.rootViewController = navigationController
                    
                    // DispatchQueue.main.async 구문 내에서 push 하지 않으면 계산기 화면에서
                    // 네비게이션 back title이 'back'으로 표시. view를 그리는 시점의 차이에서 문제 발생.
                    DispatchQueue.main.async {
                        navigationController.pushViewController(ExchangeRateCalculatorViewController(currencyModel: currencyModel, DIContainer: DIContainer()), animated: true)
                    }
                } else {
                    print("Currency 값 없음...")
                    window.rootViewController = navigationController
                }
            } else {
                print("SaveContent 값 없음...")
                window.rootViewController = navigationController
            }
        } catch {
            print("SaveResult load 실패...")
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

