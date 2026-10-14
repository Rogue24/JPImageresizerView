//
//  Env.swift
//  WaterfallLayoutDemo
//
//  Created by aa on 2026/10/9.
//

import UIKit

enum Env {
    // 常量
    private(set) static var isDuo: Bool = false
    private(set) static var displayScale: CGFloat = 0
    private(set) static var basisSceneBounds: CGRect = .zero
    private(set) static var basisSafeAreaInsets: UIEdgeInsets = .zero
    private(set) static var basisWScale: CGFloat = 0
    
    // 变量
    private(set) static var screenBounds: CGRect = .zero
    private(set) static var sceneBounds: CGRect = .zero
    private(set) static var safeAreaInsets: UIEdgeInsets = .zero
    private(set) static var isHorRegular: Bool = false
    private(set) static var isVerRegular: Bool = false
    private(set) static var displayMode: EnvDisplayMode = .outerPortrait
    
    private static var _isConfigured = false
    private static var _delayReset: DispatchWorkItem? = nil
    private static var isReseting: Bool { _delayReset != nil }
    
    static var isLandscapeScreen: Bool { screenBounds.width > screenBounds.height }
    static var isLandscapeScene: Bool { sceneBounds.width > sceneBounds.height }
    static var sceneSize: CGSize { sceneBounds.size }
    static var sceneWidth: CGFloat { sceneBounds.width }
    static var sceneHeight: CGFloat { sceneBounds.height }
    
    static var safeAreaWithTabBarInsets: UIEdgeInsets {
        var safeAreaInsets = self.safeAreaInsets
        guard isDuo else {
            safeAreaInsets.bottom += tabBarBaseH
            return safeAreaInsets
        }
        switch displayMode {
        case .innerSplitLeft:
            safeAreaInsets.left = 84
        case .innerPortraitFull:
            safeAreaInsets.bottom = 83 // 49 + 34
        default:
            break
        }
        return safeAreaInsets
    }
    
    static var safeAreaWithTopMarginInsets: UIEdgeInsets {
        var safeAreaInsets = self.safeAreaInsets
        guard isDuo else {
            return safeAreaInsets
        }
        switch displayMode {
        case .innerPortraitFull:
            break
        default:
            safeAreaInsets.top = 24
        }
        return safeAreaInsets
    }
    
    static var safeAreaFullInsets: UIEdgeInsets {
        var safeAreaInsets = self.safeAreaInsets
        guard isDuo else {
            safeAreaInsets.bottom += tabBarBaseH
            return safeAreaInsets
        }
        switch displayMode {
        case .innerSplitLeft:
            safeAreaInsets.top = 24
            safeAreaInsets.left = 84
        case .innerPortraitFull:
            safeAreaInsets.bottom = 83 // 49 + 34
        default:
            safeAreaInsets.top = 24
        }
        return safeAreaInsets
    }
    
    // 外屏竖屏 Compact × Regular
    // 外屏横屏 Compact × Compact
    // 内屏铺满 Regular × Regular
    // 内屏半屏 Compact × Regular
//    static var isInnerDisplay: Bool { isHorRegular && isVerRegular }
}

// MARK: - 初始化配置
extension Env {
    static func setup(_ window: UIWindow) {
        guard let windowScene = window.windowScene else { return }
        window.layoutIfNeeded()
        
        let trait = windowScene.traitCollection
        displayScale = trait.displayScale
        isHorRegular = trait.horizontalSizeClass == .regular
        isVerRegular = trait.verticalSizeClass == .regular
        
        let screenSpace = windowScene.screen.coordinateSpace
        screenBounds = screenSpace.bounds
        
        let sceneSpace: UICoordinateSpace
        if #available(iOS 26.0, *) {
            sceneSpace = windowScene.effectiveGeometry.coordinateSpace
        } else {
            sceneSpace = window.coordinateSpace
        }
        sceneBounds = sceneSpace.bounds
        
