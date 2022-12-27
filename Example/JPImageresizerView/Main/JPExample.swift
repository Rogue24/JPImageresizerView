//
//  JPExample.swift
//  JPImageresizerView_Example
//
//  Created by aa on 2022/11/24.
//  Copyright © 2022 ZhouJianPing. All rights reserved.
//

protocol JPExampleItem: RawRepresentable<Int> {
    var item: Int { get }
    var title: String { get }
    func execute() async throws
}
extension JPExampleItem {
    var item: Int { rawValue }
    
    func execute() async throws {
        JPProgressHUD.show(nil, status: "敬请期待", userInteractionEnabled: true)
    }
    
    func doExecute(complete: ((_ r: Result<Void, Error>) -> Void)? = nil) {
        Task {
            do {
                try await execute()
                guard let complete = complete else { return }
                Task.detached { @MainActor in
                    complete(.success(()))
                }
            } catch {
                print("jpjpjp doExecute failure \(error)")
                guard let complete = complete else { return }
                Task.detached { @MainActor in
                    complete(.failure(error))
                }
            }
        }
    }
}

protocol JPExampleSection: CaseIterable, JPExampleItem {
    static var section: Int { get }
    static var title: String { get }
    static var items: [Self] { get }
}
extension JPExampleSection {
    static var items: [Self] { allCases as? [Self] ?? [] }
}

enum JPExample {
    static let sections: [any JPExampleSection.Type] = [Section0.self, Section1.self, Section2.self]
    
    enum Section0: Int, JPExampleSection {
        case `default`
        case darkBlur
        case lightBlur
        case stretchBorder
        case tileBorder
        case roundResize
        case mask
        
        static var section: Int { 0 }
        static var title: String { "裁剪图片" }
        
        var title: String {
            switch self {
            case .`default`:
                return "默认样式"
            case .darkBlur:
                return "深色毛玻璃遮罩"
            case .lightBlur:
                return "浅色毛玻璃遮罩"
            case .stretchBorder:
                return "拉伸的边框图片"
            case .tileBorder:
                return "平铺的边框图片"
            case .roundResize:
                return "圆切样式"
            case .mask:
                return "蒙版样式"
            }
        }
    }
    
    enum Section1: Int, JPExampleSection {
        case localGIF
        case localVideo
        case album
        
        static var section: Int { 1 }
        static var title: String { "裁剪GIF&视频" }
        
        var title: String {
            switch self {
            case .localGIF:
                return "裁剪GIF"
            case .localVideo:
                return "裁剪视频"
            case .album:
                return "打开相册"
            }
        }
    }
    
    enum Section2: Int, JPExampleSection {
        case replaceFace
        case girlsGIF
        case compatibleSwift
        case compatibleSwiftUI
        case JPCroper
        
        static var section: Int { 2 }
        static var title: String { "其他" }
        
        var title: String {
            switch self {
            case .replaceFace:
                return "趣味换脸"
            case .girlsGIF:
                return "自制GIF"
            case .compatibleSwift:
                return "适配 Swift"
            case .compatibleSwiftUI:
                return "适配 SwiftUI"
            case .JPCroper:
                return "高仿小红书的裁剪功能：JPCroper"
            }
        }
    }
}
