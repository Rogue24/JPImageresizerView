//
//  UIViewController+.swift
//  JPImageresizerView_Example
//
//  Created by aa on 2022/12/26.
//  Copyright © 2022 ZhouJianPing. All rights reserved.
//

import UIKit
import SwiftUI

var rootVC: UIViewController {
    (UIApplication.shared.delegate?.window??.rootViewController!)!
}

extension UIViewController {
    func addCubeAnimation(duration: TimeInterval = 0.45, subtype: CATransitionSubtype = .fromRight, timingFunName: CAMediaTimingFunctionName = .easeInEaseOut, animKey: String = "cube") {
        // TODO: 在iOS26中cube动画效果有问题，不会覆盖整个要push的界面（大概只一半），等后续修复吧。
//        let cubeAnim = CATransition()
//        cubeAnim.duration = duration
//        cubeAnim.type = CATransitionType(rawValue: "cube")
//        cubeAnim.subtype = subtype
//        cubeAnim.timingFunction = CAMediaTimingFunction(name: timingFunName)
//        view.layer.add(cubeAnim, forKey: animKey)
    }
}

@available(iOS 15.0.0, *)
extension UIViewController {
    static func createCropViewController(saveOneDayImage: ((_ oneDayImage: UIImage?) -> ())?) -> UIViewController {
        let vc = CropView(saveOneDayImage: saveOneDayImage).intoUIVC()
        vc.view.clipsToBounds = true
        return vc
    }
}
