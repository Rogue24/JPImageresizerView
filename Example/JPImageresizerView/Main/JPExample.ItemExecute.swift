//
//  JPExample.ItemExecute.swift
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
