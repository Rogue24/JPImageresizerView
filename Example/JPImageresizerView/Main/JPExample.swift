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
        case darkBlur = "深色毛玻璃遮罩"
        case lightBlur = "浅色毛玻璃遮罩"
        case stretchBorder = "拉伸的边框图片"
        case tileBorder = "平铺的边框图片"
        case roundResize = "圆切样式"
        case mask = "蒙版样式"
        
        case localGIF = "裁剪GIF"
        case localVideo = "裁剪视频"
        case album = "打开相册"
        
        case cropGifAndAddStroke = "裁剪GIF并添加轮廓描边"
        case makeGifAndAddStroke = "多张PNG图片组装GIF并添加轮廓描边"
        case singleImageAddStroke = "单张PNG图片添加轮廓描边"
        
        case replaceFace = "趣味换脸"
        case girlsGIF = "自制GIF"
        case compatibleSwift = "适配 Swift"
        case compatibleSwiftUI = "适配 SwiftUI"
        case JPCroper = "JPCroper：高仿小红书的裁剪功能"
        
        var title: String { rawValue }
    }
    
    struct Section {
        let title: String
        let items: [Item]
    }
    
    static let sections: [Section] = [
        Section(title: "裁剪图片", items: [
            .`default`,
            .darkBlur,
            .lightBlur,
            .stretchBorder,
            .tileBorder,
            .roundResize,
            .mask,
        ]),
        
        Section(title: "裁剪GIF&视频", items: [
            .localGIF,
            .localVideo,
            .album,
        ]),
        
        Section(title: "图像内容添加轮廓描边", items: [
            .cropGifAndAddStroke,
            .makeGifAndAddStroke,
            .singleImageAddStroke,
        ]),
        
        Section(title: "其他", items: [
            .replaceFace,
            .girlsGIF,
            .compatibleSwift,
            .compatibleSwiftUI,
            .JPCroper,
        ]),
    ]
}

// MARK: - JPExampleError
enum JPExampleError: Error {
    case videoFixFaild
    case nonVideoFile
    case pickNullObject
}
