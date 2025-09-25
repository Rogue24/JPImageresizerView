//
//  UIAlertController+JPImageresizer.swift
//  JPImageresizerView_Example
//
//  Created by aa on 2023/7/31.
//  Copyright © 2023 ZhouJianPing. All rights reserved.
//

import UIKit
import JPBasic
import JPImageresizerView

@objc
extension UIAlertController {
    static func changeResizeWHScale(_ handler: @escaping (_ resizeWHScale: CGFloat) -> Void, isArbitrarily: Bool, isRoundResize: Bool, fromVC: UIViewController? = nil) {
        UIAlertController
            .build(.actionSheet)
            .addAction("使用\(isArbitrarily ? "固定比例" : "任意比例")") { handler(-1) }
            .addAction("\(isRoundResize ? "取消" : "")圆切") { handler(0) }
            .addAction("1 : 1") { handler(1) }
            .addAction("2 : 3") { handler(2.0 / 3.0) }
            .addAction("3 : 5") { handler(3.0 / 5.0) }
            .addAction("9 : 16") { handler(9.0 / 16.0) }
            .addAction("7 : 3") { handler(7.0 / 3.0) }
            .addAction("16 : 9") { handler(16.0 / 9.0) }
            .addCancel()
            .present(from: fromVC ?? rootVC)
    }
    
    static func changeEffect(_ handler: @escaping (_ effect: UIVisualEffect?) -> Void, fromVC: UIViewController? = nil) {
        let alertCtr = UIAlertController
            .build(.actionSheet)
            .addDestructive("移除模糊效果") { handler(nil) }
        if #available(iOS 26.0, *) {
            alertCtr
                .addAction("Glass Regular") { handler(UIGlassEffect(style: .regular)) }
                .addAction("Glass Clear") { handler(UIGlassEffect(style: .clear)) }
        }
        alertCtr
            .addAction("ExtraLight") { handler(UIBlurEffect(style: .extraLight)) }
            .addAction("Light") { handler(UIBlurEffect(style: .light)) }
            .addAction("Dark") { handler(UIBlurEffect(style: .dark)) }
            .addAction("Regular") { handler(UIBlurEffect(style: .regular)) }
            .addAction("Prominent") { handler(UIBlurEffect(style: .prominent)) }
            .addAction("SystemUltraThinMaterial") { handler(UIBlurEffect(style: .systemUltraThinMaterial)) }
            .addAction("SystemThinMaterial") { handler(UIBlurEffect(style: .systemThinMaterial)) }
            .addAction("SystemMaterial") { handler(UIBlurEffect(style: .systemMaterial)) }
            .addAction("SystemThickMaterial") { handler(UIBlurEffect(style: .systemThickMaterial)) }
            .addAction("SystemChromeMaterial") { handler(UIBlurEffect(style: .systemChromeMaterial)) }
            .addAction("SystemUltraThinMaterialLight") { handler(UIBlurEffect(style: .systemUltraThinMaterialLight)) }
            .addAction("SystemThinMaterialLight") { handler(UIBlurEffect(style: .systemThinMaterialLight)) }
            .addAction("SystemMaterialLight") { handler(UIBlurEffect(style: .systemMaterialLight)) }
            .addAction("SystemThickMaterialLight") { handler(UIBlurEffect(style: .systemThickMaterialLight)) }
            .addAction("SystemChromeMaterialLight") { handler(UIBlurEffect(style: .systemChromeMaterialLight)) }
            .addAction("SystemUltraThinMaterialDark") { handler(UIBlurEffect(style: .systemUltraThinMaterialDark)) }
            .addAction("SystemThinMaterialDark") { handler(UIBlurEffect(style: .systemThinMaterialDark)) }
            .addAction("SystemMaterialDark") { handler(UIBlurEffect(style: .systemMaterialDark)) }
            .addAction("SystemThickMaterialDark") { handler(UIBlurEffect(style: .systemThickMaterialDark)) }
            .addAction("SystemChromeMaterialDark") { handler(UIBlurEffect(style: .systemChromeMaterialDark)) }
            .addCancel()
            .present(from: fromVC ?? rootVC)
    }
    
    static func replaceObj(_ handler: @escaping (_ image: UIImage?, _ imageData: Data?, _ videoURL: URL?) -> Void, fromVC: UIViewController? = nil) {
        UIAlertController
            .build(.actionSheet)
            .addAction("Girl") { handler(UIImage.randomGirlImage, nil, nil) }
            .addAction("Kobe") { handler(UIImage.bundleImage("Kobe.jpg"), nil, nil) }
            .addAction("Flowers") { handler(UIImage.bundleImage("flowers.jpg"), nil, nil) }
            .addAction("咬人猫舞蹈节选（视频）") { handler(nil, nil, URL(fileURLWithPath: Bundle.main.path(forResource: "yaorenmao", ofType: "mov")!)) }
            .addAction("See the sea（视频）") { handler(nil, nil, URL(fileURLWithPath: Bundle.main.path(forResource: "seeTheSea", ofType: "mp4")!)) }
            .addAction("Gem（GIF）") { handler(nil, try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "Gem", ofType: "gif")!)), nil) }
            .addAction("Dilraba（GIF）") { handler(nil, try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "Dilraba", ofType: "gif")!)), nil) }
            .addAction("八爪丸（GIF）") {
                Task {
                    let gifImage = await UIImage.getCuteOctoGIFImage()
                    handler(gifImage, nil, nil)
                }
            }
            .addAction("系统相册") {
                ImagePicker.openAlbumForObject { result in
                    switch result {
                    case let .success(obj):
                        handler(nil, obj.imageData, obj.videoURL)
                    case .failure:
                        break
                    }
                }
            }
            .addCancel()
            .present(from: fromVC ?? rootVC)
    }
    
    static func rotation(_ handler1: @escaping (_ isClockwise: Bool) -> Void, toDirection handler2: @escaping (_ direction: JPImageresizerRotationDirection) -> Void, fromVC: UIViewController? = nil) {
        UIAlertController
            .build(.actionSheet)
            .addAction("顺时针旋转 ⤵️") { handler1(true) }
            .addAction("逆时针旋转 ⤴️") { handler1(false) }
            .addAction("垂直向上 ⬆️") { handler2(.verticalUpDirection) }
            .addAction("水平向右 ➡️") { handler2(.horizontalRightDirection) }
            .addAction("垂直向下 ⬇️") { handler2(.verticalDownDirection) }
            .addAction("水平向左 ⬅️") { handler2(.horizontalLeftDirection) }
            .addCancel()
            .present(from: fromVC ?? rootVC)
    }
    
    static func changeMaskImage(_ handler1: @escaping (_ maskImage: UIImage?) -> Void,
                                gotoMaskImageList handler2: @escaping () -> Void,
                                isCanRemoveMaskImage: Bool,
                                fromVC: UIViewController? = nil) {
        let alertCtr = UIAlertController.build(.actionSheet)
            .addAction("蒙版素材列表") { handler2() }
            .addAction("love") { handler1(UIImage.bundleImage("love.png")) }
            .addAction("Supreme") { handler1(UIImage.bundleImage("supreme.png")) }
            .addAction("Face Mask") { handler1(UIImage.bundleImage("DanielWuFace.png")) }
        if isCanRemoveMaskImage {
            alertCtr.addDestructive("移除蒙版") { handler1(nil) }
        }
        alertCtr
            .addCancel()
            .present(from: fromVC ?? rootVC)
    }
}
