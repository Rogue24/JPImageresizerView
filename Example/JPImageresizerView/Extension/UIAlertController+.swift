//
//  UIAlertController+.swift
//  JPMovieWriter_Example
//
//  Created by 周健平 on 2023/4/12.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit

@objc
extension UIAlertController {
    static func build(_ preferredStyle: UIAlertController.Style, title: String? = nil, message: String? = nil) -> UIAlertController {
        UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
    }
    
    @discardableResult
    func addAction(_ title: String?,
                   handler: (() -> Void)?) -> UIAlertController {
        addAction(UIAlertAction(title: title, style: .default, handler: { _ in
            handler?()
        }))
        return self
    }
    
    @discardableResult
    func addDestructive(_ title: String?,
                        handler: (() -> Void)?) -> UIAlertController {
        addAction(UIAlertAction(title: title, style: .destructive, handler: { _ in
            handler?()
        }))
        return self
    }
    
    @discardableResult
    func addCancel(_ title: String? = "取消",
                   handler: (() -> Void)? = nil) -> UIAlertController {
        addAction(UIAlertAction(title: title, style: .cancel, handler: { _ in
            handler?()
        }))
        return self
    }
    
    func present(from vc: UIViewController) {
        vc.present(self, animated: true)
    }
}
