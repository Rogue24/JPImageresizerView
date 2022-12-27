//
//  JPExample.ItemExecute.swift
//  JPImageresizerView_Example
//
//  Created by aa on 2022/12/12.
//  Copyright © 2022 ZhouJianPing. All rights reserved.
//

extension JPExample.Section0 {
    func execute() async throws {
        let model = JPExample.ConfigureModel.build(with: self)
        await MainActor.run {
            mainVC.pushImageresizerVC(with: model)
        }
    }
}

extension JPExample.Section1 {
    func execute() async throws {
        let model = try await JPExample.ConfigureModel.build(with: self)
        await MainActor.run {
            mainVC.pushImageresizerVC(with: model)
        }
    }
}

extension JPExample.Section2 {
    private static var girlsImg: UIImage? = nil
    private static func getGirlsImg() async -> UIImage {
        if let girlsImg = self.girlsImg {
            return girlsImg
        }
        let girlsImg = await UIImage.createGirlsGIFImage()
        self.girlsImg = girlsImg
        return girlsImg
    }
    
    func execute() async throws {
        switch self {
        case .replaceFace:
            await MainActor.run {
                mainVC.pushChooseFaceVC()
            }
            
        case .girlsGIF:
            let girlsImg = await Self.getGirlsImg()
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
        }
    }
}

