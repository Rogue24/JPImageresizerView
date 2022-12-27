//
//  OneDaySize.swift
//  JPImageresizerView_Example
//
//  Created by aa on 2022/6/28.
//  Copyright © 2022 ZhouJianPing. All rights reserved.
//

enum OneDaySize: CaseIterable {
    case small
    case medium
    case large
    
    var viewWidth: CGFloat {
        switch self {
        case .small:
            return 170
        case .medium:
            return 364
        case .large:
            return 364
        }
    }
    
    var viewHeight: CGFloat {
        switch self {
        case .small:
            return 170
        case .medium:
            return 170
        case .large:
            return 382
        }
    }
    
    var imageWidth: CGFloat { viewWidth }
    
    var imageHeight: CGFloat {
        switch self {
        case .small:
            return 170
        case .medium:
            return 170
        case .large:
            return 382 - 100
        }
    }
}
