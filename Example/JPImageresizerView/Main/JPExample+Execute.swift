//
//  JPExample+Execute.swift
//  JPImageresizerView_Example
//
//  Created by aa on 2023/1/11.
//  Copyright © 2023 ZhouJianPing. All rights reserved.
//

import UIKit
import JPImageresizerView
import JPBasic

extension JPExample.Item {
    func doExecute() {
        Task {
            do {
                try await execute()
            } catch let error as ErrorHUD {
                error.showErrorHUD()
            } catch {
                JPProgressHUD.showError(withStatus: "发生错误：\(error)", userInteractionEnabled: true)
            }
        }
    }
    
    func execute() async throws {
        switch self {
        // MARK: - Section2
        case .cropGifAndAddStroke:
            let gifPath = Bundle.main.path(forResource: Bool.random() ? "Gem" : "Dilraba", ofType: "gif")!
            let gifData = try! Data(contentsOf: URL(fileURLWithPath: gifPath))
            
            let settings = JPImageProcessingSettings()
            settings.outlineStrokeColor = .white
            settings.outlineStrokeWidth = 3
            settings.padding = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
            
            let configure = JPImageresizerConfigure.defaultConfigure(withImageData: gifData)
                .jp_frameType(.classicFrameType)
                .jp_maskImage(UIImage.bundleImage("love.png"))
                .jp_isLoopPlaybackGIF(Bool.random())
                .jp_gifCropSettings(settings)
            let model = JPExample.ConfigureModel(.lightContent, configure)
            await MainActor.run {
                mainVC.pushImageresizerVC(with: model)
            }
            
        case .makeGifAndAddOutlineStroke:
            let gifImage = await UIImage.getCuteOctoGIFImage()
            
            let settings = JPImageProcessingSettings()
            settings.outlineStrokeColor = .white
            settings.outlineStrokeWidth = 3
            settings.padding = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
            
            guard let result = await Self.processImage(gifImage, settings, getTmpCacheURL("gif")) else { return }
            await MainActor.run {
                mainVC.pushPreviewVC([result])
            }
            
        case .singleImageAddOutlineStroke:
            let imageName = ["love.png",
                             "supreme.png",
                             "bazhuawan_icon.png",
                             "bazhuawan_error.png",
                             "bazhuawan_empty.png",
                             "bazhuawan_\(Int.random(in: 1...20)).png",
                             "Girl\(Int.random(in: 1...8)).jpg",
                             "Kobe.jpg",
                             "flowers.jpg"].randomElement()!
            let image = UIImage.bundleImage(imageName)
            
            let scale = await (image.size.width * image.scale) / UIScreen.main.bounds.width
            
            let settings = JPImageProcessingSettings()
            if let last = imageName.components(separatedBy: ".").last, last == "jpg" {
                let borderWidth: CGFloat = scale <= 1 ? 5 : (5 * scale)
                settings.cornerRadius = scale <= 1 ? 30 : (30 * scale)
                settings.borderColor = .systemPink
                settings.borderWidth = borderWidth
            } else {
                let strokeWidth: CGFloat = scale <= 1 ? 2 : (2 * scale)
                settings.outlineStrokeColor = .white
                settings.outlineStrokeWidth = strokeWidth
                settings.padding = UIEdgeInsets(top: strokeWidth, left: strokeWidth, bottom: strokeWidth, right: strokeWidth)
            }
            
            guard let result = await Self.processImage(image, settings, getTmpCacheURL("png")) else { return }
            await MainActor.run {
                mainVC.pushPreviewVC([result])
            }
            
        case .singleImageOnlyDrawOutline:
            let imageName = ["bazhuawan_error.png",
                             "bazhuawan_empty.png",
                             "bazhuawan_\(Int.random(in: 1...20)).png",
                             "love.png",
                             "supreme.png",
                             "bazhuawan_icon.png"].randomElement()!
            let image = UIImage.bundleImage(imageName)
            
            let settings = JPImageProcessingSettings()
            settings.isOnlyDrawOutline = true
            settings.outlineStrokeColor = UIColor(red: CGFloat.random(in: 0...1),
                                                  green: CGFloat.random(in: 0...1),
                                                  blue: CGFloat.random(in: 0...1),
                                                  alpha: 1)
            
            guard let result = await Self.processImage(image, settings, getTmpCacheURL("png")) else { return }
            await MainActor.run {
                mainVC.pushPreviewVC([result])
            }
            
        case .colorMeasurement:
            let imageName = ["colorpicker.png", 
                             "bazhuawan_\(Int.random(in: 1...20)).png",
                             "Girl\(Int.random(in: 1...8)).jpg",
                             "Kobe.jpg",
                             "flowers.jpg"].randomElement()!
            let image = UIImage.bundleImage(imageName)
            await MainActor.run {
                mainVC.pushColorMeasurementVC(image)
            }
            
        // MARK: - Section3
        case .replaceFace:
            await MainActor.run {
                mainVC.pushChooseFaceVC()
            }
            
        case .girlsGIF:
            let girlsImg = await UIImage.getGirlsGIFImage()
            let configure = JPImageresizerConfigure.defaultConfigure(with: girlsImg).jp_isLoopPlaybackGIF(true)
            let model = JPExample.ConfigureModel(.lightContent, configure)
            await MainActor.run {
                mainVC.pushImageresizerVC(with: model)
            }
            
        case .compatibleSwift:
            await MainActor.run {
                mainVC.pushCropVC(isJPCroper: false)
            }
            
        case .compatibleSwiftUI:
            await MainActor.run {
                mainVC.pushOneDayCropVC()
            }
            
        case .JPCroper:
            await MainActor.run {
                mainVC.pushCropVC(isJPCroper: true)
            }
            
        // MARK: - Section0 & Section1
        default:
            guard let model = try await JPExample.ConfigureModel.build(with: self) else { return }
            await MainActor.run {
                mainVC.pushImageresizerVC(with: model)
            }
        }
    }
}

extension JPExample.Item {
    func getTmpCacheURL(_ pathExtension: String) -> URL {
        let cachePath = NSTemporaryDirectory() + "\(Int(Date().timeIntervalSince1970))" + "." + pathExtension
        return URL(fileURLWithPath: cachePath)
    }
    
    static func processImage(_ image: UIImage,
                             _ settings: JPImageProcessingSettings?,
                             _ cacheURL: URL?) async -> JPImageresizerResult? {
        JPProgressHUD.show()
        return await withCheckedContinuation { (continuation: CheckedContinuation<JPImageresizerResult?, Never>) in
            JPImageresizerTool.processImage(with: image, settings: settings, cacheURL: cacheURL) { kURL, reason in
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
