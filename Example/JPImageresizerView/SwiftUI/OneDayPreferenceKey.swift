//
//  OneDayPreferenceKey.swift
//  JPImageresizerView_Example
//
//  Created by aa on 2022/7/1.
//  Copyright © 2022 ZhouJianPing. All rights reserved.
//

import SwiftUI

struct OneDayPreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
