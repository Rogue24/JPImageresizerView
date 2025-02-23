//
//  UIImage+.swift
//  JPImageresizerView_Example
//
//  Created by aa on 2022/12/26.
//  Copyright © 2022 ZhouJianPing. All rights reserved.
//

import UIKit
import CoreImage
import Vision

extension UIImage {
    static func bundleImage(_ name: String, ofType ext: String? = nil) -> UIImage {
        UIImage(contentsOfFile: Bundle.main.path(forResource: name, ofType: ext)!)!
    }
}

extension UIImage {
    // MARK: - Stretch border
    @objc static var stretchBorderRectInset: CGPoint { CGPoint(x: -2, y: -2) }
    @objc static func getStretchBorderImage() -> UIImage {
        let image = UIImage(named: "real_line")!
        var cgImage = image.cgImage!
        // 裁剪掉上下多余的空白部分
        let inset = 1.5 * image.scale
        cgImage = cgImage.cropping(to: CGRect(x: 0, y: inset, width: CGFloat(cgImage.width), height: CGFloat(cgImage.height) - 2 * inset))!
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation).resizableImage(withCapInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), resizingMode: .stretch)
    }
    
    // MARK: - Tile border
    @objc static var tileBorderRectInset: CGPoint { CGPoint(x: -1.75, y: -1.75) }
    @objc static func getTileBorderImage() -> UIImage {
        UIImage(named: "dotted_line")!.resizableImage(withCapInsets: UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14), resizingMode: .tile)
    }
}

extension UIImage {
    @objc static var randomGirlImage: UIImage {
        let girlCount = 8
        let index = Int.random(in: 1...girlCount)
        let imageName = "Girl\(index).jpg"
        return bundleImage(imageName, ofType: nil)
    }
    
    @objc static var randomLocalImage: UIImage {
        let girlCount = 8
        let index = Int.random(in: 1...(girlCount + 2))
        let imageName: String
        switch index {
        case 1...girlCount:
            imageName = "Girl\(index).jpg"
        case (girlCount + 1):
            imageName = "Kobe.jpg"
        default:
            imageName = "flowers.jpg"
        }
        return bundleImage(imageName)
    }
    
    private static var cuteOctoGIFImg: UIImage? = nil
    static func getCuteOctoGIFImage() async -> UIImage {
        if let cuteOctoGIFImg = self.cuteOctoGIFImg {
            return cuteOctoGIFImg
        }
        let images = Array(1...20).map { UIImage.bundleImage("bazhuawan_\($0).png") }
        let cuteOctoGIFImg = UIImage.animatedImage(with: images, duration: 1.5)!
        self.cuteOctoGIFImg = cuteOctoGIFImg
        return cuteOctoGIFImg
    }
    
    private static var girlsGIFImg: UIImage? = nil
    static func getGirlsGIFImage() async -> UIImage {
        if let girlsGIFImg = self.girlsGIFImg {
            return girlsGIFImg
        }
        let girlsGIFImg = await createGirlsGIFImage()
        self.girlsGIFImg = girlsGIFImg
        return girlsGIFImg
    }
    
    private static func createGirlsGIFImage() async -> UIImage {
        let girlCount = 8
        let size = CGSize(width: 500, height: 500)
        var images: [UIImage] = []
        
        var bitmapRawValue = CGBitmapInfo.byteOrder32Little.rawValue
        bitmapRawValue += CGImageAlphaInfo.noneSkipFirst.rawValue
        
        let context = CGContext(data: nil,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: 0,
                                space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: bitmapRawValue)!
        context.setShouldAntialias(true)
        context.setAllowsAntialiasing(true)
        context.interpolationQuality = .high
        
        for i in 1...girlCount {
            let imageName = "Girl\(i).jpg"
            let image = bundleImage(imageName, ofType: nil)
            
            context.saveGState()
            
            let cgImage = image.cgImage!
            var width: CGFloat = 0
            var height: CGFloat = 0
            if image.size.width >= image.size.height {
                width = size.width
                height = width * (image.size.height / image.size.width)
            } else {
                height = size.height
                width = height * (image.size.width / image.size.height)
            }
            let x = (size.width - width) * 0.5
            let y = (size.height - height) * 0.5
            
            context.draw(cgImage, in: CGRect(x: x, y: y, width: width, height: height))
            let newCgImage = context.makeImage()!
            let newImage = UIImage(cgImage: newCgImage)
            images.append(newImage)
            
            context.restoreGState()
            context.clear(CGRect(origin: .zero, size: size))
        }
        
        return UIImage.animatedImage(with: images, duration: 4)!
    }
}

// MARK: - Detect Faces
extension UIImage {
    /// CoreImage方式
    static func detectFaces(in image: UIImage?) async -> [CGRect] {
        guard let image, let ciImage = CIImage(image: image),
              let detector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyLow]) else {
            print("not found the faces.")
            return []
        }
        
        let features = detector.features(in: ciImage)
        let size = image.size
        return features.map {
            let faceBounds = $0.bounds
            // 转换成以【原尺寸的百分比形式】表示，取值为0~1。
            return CGRect(x: faceBounds.minX / size.width,
                          // 图像的原点在【左下角】，而手机屏幕是在【左上角】，所以要把Y轴颠倒
                          y: (size.height - faceBounds.minY - faceBounds.height) / size.height,
                          width: faceBounds.width / size.width,
                          height: faceBounds.height / size.height)
        }
    }
    
    /// Vision方式
    /// 📢📢📢：模拟机无法使用`Vision`，只能真机使用
    static func detectFacesWithVision(in image: UIImage?) async -> [CGRect] {
        await withCheckedContinuation { (continuation: CheckedContinuation<[CGRect], Never>) in
            guard let image, let ciImage = CIImage(image: image) else {
                continuation.resume(returning: [])
                return
            }
            
            let request = VNDetectFaceRectanglesRequest { (request, error) in
                if let error {
                    print("Error detecting faces: \(error)")
                    continuation.resume(returning: [])
                    return
                }
                
                let results = request.results as? [VNFaceObservation] ?? []
                let allScaledBounds: [CGRect] = results.map {
                    // boundingBox已经是以【原尺寸的百分比形式】表示的，取值为0~1。
                    var faceBounds = $0.boundingBox
                    // 图像的原点在【左下角】，而手机屏幕是在【左上角】，所以要把Y轴颠倒
                    faceBounds.origin.y = 1 - faceBounds.minY - faceBounds.height
                    return faceBounds
                }
                
                continuation.resume(returning: allScaledBounds)
            }
            
            let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                print("Request Error: \(error)")
            }
        }
    }
}
