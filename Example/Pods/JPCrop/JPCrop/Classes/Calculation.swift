//
//  Calculation.swift
//  JPCrop_Example
//
//  Created by Rogue24 on 2020/12/26.
//

import UIKit

extension Croper {
    func checkCropWHRatio(_ cropWHRatio: CGFloat, isCallBack: Bool = false) -> CGFloat {
        if cropWHRatio < Self.cropWHRatioRange.lowerBound {
            if isCallBack, let overstep = cropWHRatioRangeOverstep {
                overstep(false, Self.cropWHRatioRange.lowerBound)
            }
            
            if cropWHRatio <= 0 {
                return 0
            }
            return Self.cropWHRatioRange.lowerBound
        }
        
        if cropWHRatio > Self.cropWHRatioRange.upperBound {
            if isCallBack, let overstep = cropWHRatioRangeOverstep {
                overstep(true, Self.cropWHRatioRange.upperBound)
            }
            
            return Self.cropWHRatioRange.upperBound
        }
        
        return cropWHRatio
    }
    
    func checkRadian(_ radian: CGFloat) -> CGFloat {
        switch radian {
        case ...Self.radianRange.lowerBound:
            return Self.radianRange.lowerBound
        case Self.radianRange.upperBound...:
            return Self.radianRange.upperBound
        default:
            return radian
        }
    }
    
    func fitCropFrame() -> CGRect {
        let margin = Self.margin
        let w = bounds.width - margin * 2
        let h = w / (cropWHRatio > 0 ? cropWHRatio : checkCropWHRatio(imageWHRatio))
        let x = margin
        let y = margin + (bounds.height - margin * 2 - h) * 0.5
        return .init(x: x, y: y, width: w, height: h)
    }
    
    func fitImageSize() -> CGSize {
        var imageW: CGFloat
        var imageH: CGFloat
        if isLandscapeImage {
            imageH = cropFrame.height
            imageW = imageH * imageWHRatio
            if imageW < cropFrame.width {
                imageW = cropFrame.width
                imageH = imageW / imageWHRatio
            }
        } else {
            imageW = cropFrame.width
            imageH = imageW / imageWHRatio
            if imageH < cropFrame.height {
                imageH = cropFrame.height
                imageW = imageH * imageWHRatio
            }
        }
        return .init(width: imageW, height: imageH)
    }
    
    func fitFactor() -> (scale: CGFloat, transform: CGAffineTransform, contentInset: UIEdgeInsets) {
        let absRadian = fabs(Double(radian))
        let cosValue = CGFloat(cos(absRadian))
        let sinValue = CGFloat(sin(absRadian))
        
        let verSide1 = cosValue * cropFrame.height
        let verSide2 = sinValue * cropFrame.width
        
        let horSide1 = cosValue * cropFrame.width
        let horSide2 = sinValue * cropFrame.height
        
        let scale: CGFloat
        let verMargin: CGFloat
        let horMargin: CGFloat
        if isLandscapeImage {
            scale = (verSide1 + verSide2) / cropFrame.height
            verMargin = minVerMargin
            horMargin = (cropFrame.width * scale - (horSide1 + horSide2)) * 0.5 / scale + minHorMargin
        } else {
            scale = (horSide1 + horSide2) / cropFrame.width
            verMargin = (cropFrame.height * scale - (verSide1 + verSide2)) * 0.5 / scale + minVerMargin
            horMargin = minHorMargin
        }
        
        return (scale,
                CGAffineTransform(rotationAngle: radian).scaledBy(x: scale, y: scale),
                UIEdgeInsets(top: verMargin, left: horMargin, bottom: verMargin, right: horMargin))
    }
    
    func fitOffset(_ xSclae: CGFloat, _ ySclae: CGFloat, contentSize: CGSize? = nil, contentInset: UIEdgeInsets? = nil) -> CGPoint {
        let sBounds = scrollView.bounds
        let size = contentSize ?? scrollView.contentSize
        
        var offsetX = xSclae * size.width - sBounds.width * 0.5
        var offsetY = ySclae * size.height - sBounds.height * 0.5
        
        guard let insets = contentInset else {
            return .init(x: offsetX, y: offsetY)
        }
        
        let maxOffsetX = size.width - sBounds.width + insets.right
        let maxOffsetY = size.height - sBounds.height + insets.bottom
        
        if offsetX < -insets.left {
            offsetX = -insets.left
        } else if offsetX > maxOffsetX {
            offsetX = maxOffsetX
        }
        
        if offsetY < -insets.top {
            offsetY = -insets.top
        } else if offsetY > maxOffsetY {
            offsetY = maxOffsetY
        }
        
        return .init(x: offsetX, y: offsetY)
    }
    
    func scaleValue(_ t: CGAffineTransform) -> CGFloat { sqrt(t.a * t.a + t.c * t.c) }
}
