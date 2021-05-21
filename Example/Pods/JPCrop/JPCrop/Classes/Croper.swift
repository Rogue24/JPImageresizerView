//
//  Croper.swift
//  JPCrop_Example
//
//  Created by 周健平 on 2020/12/21.
//

import UIKit

public class Croper: UIView {
    
    // MARK:- 默认初始值
    /// 裁剪宽高比的范围（默认 最小 3 : 4 ~ 2 : 1）
    public static var cropWHRatioRange: ClosedRange<CGFloat> = (3.0 / 4.0)...2
    /// 旋转的范围（默认 -45° ~ 45°）
    public static var radianRange: ClosedRange = (-CGFloat.pi * 0.25)...(CGFloat.pi * 0.25)
    /// 裁剪区域的边距
    public static var margin: CGFloat = 12
    /// 动画时间
    public static var animDuration: TimeInterval = 0.25
    
    // MARK:- 公开可设置的存储属性
    /// 裁剪图片
    public let image: UIImage
    /// 图片的宽高比（当 cropWHRatio = 0 时取该值）
    public let imageWHRatio: CGFloat
    /// 是否为横幅图片
    public var isLandscapeImage: Bool { imageWHRatio > 1 }
    
    /// 裁剪宽高比
    public private(set) var cropWHRatio: CGFloat = 0
    /// 裁剪框的frame
    public private(set) var cropFrame: CGRect = .zero
    
    /// 旋转角度（弧度）
    public private(set) var radian: CGFloat = 0
    
    /// 类型：网格数 - (垂直方向数量, 水平方向数量)
    public typealias GridCount = (verCount: Int, horCount: Int)
    /// 闲置时的网格数
    public var idleGridCount: GridCount = (0, 0)
    /// 旋转时的网格数
    public var rotateGridCount: GridCount = (0, 0)
    
    /// 当设置裁剪宽高比时超出可设置范围时的回调
    public var cropWHRatioRangeOverstep: ((_ isUpper: Bool, _ bound: CGFloat) -> ())?
    
    // MARK:- 私有的存储属性
    var minHorMargin: CGFloat = 0
    var minVerMargin: CGFloat = 0
    
    let scrollView = UIScrollView()
    let imageView = UIImageView()
    let shadeLayer = CAShapeLayer()
    let borderLayer = CAShapeLayer()
    let idleGridLayer = CAShapeLayer()
    let rotateGridLayer = CAShapeLayer()
    
    // MARK:- 构造器
    public convenience init(frame: CGRect,
                            _ configure: Configure,
                            idleGridCount: GridCount = (3, 3),
                            rotateGridCount: GridCount = (5, 5)) {
        self.init(frame: frame,
                  configure.image,
                  configure.cropWHRatio,
                  configure.radian,
                  configure.zoomScale,
                  configure.contentOffset,
                  idleGridCount,
                  rotateGridCount)
    }
    
