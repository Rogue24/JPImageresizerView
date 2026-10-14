//
//  SceneDelegate.swift
//  WaterfallLayoutDemo
//
//  Created by aa on 2023/3/5.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let window = MainWindow(windowScene: windowScene)
        self.window = window
        
        Env.setup(window)
        
        if let appDelegate = UIApplication.shared.delegate as? JPAppDelegate {
            // 同步给`AppDelegate.window` 👉🏻 统一全局主窗口获取处
            appDelegate.window = window
        }
        
        let navCtr = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(
            withIdentifier: "MainNavigationController"
        )
        window.rootViewController = navCtr
        
        window.makeKeyAndVisible()
    }
    
    @available(iOS 26.0, *)
    func windowScene(
        _ windowScene: UIWindowScene,
        didUpdateEffectiveGeometry previousEffectiveGeometry: UIWindowScene.Geometry
    ) {
        // previousEffectiveGeometry：旧场地
        // windowScene.effectiveGeometry：新场地
        Env.resetIfNeeded(windowScene)
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            let rectOnScreen = windowScene.effectiveGeometry.coordinateSpace.convert(windowScene.effectiveGeometry.coordinateSpace.bounds, to: windowScene.screen.coordinateSpace)
//            print("jp_log rectOnScreen222222: \(rectOnScreen)")
//        }
    }
}
