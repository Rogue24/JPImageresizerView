//
//  NotificationCenter+Key.swift
//  WaterfallLayoutDemo
//
//  Created by aa on 2026/10/9.
//

import Foundation

/// 在这里注册`Key`
extension Notification.Name {
    enum Key: String {
        case EnvSceneDidChange // Duo适配_场景发生变化的通知（内外屏切换、内屏旋转、内屏分屏）
        case EnvHingeStatusDidChange // Duo适配_铰链状态发生变化的通知
        
        var name: Notification.Name {
            Notification.Name(rawValue)
        }
    }
}