    public init(frame: CGRect = UIScreen.main.bounds,
                _ image: UIImage,
                _ cropWHRatio: CGFloat,
                _ radian: CGFloat,
                _ zoomScale: CGFloat? = nil,
                _ contentOffset: CGPoint? = nil,
                _ idleGridCount: GridCount? = nil,
                _ rotateGridCount: GridCount? = nil) {
        self.image = image
        self.imageWHRatio = image.size.width / image.size.height
        
        super.init(frame: frame)
        setupUI()
        
        updateCropWHRatio(cropWHRatio,
                          idleGridCount: idleGridCount,
                          rotateGridCount: rotateGridCount)
        
        updateRadian(radian)
        
        if let scale = zoomScale { scrollView.zoomScale = scale }
        if let offset = contentOffset { scrollView.contentOffset = offset }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK:- API
extension Croper {
    
    // MARK: 获取同步的Configure（当前的裁剪元素、状态）
    /// 获取同步的Configure，可用于保存当前的裁剪状态，下一次打开恢复状态
    public func syncConfigure() -> Configure {
        Configure(image,
                  cropWHRatio: cropWHRatio,
                  radian: radian,
                  zoomScale: scrollView.zoomScale,
                  contentOffset: scrollView.contentOffset)
    }
    
    // MARK: 旋转
    /// 刷新旋转角度（单位：弧度）
    public func updateRadian(_ radian: CGFloat) {
        self.radian = checkRadian(radian)
        
        let factor = fitFactor()
        
        var zoomScale = scrollView.zoomScale
        let minZoomScale = scrollView.minimumZoomScale
        
        let oldScale = scaleValue(scrollView.transform)
        let newScale = factor.scale
        // scrollView 变大/变小多少，zoomScale 则变小/变大多少（反向缩放）
        // 否则在旋转过程中，裁剪区域在图片上即便有足够空间进行旋转（不超出图片区域），也会跟随 scrollView 变大变小
        zoomScale *= oldScale / newScale
        if zoomScale <= minZoomScale { zoomScale = minZoomScale }
        
        scrollView.transform = factor.transform
        scrollView.contentInset = factor.contentInset
        scrollView.zoomScale = zoomScale
    }
    
    // MARK: 切换裁剪框的宽高比
    /// 刷新裁剪比例（idleGridCount：闲置时的网格数；rotateGridCount：旋转时的网格数）
    public func updateCropWHRatio(_ cropWHRatio: CGFloat,
                                  idleGridCount: GridCount? = nil,
                                  rotateGridCount: GridCount? = nil,
                                  animated: Bool = false) {
        self.cropWHRatio = checkCropWHRatio(cropWHRatio, isCallBack: true)
        
        let oldCropFrame = cropFrame
        cropFrame = fitCropFrame()
        minHorMargin = (bounds.width - cropFrame.width) * 0.5
        minVerMargin = (bounds.height - cropFrame.height) * 0.5
        
        // 1.算出改变后的UI数值，和改变前后的差值
        
        let factor = fitFactor() // 获取 scrollView 最合适（不会超出） cropFrame 和 radian 的 transform 和 contentInset
        let imageBoundsSize = fitImageSize() // 获取 imageView 适配了 cropFrame 的原始 Size
        
        let zoomScale: CGFloat
        let xScale: CGFloat
        let yScale: CGFloat
        if imageView.bounds.width > 0 {
            let convertOffset = borderLayer.convert(.init(x: oldCropFrame.midX, y: oldCropFrame.midY), to: imageView.layer)
            xScale = convertOffset.x / imageView.bounds.width
            yScale = convertOffset.y / imageView.bounds.height
            
            let diffScale = scaleValue(scrollView.transform) / scaleValue(factor.transform)
            zoomScale = imageView.frame.width / imageBoundsSize.width * diffScale
        } else {
            xScale = 0.5
            yScale = 0.5
            zoomScale = 1
        }
        
        let imageFrameSize = CGSize(width: imageBoundsSize.width * zoomScale, height: imageBoundsSize.height * zoomScale)
        
        // 2.立马设置 scrollView 改变后的 transform，和其他的一些差值，让 scrollView 形变后相对于之前的 UI 状态“看上去”没有变化一样
        
        imageView.bounds = .init(origin: .zero, size: imageBoundsSize)
        
        scrollView.transform = factor.transform
        if zoomScale < 1 { scrollView.minimumZoomScale = zoomScale }
        scrollView.zoomScale = zoomScale
        scrollView.contentSize = imageFrameSize
        
        imageView.frame = .init(origin: .zero, size: imageFrameSize)
        
        scrollView.contentOffset = fitOffset(xScale, yScale, contentSize: imageFrameSize)
        
        // 3.再通过动画适配当前窗口，也就是把差值还原回去
        
        let updateScrollView = {
            if zoomScale < 1 {
                self.scrollView.minimumZoomScale = 1
                self.scrollView.zoomScale = 1
            }
            self.scrollView.contentInset = factor.contentInset
            self.scrollView.contentOffset = self.fitOffset(xScale, yScale, contentInset: factor.contentInset)
        }
        
        // 边框路径
        let borderPath = UIBezierPath(rect: cropFrame)
        // 阴影路径
        let shadePath = UIBezierPath(rect: bounds)
        shadePath.append(borderPath)
        // 闲置网格路径
        if let obIdleGridCount = idleGridCount { self.idleGridCount = obIdleGridCount }
        let idleGridPath = buildGridPath(self.idleGridCount)
        // 旋转网格路径
        if let obRotateGridCount = rotateGridCount { self.rotateGridCount = obRotateGridCount }
        let rotateGridPath = buildGridPath(self.rotateGridCount)
        
        if animated {
            UIView.animate(withDuration: Self.animDuration, delay: 0, options: .curveEaseOut, animations: updateScrollView, completion: nil)
            buildAnimation(addTo: borderLayer, "path", borderPath.cgPath, Self.animDuration)
            buildAnimation(addTo: shadeLayer, "path", shadePath.cgPath, Self.animDuration)
            buildAnimation(addTo: idleGridLayer, "path", idleGridPath.cgPath, Self.animDuration)
            buildAnimation(addTo: rotateGridLayer, "path", rotateGridPath.cgPath, Self.animDuration)
        } else {
            updateScrollView()
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        borderLayer.path = borderPath.cgPath
        shadeLayer.path = shadePath.cgPath
        idleGridLayer.path = idleGridPath.cgPath
        rotateGridLayer.path = rotateGridPath.cgPath
        CATransaction.commit()
    }
    
    // MARK: 显示旋转网格
    /// 显示旋转时的网格数
    public func showRotateGrid(animated: Bool = false) {
        updateGrid(0, 1, animated: animated)
    }
    
    // MARK: 隐藏旋转网格
    /// 隐藏旋转时的网格数
    public func hideRotateGrid(animated: Bool = false) {
        updateGrid(1, 0, animated: animated)
    }
    
    private func updateGrid(_ idleGridAlpha: Float, _ rotateGridAlpha: Float, animated: Bool = false) {
        if animated {
            buildAnimation(addTo: idleGridLayer, "opacity", idleGridAlpha, 0.12, timingFunctionName: .easeIn)
            buildAnimation(addTo: rotateGridLayer, "opacity", rotateGridAlpha, 0.12, timingFunctionName: .easeIn)
        }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        idleGridLayer.opacity = idleGridAlpha
        rotateGridLayer.opacity = rotateGridAlpha
        CATransaction.commit()
    }
    
    // MARK: 恢复
    /// 恢复 --> 角度0 + 缩放比例1 + 中心点
    public func recover(animated: Bool = false) {
        radian = 0
        let factor = fitFactor()
        let updateScrollView = {
            self.scrollView.zoomScale = 1
            self.scrollView.transform = factor.transform
            self.scrollView.contentInset = factor.contentInset
            self.scrollView.contentOffset = self.fitOffset(0.5, 0.5, contentInset: factor.contentInset)
        }
        if animated {
            UIView.animate(withDuration: Self.animDuration, delay: 0, options: .curveEaseOut, animations: updateScrollView, completion: nil)
        } else {
            updateScrollView()
        }
    }
    
    // MARK: 同步裁剪
    /// 裁剪：compressScale：压缩比例，默认为1，即原图尺寸
    public func crop(_ compressScale: CGFloat = 1) -> UIImage? {
        guard let imageRef = image.cgImage else { return nil }
        
        let convertTranslate = borderLayer.convert(.init(x: cropFrame.origin.x, y: cropFrame.maxY), to: imageView.layer)
        
        return Self.crop(compressScale,
                         imageRef,
                         cropWHRatio > 0 ? cropWHRatio : checkCropWHRatio(imageWHRatio),
                         scaleValue(scrollView.transform) * scrollView.zoomScale,
                         convertTranslate,
                         radian,
                         imageView.bounds.height)
    }
    
    // MARK: 异步裁剪
    /// 裁剪：compressScale：压缩比例，默认为1，即原图尺寸
    public func asyncCrop(_ compressScale: CGFloat = 1, _ cropDone: @escaping (UIImage?) -> ()) {
        guard let imageRef = image.cgImage else {
            cropDone(nil)
            return
        }
        
        let cropWHRatio = self.cropWHRatio > 0 ? self.cropWHRatio : checkCropWHRatio(imageWHRatio)
        let scale = scaleValue(scrollView.transform) * scrollView.zoomScale
        let convertTranslate = borderLayer.convert(.init(x: cropFrame.origin.x, y: cropFrame.maxY), to: imageView.layer)
        let radian = self.radian
        let height = imageView.bounds.height
        
        DispatchQueue.global().async {
            let result = Self.crop(compressScale,
                                   imageRef,
                                   cropWHRatio,
                                   scale,
                                   convertTranslate,
                                   radian,
                                   height)
            DispatchQueue.main.async { cropDone(result) }
        }
    }
}
