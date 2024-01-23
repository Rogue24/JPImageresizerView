//
//  JPImageresizerView+.swift
//  JPImageresizerView_Example
//
//  Created by aa on 2024/1/22.
//  Copyright © 2024 ZhouJianPing. All rights reserved.
//

import Foundation
import JPImageresizerView
import JPBasic

extension JPImageresizerTool {
    static func addStrokeForContentOutline(withImage image: UIImage,
                                           strokeColor: UIColor,
                                           strokeWidth: CGFloat,
                                           padding: UIEdgeInsets,
                                           cacheURL: URL?) async -> JPImageresizerResult? {
        JPProgressHUD.show()
        return await withCheckedContinuation { (continuation: CheckedContinuation<JPImageresizerResult?, Never>) in
            self.addStrokeForContentOutline(with: image, stroke: strokeColor, strokeWidth: Int(strokeWidth), padding: padding, cacheURL: cacheURL) { kURL, reason in
                JPProgressHUD.showImageresizerError(reason, pathExtension: kURL?.pathExtension ?? "")
                continuation.resume(returning: nil)
            } complete: { result in
                if result == nil {
                    JPProgressHUD.showError(withStatus: "操作失败", userInteractionEnabled: true)
                } else {
                    JPProgressHUD.dismiss()
                }
                continuation.resume(returning: result)
            }
        }
    }
}
