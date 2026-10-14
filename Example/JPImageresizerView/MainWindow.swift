//
//  MainWindow.swift
//  WaterfallLayoutDemo
//
//  Created by aa on 2026/10/10.
//

import UIKit

final class MainWindow: UIWindow {
    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
//        print("jp_log *** MainWindow.safeAreaInsetsDidChange: \(frame.size), \(safeAreaInsets) --- \(lookTime())")
        
//        print("jp_log *** MainWindow safeAreaInsetsDidChange:")
//        print("jp_log *** MainWindow wo \(frame.size), \(safeAreaInsets)")
//        print("jp_log *** MainWindow ta \(Env.sceneSize), \(Env.safeAreaInsets)")
//        print("jp_log *** MainWindow --------- \(lookTime())")
        
        Env.switchSplitIfNeeded(self)
    }
}
