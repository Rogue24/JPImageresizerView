//
//  JPExample.ConfigureModel.swift
//  JPImageresizerView_Example
//
//  Created by aa on 2022/12/27.
//  Copyright © 2022 ZhouJianPing. All rights reserved.
//

extension JPExample {
    class ConfigureModel: NSObject {
        let statusBarStyle: UIStatusBarStyle
        let configure: JPImageresizerConfigure
        
        required init(_ statusBarStyle: UIStatusBarStyle, _ configure: JPImageresizerConfigure) {
            self.statusBarStyle = statusBarStyle
            self.configure = configure
        }
    }
}

extension JPExample.ConfigureModel {
    class func build(with item: JPExample.Item) async throws -> Self? {
        switch item {
        // MARK: - Section0
        case .`default`:
            let configure = JPImageresizerConfigure.defaultConfigure(with: .randomLocalImage)
            return .init(.lightContent, configure)
            
        case .darkBlur:
            let configure = JPImageresizerConfigure.darkBlurMaskTypeConfigure(with: .randomLocalImage)
            return .init(.lightContent, configure)
            
        case .lightBlur:
            let configure = JPImageresizerConfigure.lightBlurMaskTypeConfigure(with: .randomLocalImage)
            return .init(.darkContent, configure)
            
        case .stretchBorder:
            let configure = JPImageresizerConfigure.lightBlurMaskTypeConfigure(with: .randomLocalImage)
                .jp_strokeColor(UIColor(red: 205.0 / 255.0, green: 107.0 / 255.0, blue: 153.0 / 255.0, alpha: 1))
                .jp_borderImage(UIImage.getStretchBorderImage())
                .jp_borderImageRectInset(UIImage.stretchBorderRectInset)
            return .init(.darkContent, configure)
            
        case .tileBorder:
            let configure = JPImageresizerConfigure.darkBlurMaskTypeConfigure(with: .randomLocalImage)
                .jp_frameType(.classicFrameType)
                .jp_borderImage(UIImage.getTileBorderImage())
                .jp_borderImageRectInset(UIImage.tileBorderRectInset)
            return .init(.lightContent, configure)
            
        case .roundResize:
            let configure = JPImageresizerConfigure.darkBlurMaskTypeConfigure(with: .randomLocalImage)
                .jp_strokeColor(UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1))
                .jp_frameType(.classicFrameType)
                .jp_isClockwiseRotation(true)
                .jp_animationCurve(.easeOut)
                .jp_isRoundResize(true)
                .jp_isArbitrarily(false)
            return .init(.lightContent, configure)
            
        case .mask:
            let configure = JPImageresizerConfigure.darkBlurMaskTypeConfigure(with: .randomLocalImage)
                .jp_frameType(.classicFrameType)
                .jp_maskImage(UIImage(named: "love.png"))
                .jp_isArbitrarily(false)
            return .init(.lightContent, configure)
            
        // MARK: - Section1
        case .localGIF:
            let gifPath = Bundle.main.path(forResource: Bool.random() ? "Gem" : "Dilraba", ofType: "gif")!
            let gifData = try! Data(contentsOf: URL(fileURLWithPath: gifPath))
            let configure = JPImageresizerConfigure.defaultConfigure(withImageData: gifData)
                .jp_frameType(.classicFrameType)
                .jp_isLoopPlaybackGIF(Bool.random())
            return .init(.lightContent, configure)
            
        case .localVideo:
            let videoPath = Bundle.main.path(forResource: "yaorenmao", ofType: "mov")!
            let videoURL = URL(fileURLWithPath: videoPath)
            let configure = JPImageresizerConfigure
                .lightBlurMaskTypeConfigure(withVideoURL: videoURL,
                                            make: nil,
                                            fixErrorBlock: nil,
                                            fixStart: nil,
                                            fixProgressBlock: nil)
                .jp_borderImage(UIImage.getStretchBorderImage())
                .jp_borderImageRectInset(UIImage.stretchBorderRectInset)
            return .init(.darkContent, configure)
            
        case .album:
            let object: AlbumObject = try await ImagePicker.openAlbum()
            
            let configure: JPImageresizerConfigure
            if let imageData = object.imageData {
                configure = .defaultConfigure(withImageData: imageData)
            } else if let videoURL = object.videoURL {
                configure = try await JPExample.videoFixOrientation(videoURL)
            } else {
                throw JPExampleError.pickNullObject
            }
            
            return .init(.lightContent, configure)
            
        // MARK: - Section2
        default:
            return nil
        }
    }
}