        safeAreaInsets = window.safeAreaInsets
        
        // 判断屏幕和App最大边是否相等，否则就是内屏正在分屏展示中（两个App并排同时运行）
        if max(screenBounds.width, screenBounds.height) == max(sceneBounds.width, sceneBounds.height) {
            if isHorRegular && isVerRegular { // 内屏铺满 Regular × Regular
                displayMode = isLandscapeScene ? .innerLandscapeFull : .innerPortraitFull
            } else { // 外屏
                let orientation: UIInterfaceOrientation
                if #available(iOS 26.0, *) {
                    orientation = windowScene.effectiveGeometry.interfaceOrientation
                } else {
                    orientation = windowScene.interfaceOrientation
                }
                switch orientation {
                case .landscapeLeft:
                    displayMode = .outerLandscapeLeft
                case .landscapeRight:
                    displayMode = .outerLandscapeRight
                default:
                    displayMode = .outerPortrait
                }
            }
        } else { // 内屏分屏
//            if #available(iOS 27.1, *) {
//                if let hinge = window.reservedRegions(kind: .division, options: .includeInactive).first {
//                    if hinge.frame.minX > window.bounds.midX {
//                        displayMode = .innerSplitLeft // 左边
//                    } else if hinge.frame.maxX < window.bounds.midX {
//                        displayMode = .innerSplitRight // 右边
//                    }
//                }
//            }
            // 临时处理：在左边时不会有右侧栏，所以right是0。
            if safeAreaInsets.right > 0 { // 右边
                displayMode = .innerSplitRight
            } else { // 左边
                displayMode = .innerSplitLeft
            }
        }
        
        // 临时处理：直接判断手机屏幕是不是Duo机型的尺寸
        if #available(iOS 27.1, *) {
            // 外屏尺寸：466 x 678 | 内屏尺寸：951 x 669
            isDuo = (min(screenBounds.width, screenBounds.height) == 466.0 && max(screenBounds.width, screenBounds.height) == 678.0)
                 || (max(screenBounds.width, screenBounds.height) == 951.0 && min(screenBounds.width, screenBounds.height) == 669.0)
        } else {
            isDuo = false
        }
        
        if isDuo {
            // 临时处理：使用外屏的尺寸和安全区域
            basisSceneBounds = CGRect(x: 0.0, y: 0.0, width: 466.0, height: 678.0)
            basisSafeAreaInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 34.0, right: 84.0)
        } else {
            basisSceneBounds = sceneBounds
            basisSafeAreaInsets = safeAreaInsets
        }
        basisWScale = basisSceneBounds.width / 375.0
        
        // 监听铰链变化
        if #available(iOS 27.1, *), isDuo {
            window.addInteraction(interaction)
        }
        
//        print("jp_log Env.sceneSize: \(self.sceneSize)")
//        print("jp_log Env.safeAreaInsets: \(self.safeAreaInsets)")
//        print("jp_log Env.displayMode: \(self.displayMode.jp_log)")
//        print("jp_log Env.hingeStatus: \(self.hingeStatus.jp_log)")
//        print("jp_log Env.hingeAngle: \(self.hingeAngle)")
//        print("jp_log setup ------------------------------- \(lookTime())")
    }
}

// MARK: - 场景变化（内外屏切换、内屏旋转、内屏全屏分屏切换）
@available(iOS 26.0, *)
extension Env {
    static func resetIfNeeded(_ windowScene: UIWindowScene) {
#if DEBUG
        log_1(windowScene)
#endif
        _delayReset?.cancel()
        _delayReset = nil
        
        // 拖拽中尺寸会不断变化，故暂不刷新
        if windowScene.effectiveGeometry.isInteractivelyResizing {
#if DEBUG
            log_2(windowScene)
            log_3(windowScene)
#endif
            return
        }
        
        // 此时的window还没真正的变化，需要下一轮Runloop才会同步最新的尺寸
        let resetItem = DispatchWorkItem {
            _delayReset = nil
            _resetIfNeeded(windowScene)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08, execute: resetItem)
        _delayReset = resetItem
    }
    
