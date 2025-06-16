//
//  JPExample.swift
//  JPImageresizerView_Example
//
//  Created by aa on 2022/11/24.
//  Copyright © 2022 ZhouJianPing. All rights reserved.
//

import Foundation

// MARK: - JPExample
enum JPExample {
    enum Item: String {
        case `default` = "默认样式"
        case blurBg = "毛玻璃遮罩"
        case customBorder = "自定义边框图片"
        case roundResize = "圆切样式"
        case mask = "蒙版样式"
        
        case localGIF = "裁剪GIF"
        case localVideo = "裁剪视频"
        case album = "打开相册"
        
        case cropGifAndAddStroke = "裁剪GIF并添加轮廓描边"
        case makeGifAndAddOutlineStroke = "本地图片组装GIF并添加轮廓描边"
        case singleImageAddOutlineStroke = "图像内容添加轮廓描边"
        case singleImageOnlyDrawOutline = "绘制图像内容的轮廓"
        case colorMeasurement = "获取图片的像素颜色值"
        
        case cropFace = "人脸裁剪"
        case replaceFace = "趣味换脸"
        case girlsGIF = "自制GIF"
        case compatibleSwift = "适配 Swift"
        case compatibleSwiftUI = "适配 SwiftUI"
        case JPCroper = "JPCroper - 高仿小红书的裁剪功能"
        
        case GlassEffect = "玻璃效果"
        
        var title: String { rawValue }
    }
    
    struct Section {
        let title: String
        let items: [Item]
    }
    
    static let sections: [Section] = [
        Section(title: "✂️ 裁剪图片", items: [
            .`default`,
            .blurBg,
            .customBorder,
            .roundResize,
            .mask,
        ]),
        
        Section(title: "🎞 裁剪GIF&视频", items: [
            .localGIF,
            .localVideo,
            .album,
        ]),
        
        Section(title: "📢 新功能", items: [
            .cropGifAndAddStroke,
            .makeGifAndAddOutlineStroke,
            .singleImageAddOutlineStroke,
            .singleImageOnlyDrawOutline,
            .colorMeasurement,
        ]),
        
        Section(title: "🦄 其他", items: [
            .cropFace,
            .replaceFace,
            .girlsGIF,
            .compatibleSwift,
            .compatibleSwiftUI,
            .JPCroper,
            .GlassEffect,
        ]),
    ]
}

// MARK: - JPExampleError
enum JPExampleError: Error {
    case videoFixFaild
    case nonVideoFile
    case pickNullObject
}

//// MARK: - JPExampleConfigure
//@objcMembers
//class JPExampleConfigure: NSObject {
//    
//}

