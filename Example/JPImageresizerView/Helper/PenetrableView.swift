//
//  PenetrableView.swift
//  JPImageresizerView_Example
//
//  Created by aa on 2023/9/26.
//  Copyright © 2025 ZhouJianPing. All rights reserved.
//

import UIKit

@objcMembers
class PenetrableView: UIView {
    var isPenetrable = true
    
    // MARK: 拦截点击 => 自己不响应，触碰的子视图响应。
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard isPenetrable else {
            return super.hitTest(point, with: event)
        }
        
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
