//
//  Const.swift
//  WaterfallLayoutDemo
//
//  Created by aa on 2026/10/9.
//

import Foundation

/// 当前时间
func lookTime() -> String {
#if DEBUG
    "\(hhmmssSSFormatter.string(from: Date()))"
#else
    ""
#endif
}

private let hhmmssSSFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "zh_CN")
    formatter.dateFormat = "hh:mm:ss.SS"
    return formatter
}()