    static private func _resetIfNeeded(_ windowScene: UIWindowScene) {
#if DEBUG
        log_2(windowScene)
        defer { log_3(windowScene) }
#endif
        guard let window = windowScene.windows.first else { return }
//        print("jp_log window.layoutIfNeeded before \(window.safeAreaInsets)")
        window.layoutIfNeeded() // 📌 核心代码：调用这句才能立马同步最新的安全区域
//        print("jp_log window.layoutIfNeeded after \(window.safeAreaInsets)")
        
        let trait = windowScene.traitCollection
        let isHorRegular = trait.horizontalSizeClass == .regular
        let isVerRegular = trait.verticalSizeClass == .regular
        
        let screenSpace = windowScene.screen.coordinateSpace
        let screenBounds = screenSpace.bounds
        
        let sceneSpace = windowScene.effectiveGeometry.coordinateSpace
        let sceneBounds = sceneSpace.bounds
        
        let safeAreaInsets = window.safeAreaInsets
        
        // ---------- 更新变量 ----------
        var isRotated: Bool = false
        
        // 判断屏幕最大边是否相等，否则就是内外屏切换
        if max(self.screenBounds.width, self.screenBounds.height) == max(screenBounds.width, screenBounds.height) {
            let originIsLandscape = self.isLandscapeScreen
            let currentIsLandscape = screenBounds.width > screenBounds.height
            isRotated = originIsLandscape != currentIsLandscape
        }
        self.screenBounds = screenBounds
        
        // 判断屏幕和App最大边是否相等，否则就是内屏正在分屏展示中（两个App并排同时运行）
        if max(screenBounds.width, screenBounds.height) == max(sceneBounds.width, sceneBounds.height) {
            if isHorRegular && isVerRegular { // 内屏铺满 Regular × Regular
                let currentIsLandscape = sceneBounds.width > sceneBounds.height
                displayMode = currentIsLandscape ? .innerLandscapeFull : .innerPortraitFull
            } else { // 外屏
                let orientation = windowScene.effectiveGeometry.interfaceOrientation
                switch orientation {
                case .landscapeLeft:
                    displayMode = .outerLandscapeLeft
                case .landscapeRight:
                    displayMode = .outerLandscapeRight
                default:
                    displayMode = .outerPortrait
                }
            }
        } else { // 内屏分屏
//            if #available(iOS 27.1, *) {
//                if let hinge = window.reservedRegions(kind: .division, options: .includeInactive).first {
//                    if hinge.frame.minX > window.bounds.midX {
//                        displayMode = .innerSplitLeft // 左边
//                    } else if hinge.frame.maxX < window.bounds.midX {
//                        displayMode = .innerSplitRight // 右边
//                    }
//                }
//            }
            // 临时处理：在左边时不会有右侧栏，所以right是0。
            if safeAreaInsets.right > 0 { // 右边
                displayMode = .innerSplitRight
            } else { // 左边
                displayMode = .innerSplitLeft
            }
        }
        
        // ---------- 检查变化+更新变量 ----------
        var options: EnvUpdateOptions = []
        
        if self.sceneBounds != sceneBounds {
            self.sceneBounds = sceneBounds
            options.insert(.bounds)
        }
        
        if self.safeAreaInsets != safeAreaInsets {
            self.safeAreaInsets = safeAreaInsets
            options.insert(.safeArea)
        }
        
        if self.isHorRegular != isHorRegular {
            self.isHorRegular = isHorRegular
            options.insert(.horSizeClass)
        }
        
        if self.isVerRegular != isVerRegular {
            self.isVerRegular = isVerRegular
            options.insert(.verSizeClass)
        }
        
        // ---------- 配置完成 ----------
        _isConfigured = true
        
        // ---------- 若变化则广播 ----------
        if options.isEmpty {
//            print("jp_log Env no Change")
            return
        }
        
        // 内外屏切换没有动画，屏幕旋转才有动画
        let transitionDuration: TimeInterval = (isRotated && UIApplication.jp_appState == .active) ? 0.3 : 0
        NotificationCenter.jp.post(key: .EnvSceneDidChange, userInfo: [
            "options": options.rawValue,
            "transitionDuration": transitionDuration,
        ])
//        print("jp_log Env.safeAreaInsets: \(safeAreaInsets)")
//        print("jp_log Env.safeAreaWithTabBarInsets: \(safeAreaWithTabBarInsets)")
//        print("jp_log Env.transitionDuration: \(transitionDuration)")
    }
}

