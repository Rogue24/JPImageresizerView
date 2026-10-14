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
        // Duo适配_场景发生变化的通知（内外屏切换、内屏旋转、内屏全屏分屏切换、内屏左右分屏切换）
        case EnvSceneDidChange
        // Duo适配_铰链状态发生变化的通知
        case EnvHingeStatusDidChange
        
        var name: Notification.Name {
            Notification.Name(rawValue)
        }
    }
}
