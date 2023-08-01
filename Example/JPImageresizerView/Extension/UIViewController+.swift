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
        let cubeAnim = CATransition()
        cubeAnim.duration = duration
        cubeAnim.type = CATransitionType(rawValue: "cube")
        cubeAnim.subtype = subtype
        cubeAnim.timingFunction = CAMediaTimingFunction(name: timingFunName)
        view.layer.add(cubeAnim, forKey: animKey)
    }
}

@available(iOS 15.0.0, *)
extension UIViewController {
    static func createCropViewController(saveOneDayImage: ((_ oneDayImage: UIImage?) -> ())?) -> UIViewController {
        let vc = UIHostingController(rootView: CropView(saveOneDayImage: saveOneDayImage))
        vc.view.clipsToBounds = true
        return vc
    }
}