// MARK: - 场景变化（内屏左右分屏切换）
extension Env {
    static func switchSplitIfNeeded(_ window: UIWindow) {
        guard _isConfigured, isDuo else { return }
        guard !isReseting else { return }
        guard displayMode.isSplit, window.safeAreaInsets.top == 0 else { return }
        guard sceneBounds == window.bounds, safeAreaInsets != window.safeAreaInsets else { return }
        
        safeAreaInsets = window.safeAreaInsets
        if safeAreaInsets.right > 0 { // 右边
            displayMode = .innerSplitRight
        } else { // 左边
            displayMode = .innerSplitLeft
        }
        
        let options = EnvUpdateOptions.safeArea
        NotificationCenter.jp.post(key: .EnvSceneDidChange, userInfo: [
            "options": options.rawValue,
            "transitionDuration": 0,
        ])
//        print("jp_log Env.safeAreaInsets: \(safeAreaInsets)")
//        print("jp_log Env.safeAreaWithTabBarInsets: \(safeAreaWithTabBarInsets)")
//        print("jp_log Env.displayMode: \(displayMode.jp_log)")
    }
    
    /*
    - (void)didReceiveEnvSceneDidChange:(NSNotification *)notification {
        EnvUpdateOptions options = [notification.userInfo[@"options"] unsignedIntegerValue];
        if (options & EnvUpdateOptions_Bounds) {
            
        }
        if (options & EnvUpdateOptions_SafeArea) {
            
        }
     
        NSTimeInterval duration = [notification.userInfo[@"transitionDuration"] doubleValue];
    }
     
    @objc func didReceiveEnvSceneDidChange(notification: Notification) {
        guard let rawValue = notification.userInfo?["options"] as? UInt else { return }
        let options = EnvUpdateOptions(rawValue: rawValue)
        if options.contains(.bounds) {
        
        }
        if options.contains(.safeArea) {
            
        }
     
        let duration = notification.userInfo?["transitionDuration"] as? TimeInterval ?? 0
    }
     */
}

// MARK: - 铰链相关（Duo适配）
extension Env {
    @available(iOS 27.1, *)
    static private let interaction = UIHingeInteraction { _, update in
        // 这里是在`viewWillAppear`之后、`viewDidAppear`之前执行的(吧？)
        if let hinge = update.hinge {
            hingeRadian = hinge.angle
            switch hinge.status {
            case .closed:
                hingeStatus = .closed
            case .partiallyOpen:
                hingeStatus = .partiallyOpen
            case .fullyOpen:
                hingeStatus = .fullyOpen
            default:
                hingeStatus = .unknown
            }
        } else {
            hingeRadian = 0
            hingeStatus = .unknown
        }
//        print("jp_log 铰链角度：\(hingeAngle)")
    }
    
    static private(set) var hingeRadian: CGFloat = 0
    static var hingeAngle: CGFloat { (hingeRadian * 180.0) / CGFloat.pi }
    
