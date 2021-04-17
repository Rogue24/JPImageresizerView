//
//  Configure.swift
//  JPCrop_Example
//
//  Created by Rogue24 on 2020/12/23.
//

import UIKit

public struct Configure {
    /// 裁剪图片
    public let image: UIImage
    /// 裁剪宽高比
    public let cropWHRatio: CGFloat
    
    /// 裁剪时旋转的角度
    public var radian: CGFloat
    /// 裁剪时的缩放比例
    public var zoomScale: CGFloat?
    /// 裁剪时的偏移量
    public var contentOffset: CGPoint?
    
    public init(_ image: UIImage,
                cropWHRatio: CGFloat = 0,
                radian: CGFloat = 0,
                zoomScale: CGFloat? = nil,
                contentOffset: CGPoint? = nil) {
        self.image = image
        self.cropWHRatio = cropWHRatio
        self.radian = radian
        self.zoomScale = zoomScale
        self.contentOffset = contentOffset
    }
}
