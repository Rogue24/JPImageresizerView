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
            settings.outlineStrokeWidth = 2
            settings.padding = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
            
            let configure = JPImageresizerConfigure.defaultConfigure(withImageData: gifData)
                .jp_frameType(.classicFrameType)
                .jp_maskImage(UIImage(named: "love.png"))
                .jp_isLoopPlaybackGIF(Bool.random())
                .jp_gifCropSettings(settings)
            let model = JPExample.ConfigureModel(.lightContent, configure)
            await MainActor.run {
                mainVC.pushImageresizerVC(with: model)
            }
            
        case .makeGifAndAddStroke:
            let gifImgs = Array(1...20).map {
                UIImage(named: "bazhuawan_\($0).png")!
            }
            let gifImage = UIImage.animatedImage(with: gifImgs, duration: 1.5)!
            
            let settings = JPImageProcessingSettings()
            settings.outlineStrokeColor = .white
            settings.outlineStrokeWidth = 2
            settings.padding = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
            
            let cachePath = NSTemporaryDirectory() + "\(Int(Date().timeIntervalSince1970)).gif"
            let cacheURL = URL(fileURLWithPath: cachePath)
            
            guard let result = await Self.processImage(gifImage, settings, cacheURL) else { return }
            await MainActor.run {
                mainVC.pushPreviewVC([result])
            }
            
            
        case .singleImageAddStroke:
            let imageName = ["love.png", "supreme.png", "bazhuawan_icon.png", "bazhuawan_error.png", "bazhuawan_empty.png"].randomElement()!
//            let imageName = "Flowers.jpg"
//            let imageName = "bazhuawan_empty.png"
            let image = UIImage(named: imageName)!
            
            let scale = await (image.size.width * image.scale) / UIScreen.main.bounds.width
            let cornerRadius: CGFloat = scale <= 1 ? 30 : (30 * scale)
            let borderWidth: CGFloat = scale <= 1 ? 5 : (5 * scale)
            let strokeWidth: CGFloat = scale <= 1 ? 2 : (2 * scale)
            
            let settings = JPImageProcessingSettings()
            settings.backgroundColor = .black
            settings.cornerRadius = cornerRadius
            settings.borderColor = .red
            settings.borderWidth = borderWidth
            settings.outlineStrokeColor = .white
            settings.outlineStrokeWidth = strokeWidth
            settings.padding = UIEdgeInsets(top: strokeWidth, left: strokeWidth, bottom: strokeWidth, right: strokeWidth)
            settings.isOnlyDrawOutline = Bool.random()
            
            let cachePath = NSTemporaryDirectory() + "\(Int(Date().timeIntervalSince1970)).png"
            let cacheURL = URL(fileURLWithPath: cachePath)
            
            guard let result = await Self.processImage(image, settings, cacheURL) else { return }
            await MainActor.run {
                mainVC.pushPreviewVC([result])
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
