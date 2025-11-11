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
        // 📢：故事版和xib上的tf，通过拖线放入的子view，父视图只能是self，
        super.init(coder: coder)
        _setup()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        guard let container else { return }
        let subviews = self.subviews
        for subview in subviews where subview != container {
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
}