    static private(set) var hingeStatus: EnvHingeStatus = .unknown {
        didSet {
            guard _isConfigured, hingeStatus != oldValue else { return }
            NotificationCenter.jp.post(key: .EnvHingeStatusDidChange, userInfo: [
                "oldStatus": oldValue.rawValue,
                "nowStatus": hingeStatus.rawValue,
            ])
//            print("jp_log 铰链状态发生变化 以前是：\(oldValue.jp_log), 现在是：\(hingeStatus.jp_log)")
        }
    }
    
    /*
     - (void)didReceiveEnvHingeStatusDidChange:(NSNotification *)notification {
         EnvHingeStatus oldStatus = [notification.userInfo[@"oldStatus"] integerValue];
         EnvHingeStatus nowStatus = [notification.userInfo[@"nowStatus"] integerValue];
     }
     
     @objc func didReceiveEnvHingeStatusDidChange(notification: Notification) {
         guard let userInfo = notification.userInfo,
               let oldRawValue = userInfo["oldStatus"] as? Int,
               let nowRawValue = userInfo["nowStatus"] as? Int,
               let oldStatus = EnvHingeStatus(rawValue: oldRawValue),
               let nowStatus = EnvHingeStatus(rawValue: nowRawValue)
         else { return }
     }
     */
    
    static var isHingeActive: Bool {
        hingeStatus.isActive
    }
    
    static var hingeFrame: CGRect {
        switch displayMode {
        case .innerLandscapeFull:
            let hingeW: CGFloat = 40.0
            return CGRect(
                x: (sceneWidth - hingeW) * 0.5,
                y: 0.0,
                width: hingeW,
                height: sceneHeight
            )
        case .innerPortraitFull:
            let hingeH: CGFloat = 40.0
            return CGRect(
                x: 0.0,
                y: (sceneHeight - hingeH) * 0.5,
                width: sceneWidth,
                height: hingeH
            )
        case .innerSplitLeft:
            let hingeW: CGFloat = 13.5 // 13.5 + 13 + 13.5 = 40，所以中间那条缝宽13
            return CGRect(
                x: sceneWidth - hingeW,
                y: 0.0,
                width: hingeW,
                height: sceneHeight
            )
        case .innerSplitRight:
            let hingeW: CGFloat = 13.5
            return CGRect(
                x: 0.0,
                y: 0.0,
                width: hingeW,
                height: sceneHeight
            )
        default:
            return .zero
        }
    }
}

// MARK: - 状态栏/导航栏/TabBar
extension Env {
    /// 状态栏高度
    static var statusBarH: CGFloat {
        guard _statusBarH == 0 else { return _statusBarH }
        _statusBarH = UIApplication.jp_window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        return _statusBarH
    }
    private static var _statusBarH: CGFloat = 0
    
    /// 导航栏基本高度
    static var navBarH: CGFloat { 44.0 }
    /// 状态栏+导航栏高度
    static var statusNavBarH: CGFloat { statusBarH + navBarH }
    
    /// tabBar基本高度
    static var tabBarBaseH: CGFloat { 49.0 }
    /// tabBar+底部安全间距
    static var tabBarFullH: CGFloat { tabBarBaseH + safeAreaInsets.bottom }
    
    /// tabBar基本高度/宽度
    static var tabBarSize: CGFloat {
        guard isDuo else {
            return tabBarBaseH
        }
        switch displayMode {
        case .innerPortraitFull:
            return 49
        default:
            return 84
        }
    }
    /// tabBar+安全间距
    static var tabBarInset: CGFloat {
        guard isDuo else {
            return tabBarFullH
        }
        switch displayMode {
        case .innerPortraitFull:
            return 83 // 49 + 34
        default:
            return 84
        }
    }
    
    /// 顶部基本间距
    static var topMargin: CGFloat {
        guard isDuo else {
            return 20
        }
        switch displayMode {
        case .innerPortraitFull:
            return 82
        default:
            return 24
        }
    }
}

