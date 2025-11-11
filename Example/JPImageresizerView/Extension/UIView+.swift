//
//  UIView+.swift
//  JPImageresizerView_Example
//
//  Created by aa on 2025/10/28.
//  Copyright © 2025 ZhouJianPing. All rights reserved.
//

import UIKit

extension UIView {
    /// 移除与父视图相关的约束
    func removeConstraintsInParent() {
        guard let parent = superview else { return }
        
        // 找出与父视图相关的约束
        let parentConstraints = parent.constraints.filter {
            // firstItem 或 secondItem 是该view
            ($0.firstItem as? UIView) == self || ($0.secondItem as? UIView) == self
        }
        
        // 移除这些约束
        parent.removeConstraints(parentConstraints)
    }
    
    /// 移动到新父视图并且把与旧父视图相关的约束迁移过去
    @discardableResult
    func reparentAndMigrateConstraints(to newParent: UIView) -> [NSLayoutConstraint] {
        guard let oldParent = superview else {
            removeFromSuperview()
            newParent.addSubview(self)
            return []
        }
        
        // 1. 获取旧父视图所有与该view有关的约束
        let oldConstraints = oldParent.constraints.filter {
            // firstItem 或 secondItem 是该view
            ($0.firstItem as? UIView) == self || ($0.secondItem as? UIView) == self
        }
        
        // 2. 记录与旧父视图的约束描述（用来重新创建）
        var newConstraints: [NSLayoutConstraint] = []
        for constraint in oldConstraints {
            var firstItem = constraint.firstItem
            var secondItem = constraint.secondItem
            
            // 替换旧父视图为新父视图
            if (firstItem as? UIView) == oldParent { firstItem = newParent }
            if (secondItem as? UIView) == oldParent { secondItem = newParent }
            let newConstraint = NSLayoutConstraint(
                item: firstItem as Any,
                attribute: constraint.firstAttribute,
                relatedBy: constraint.relation,
                toItem: secondItem,
                attribute: constraint.secondAttribute,
                multiplier: constraint.multiplier,
                constant: constraint.constant
            )
            newConstraint.priority = constraint.priority
            newConstraint.identifier = constraint.identifier
            newConstraints.append(newConstraint)
        }
        
        // 3. 移除旧父视图上的约束
        oldParent.removeConstraints(oldConstraints)
        
        // 4. 移除并添加到新父视图
        removeFromSuperview()
        newParent.addSubview(self)
        
        // 5. 添加新约束
        if newConstraints.count > 0 {
//            translatesAutoresizingMaskIntoConstraints = false // 如果newConstraints不为空，说明这个属性早就设置好了
            NSLayoutConstraint.activate(newConstraints)
        }
        
        return newConstraints
    }
}
