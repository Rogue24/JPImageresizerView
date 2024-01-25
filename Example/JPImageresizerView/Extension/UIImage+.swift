//
//  UIImage+.swift
//  JPImageresizerView_Example
//
//  Created by aa on 2022/12/26.
//  Copyright © 2022 ZhouJianPing. All rights reserved.
//

import UIKit

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
        return bundleImage(imageName, ofType: nil)
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