// MARK: - Debug Log
@available(iOS 26.0, *)
private extension Env {
    static func log_1(_ windowScene: UIWindowScene) {
//        let geometry = windowScene.effectiveGeometry
////        let trait = windowScene.traitCollection
//
//        let isResizing = geometry.isInteractivelyResizing // 是否正在拖拽窗口
//        print("jp_log isResizing: \(isResizing) --- \(lookTime())")
//
//        let orientation = geometry.interfaceOrientation
//        print("jp_log orientation: \(orientation.jp_log)")
//
////        let isOrientationLocked = geometry.isInterfaceOrientationLocked
////        print("jp_log isOrientationLocked: \(isOrientationLocked)")
////
////        let displayScale = trait.displayScale
////        print("jp_log displayScale: \(displayScale)")
////
////        let horSizeClass = trait.horizontalSizeClass
////        print("jp_log horizontalSizeClass: \(horSizeClass.jp_log)")
////
////        let verSizeClass = trait.verticalSizeClass
////        print("jp_log verticalSizeClass: \(verSizeClass.jp_log)")
////
////        if #available(iOS 27.1, *) {
////            let verBarEdge = trait.verticalBarEdge
////            print("jp_log verticalBarEdge: \(verBarEdge.jp_log)")
////        }
//
//        let sceneBounds = geometry.coordinateSpace.bounds
//        print("jp_log scene.bounds: \(sceneBounds)")
//
//        let screenBounds = windowScene.screen.coordinateSpace.bounds
//        print("jp_log screen.bounds: \(screenBounds)")
//
////        let rectOnScreen = geometry.coordinateSpace.convert(sceneBounds, to: windowScene.screen.coordinateSpace)
////        print("jp_log rectOnScreen: \(rectOnScreen)")
    }
    
    static func log_2(_ windowScene: UIWindowScene) {
////        let mainBounds = UIScreen.main.bounds
////        print("jp_log UIScreen.main.bounds: \(mainBounds)")
////
////        let statusBarFrame = windowScene.statusBarManager?.statusBarFrame ?? .zero
////        print("jp_log statusBarFrame: \(statusBarFrame)")
//
//        if #available(iOS 27.1, *) {
//            let verBarEdge = windowScene.traitCollection.verticalBarEdge
//            print("jp_log verticalBarEdge: \(verBarEdge.jp_log)")
//        }
//
//        if let window = windowScene.windows.first {
////            print("jp_log windows.first == self.window: \(window == self.window)") // true
////            print("jp_log windows.first == windowScene.keyWindow: \(window == windowScene.keyWindow)") // true
////            print("jp_log windows.first.windowScene == windowScene: \(window.windowScene == windowScene)") // true
//            print("jp_log window.bounds: \(window.bounds)")
//            print("jp_log window.safeAreaInsets: \(window.safeAreaInsets)")
//        }
    }
    
    static func log_3(_ windowScene: UIWindowScene) {
//        print("jp_log Env.displayMode: \(self.displayMode.jp_log)")
//        print("jp_log Env.hingeStatus: \(self.hingeStatus.jp_log)")
//        print("jp_log Env.hingeAngle: \(self.hingeAngle)")
//        print("jp_log Env.hingeFrame: \(self.hingeFrame)")
//        if #available(iOS 27.1, *), let window = windowScene.windows.first {
//            if let hinge = window.reservedRegions(kind: .division, options: .includeInactive).first {
//                print("jp_log 铰链 hinge: \(hinge.isActive), \(hinge.frame)")
//                if hinge.frame.minX > window.bounds.midX {
//                    print("jp_log 铰链在App的右边，所以App在左半屏")
//                } else if hinge.frame.maxX < window.bounds.midX {
//                    print("jp_log 铰链在App的左边，所以App在右半屏")
//                } else {
//                    print("jp_log 铰链在App的中间，所以App满屏展示ing")
//                }
//            } else {
//                print("jp_log 找不着铰链")
//            }
//        }
//        print("jp_log reset ------------------------------- \(lookTime())")
    }
}
