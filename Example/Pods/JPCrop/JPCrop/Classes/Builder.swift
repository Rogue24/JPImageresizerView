//
//  Builder.swift
//  JPCrop_Example
//
//  Created by Rogue24 on 2020/12/23.
//

import UIKit

extension Croper {
    func setupUI() {
        clipsToBounds = true
        backgroundColor = .black
        
        scrollView.delegate = self
        scrollView.clipsToBounds = false
        if #available(iOS 11.0, *) { scrollView.contentInsetAdjustmentBehavior = .never }
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 10
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.frame = bounds
        addSubview(scrollView)
        
        imageView.image = image
        scrollView.addSubview(imageView)
        
        shadeLayer.frame = bounds
        shadeLayer.fillColor = UIColor(white: 0, alpha: 0.5).cgColor
        shadeLayer.fillRule = .evenOdd
        shadeLayer.strokeColor = UIColor.clear.cgColor
        shadeLayer.lineWidth = 0
        layer.addSublayer(shadeLayer)
        
        idleGridLayer.frame = bounds
        idleGridLayer.fillColor = UIColor.clear.cgColor
        idleGridLayer.strokeColor = UIColor(white: 1, alpha: 0.8).cgColor
        idleGridLayer.lineWidth = 0.35
        layer.addSublayer(idleGridLayer)
        
        rotateGridLayer.frame = bounds
        rotateGridLayer.fillColor = UIColor.clear.cgColor
        rotateGridLayer.strokeColor = UIColor(white: 1, alpha: 0.8).cgColor
        rotateGridLayer.lineWidth = 0.35
        rotateGridLayer.opacity = 0
        layer.addSublayer(rotateGridLayer)
        
        borderLayer.frame = bounds
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor.white.cgColor
        borderLayer.lineWidth = 1
        layer.addSublayer(borderLayer)
    }
    
    func buildGridPath(_ gridCount: (verCount: Int, horCount: Int)) -> UIBezierPath {
        let gridPath = UIBezierPath()
        guard gridCount.verCount > 1, gridCount.horCount > 1 else { return gridPath }
        let verSpace = cropFrame.height / CGFloat(gridCount.verCount)
        let horSpace = cropFrame.width / CGFloat(gridCount.horCount)
        for i in 1..<gridCount.verCount {
            let px = cropFrame.origin.x
            let py = cropFrame.origin.y + verSpace * CGFloat(i)
            gridPath.move(to: .init(x: px, y: py))
            gridPath.addLine(to: .init(x: px + cropFrame.width, y: py))
        }
        for i in 1..<gridCount.horCount {
            let px = cropFrame.origin.x + horSpace * CGFloat(i)
            let py = cropFrame.origin.y
            gridPath.move(to: .init(x: px, y: py))
            gridPath.addLine(to: .init(x: px, y: py + cropFrame.height))
        }
        return gridPath
    }
    
    func buildAnimation<T>(addTo layer: CALayer, _ keyPath: String, _ toValue: T, _ duration: TimeInterval, timingFunctionName: CAMediaTimingFunctionName = .easeOut) {
        let anim = CABasicAnimation(keyPath: keyPath)
        anim.fromValue = layer.value(forKeyPath: keyPath)
        anim.toValue = toValue
        anim.fillMode = .backwards
        anim.duration = duration
        anim.timingFunction = .init(name: timingFunctionName)
        layer.add(anim, forKey: keyPath)
    }
}

extension Croper: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView }
}

extension Croper {
    static func crop(_ compressScale: CGFloat,
                     _ imageRef: CGImage,
                     _ cropWHRatio: CGFloat,
                     _ scale: CGFloat,
                     _ convertTranslate: CGPoint,
                     _ radian: CGFloat,
                     _ imageBoundsHeight: CGFloat) -> UIImage? {
        
        let width = CGFloat(imageRef.width) * compressScale
        let height = CGFloat(imageRef.height) * compressScale
        
        // 获取裁剪尺寸和裁剪区域
        var rendSize: CGSize
        if width > height {
            rendSize = .init(width: height * cropWHRatio, height: height)
            if rendSize.width > width {
                rendSize = .init(width: width, height: width / cropWHRatio)
            }
        } else {
            rendSize = .init(width: width, height: width / cropWHRatio)
            if rendSize.height > height {
                rendSize = .init(width: height * cropWHRatio, height: height)
            }
        }
        
        var bitmapRawValue = CGBitmapInfo.byteOrder32Little.rawValue
        let alphaInfo = imageRef.alphaInfo
        if alphaInfo == .premultipliedLast ||
            alphaInfo == .premultipliedFirst ||
            alphaInfo == .last ||
            alphaInfo == .first {
            bitmapRawValue += CGImageAlphaInfo.premultipliedFirst.rawValue
        } else {
            bitmapRawValue += CGImageAlphaInfo.noneSkipFirst.rawValue
        }
        
        guard let context = CGContext(data: nil,
                                      width: Int(rendSize.width),
                                      height: Int(rendSize.height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: 0,
                                      space: CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: bitmapRawValue) else { return nil }
        context.setShouldAntialias(true)
        context.setAllowsAntialiasing(true)
        context.interpolationQuality = .high
        
        let iScale = CGFloat(imageRef.height) / (imageBoundsHeight * scale)
        var translate = convertTranslate
        translate.y = imageBoundsHeight - translate.y // 左下点与底部的距离
        translate.x *= -1 * scale * iScale
        translate.y *= -1 * scale * iScale
        
        let transform = CGAffineTransform(scaleX: scale, y: scale).rotated(by: -radian).translatedBy(x: translate.x, y: translate.y)
        context.concatenate(transform)
        
        context.draw(imageRef, in: .init(origin: .zero, size: .init(width: width, height: height)))
        
        guard let newImageRef = context.makeImage() else { return nil }
        return UIImage(cgImage: newImageRef)
    }
}
