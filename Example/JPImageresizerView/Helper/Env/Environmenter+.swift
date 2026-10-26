//
//  Environmenter+.swift
//  WaterfallLayoutDemo
//
//  Created by aa on 2026/10/14.
//

import UIKit

extension Environmenter {
    @objc static func setup(_ window: UIWindow) { Env.setup(window) }
    @available(iOS 26.0, *)
    @objc static func resetIfNeeded(_ windowScene: UIWindowScene) { Env.resetIfNeeded(windowScene) }
    @objc static func switchSplitIfNeeded(_ window: UIWindow) { Env.switchSplitIfNeeded(window) }
    
    @objc static var xcVersion: Int { Env.xcVersion }
    @objc static var isFullScreenRequired: Bool { Env.isFullScreenRequired }
    
    @objc static var displayScale: CGFloat { Env.displayScale }
    @objc static var basisSceneBounds: CGRect { Env.basisSceneBounds }
    @objc static var basisSafeAreaInsets: UIEdgeInsets { Env.basisSafeAreaInsets }
    @objc static var basisWScale: CGFloat { Env.basisWScale }
    
    @objc static var screenBounds: CGRect { Env.screenBounds }
    @objc static var sceneBounds: CGRect { Env.sceneBounds }
    @objc static var safeAreaInsets: UIEdgeInsets { Env.safeAreaInsets }
    @objc static var isHorRegular: Bool { Env.isHorRegular }
    @objc static var isVerRegular: Bool { Env.isVerRegular }
    @objc static var displayMode: EnvDisplayMode { Env.displayMode }
    
    @objc static var isLandscapeScreen: Bool { Env.isLandscapeScreen }
    @objc static var isLandscapeScene: Bool { Env.isLandscapeScene }
    @objc static var sceneSize: CGSize { Env.sceneSize }
    @objc static var sceneWidth: CGFloat { Env.sceneWidth }
    @objc static var sceneHeight: CGFloat { Env.sceneHeight }
    
    @objc static var targetSafeAreaInsets: UIEdgeInsets { Env.targetSafeAreaInsets }
    @objc static var safeAreaWithTabBarInsets: UIEdgeInsets { Env.safeAreaWithTabBarInsets }
    @objc static var safeAreaWithTopMarginInsets: UIEdgeInsets { Env.safeAreaWithTopMarginInsets }
    @objc static var safeAreaFullInsets: UIEdgeInsets { Env.safeAreaFullInsets }
    
    @objc static var isDuo: Bool { Env.isDuo }
    @objc static var hingeStatus: EnvHingeStatus { Env.hingeStatus }
    @objc static var hingeRadian: CGFloat { Env.hingeRadian }
    @objc static var hingeAngle: CGFloat { Env.hingeAngle }
    @objc static var isHingeActive: Bool { Env.isHingeActive }
    @objc static var hingeFrame: CGRect { Env.hingeFrame }
}

extension EnvDisplayMode {
    var isOuter: Bool {
        switch self {
        case .outerPortrait, .outerLandscapeLeft, .outerLandscapeRight:
            return true
        default:
            return false
        }
    }
    
    var isInner: Bool {
        switch self {
        case .outerPortrait, .outerLandscapeLeft, .outerLandscapeRight:
            return false
        default:
            return true
        }
    }
    
    var isPortrait: Bool {
        switch self {
        case .outerPortrait, .innerPortraitFull:
            return true
        default:
            return false
        }
    }
    
    var isLandscape: Bool {
        switch self {
        case .outerLandscapeLeft, .outerLandscapeRight, .innerLandscapeFull:
            return true
        default:
            return false
        }
    }
    
    var isSplit: Bool {
        switch self {
        case .innerSplitLeft, .innerSplitRight:
            return true
        default:
            return false
        }
    }
}

extension EnvHingeStatus {
    var isActive: Bool {
        switch self {
        case .partiallyOpen:
            return true
        default:
            return false
        }
    }
}





// MARK: - Debug Log
extension EnvUpdateOptions {
    var jp_log: String {
        var str = ""
        if self.contains(.bounds) {
            str += "sceneBounds_变了，"
        } else {
            str += "sceneBounds_没变，"
        }
        if self.contains(.safeArea) {
            str += "safeAreaInsets_变了，"
        } else {
            str += "safeAreaInsets_没变，"
        }
        if self.contains(.horSizeClass) {
            str += "horSizeClass_变了，"
        } else {
            str += "horSizeClass_没变，"
        }
        if self.contains(.verSizeClass) {
            str += "verSizeClass_变了。"
        } else {
            str += "verSizeClass_没变。"
        }
        return str
    }
}

extension EnvDisplayMode {
    var jp_log: String {
        switch self {
        case .outerLandscapeLeft:
            return "outerLandscapeLeft_外屏横屏向左"
        case .outerLandscapeRight:
            return "outerLandscapeRight_外屏横屏向右"
        case .innerLandscapeFull:
            return "innerLandscapeFull_内屏横屏铺满"
        case .innerSplitLeft:
            return "innerSplitLeft_内屏分屏左边"
        case .innerSplitRight:
            return "innerSplitRight_内屏分屏右边"
        case .innerPortraitFull:
            return "innerPortraitFull_内屏竖屏铺满"
        default:
            return "outerPortrait_外屏竖屏"
        }
    }
}

extension EnvHingeStatus {
    var jp_log: String {
        switch self {
        case .closed:
            return "closed_已闭合"
        case .partiallyOpen:
            return "partiallyOpen_对折中"
        case .fullyOpen:
            return "fullyOpen_全展开"
        default:
            return "unknown"
        }
    }
}

extension UIInterfaceOrientation {
    var jp_log: String {
        switch self {
        case .portrait:
            return "portrait"
        case .portraitUpsideDown:
            return "portraitUpsideDown"
        case .landscapeLeft:
            return "landscapeLeft"
        case .landscapeRight:
            return "landscapeRight"
        default:
            return "unknown"
        }
    }
}

extension UIUserInterfaceSizeClass {
    var jp_log: String {
        switch self {
        case .compact:
            return "compact_紧凑型_空间受限"
        case .regular:
            return "regular_常规型_空间充裕"
        default:
            return "unspecified"
        }
    }
}

@available(iOS 27.1, *)
extension UIVerticalBarEdge {
    var jp_log: String {
        switch self {
        case .leading:
            return "leading"
        case .trailing:
            return "trailing"
        default:
            return "unspecified"
        }
    }
}
