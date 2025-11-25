//
//  JPSecureView.swift
//  JPImageresizerView_Example
//
//  Created by aa on 2025/10/27.
//  Copyright © 2025 ZhouJianPing. All rights reserved.
//

import UIKit

@objcMembers
open class JPSecureView: UITextField {
    // MARK: - Private Properties
    private var isInitialized = false
    private weak var _container: UIView? = nil
    
    // MARK: - Public Properties
    public var container: UIView? {
        _container ?? {
            guard isInitialized else { return nil }
            for subview in subviews {
                // #1 `type(of: view)`的作用是【在运行时】获取某个实例的实际类型。
                // 也就是说返回的是这个对象真实的类型（Type），而不是它的父类或声明类型。
                let clsName = NSStringFromClass(type(of: subview))
                // #2 主要是获取这个`_UITextLayoutCanvasView`，是个私有类（"_"开头的一般都是私有类），
                // 后续系统不知道会不会对其改名，并且目前只发现tf只有一个私有类的情况下，因此目前只判断前缀是不是"_"即可。
                guard clsName.hasPrefix("_") else { continue }
                subview.removeConstraintsInParent()
                subview.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    subview.leadingAnchor.constraint(equalTo: leadingAnchor),
                    subview.trailingAnchor.constraint(equalTo: trailingAnchor),
                    subview.topAnchor.constraint(equalTo: topAnchor),
                    subview.bottomAnchor.constraint(equalTo: bottomAnchor)
                ])
                subview.isUserInteractionEnabled = true
                _container = subview
                return subview
            }
            return nil
        }()
    }
    
    public var isSecured: Bool {
        set { super.isSecureTextEntry = newValue }
        get { super.isSecureTextEntry }
    }
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setup()
    }
    
    public required init?(coder: NSCoder) {
        /// 📢：故事版和xib上的textField，通过拖线放入的那些子view，
        /// 执行`super.init(coder: coder)`时就已经将这些子view放到self上，
        super.init(coder: coder)
        /// 因此不能通过重写父类方法修改初始化的父视图，此时的父视图只会是self。
        _setup()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        /// 既然不能在初始化时就将xib的子view将self上转移，那就在这里转移吧~
        guard let container else { return }
        let subviews = self.subviews
        for subview in subviews where subview != container {
            // 转移到新父视图，并将与旧父视图关联约束也转移到新的父视图
            subview.reparentAndMigrateConstraints(to: container)
        }
    }
    
    // MARK: - Setup
    private func _setup() {
        insetsLayoutMarginsFromSafeArea = false
        borderStyle = .none
        isSecured = true
        isInitialized = true
    }
    
    // MARK: - Override
    public override var canBecomeFirstResponder: Bool {
        false
    }
    
    public override var isSecureTextEntry: Bool {
        set {}
        get { super.isSecureTextEntry }
    }
    
    // 用了约束就不用特地去更新frame
//    public override func layoutSubviews() {
//        super.layoutSubviews()
//        container?.frame = bounds
//    }
    
    public override func addSubview(_ view: UIView) {
        guard isInitialized else {
            super.addSubview(view)
            return
        }
        container?.addSubview(view)
    }
    
    public override func insertSubview(_ view: UIView, at index: Int) {
        guard isInitialized else {
            super.insertSubview(view, at: index)
            return
        }
        container?.insertSubview(view, at: index)
    }
    
    public override func insertSubview(_ view: UIView, aboveSubview siblingSubview: UIView) {
        guard isInitialized else {
            super.insertSubview(view, aboveSubview: siblingSubview)
            return
        }
        container?.insertSubview(view, aboveSubview: siblingSubview)
    }
    
    public override func insertSubview(_ view: UIView, belowSubview siblingSubview: UIView) {
        guard isInitialized else {
            super.insertSubview(view, belowSubview: siblingSubview)
            return
        }
        container?.insertSubview(view, belowSubview: siblingSubview)
    }
    
    // MARK: 拦截点击 => 自己不响应，触碰的子视图响应。
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !isHidden, alpha > 0.01, subviews.count > 0 else {
            // 自身不响应
            return nil
        }
        
        // 子视图从【顶层】开始遍历
        for subview in subviews.reversed() {
            // 判断一个`View`是否能响应的条件：
            guard subview.isUserInteractionEnabled, // 1.能否交互
                  !subview.isHidden, // 2.非隐藏
                  subview.alpha > 0.01, // 3.非透明
                  subview.frame.contains(point) // 4.触碰点是否属于视图区域内
            else { continue }
            
            // 转换为相对于子视图上的触碰点
            let subPoint = convert(point, to: subview)
            guard let rspView = subview.hitTest(subPoint, with: event) else { continue }
            return rspView
        }
        
        // 自身不响应
        return nil
    }
}
