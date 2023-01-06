//
//  Error.Extension.swift
//  JPImageresizerView_Example
//
//  Created by aa on 2023/1/6.
//  Copyright © 2023 ZhouJianPing. All rights reserved.
//

protocol ErrorHUD: Error {
    func showErrorHUD()
}

extension JPExampleError: ErrorHUD {
    func showErrorHUD() {
        let errorMsg: String
        switch self {
        case .videoFixFaild:
            errorMsg = "【视频修正失败】"
        case .nonVideoFile:
            errorMsg = "【非视频文件】"
        case .pickNullObject:
            errorMsg = "【获取照片/视频失败】"
        }
        JPProgressHUD.showError(withStatus: errorMsg, userInteractionEnabled: true)
    }
}

extension ImagePicker.PickError: ErrorHUD {
    func showErrorHUD() {
        let errorMsg: String
        switch self {
        case .nullParentVC:
            errorMsg = "【获取照片/视频失败】\n没有父控制器"
        case .objFetchFaild:
            errorMsg = "【获取照片/视频失败】\n对象查找失败"
        case let .objConvertFaild(error):
            errorMsg = "【获取照片/视频失败】\n对象转换失败：\(String(describing: error))）"
        case let .other(error):
            errorMsg = "【获取照片/视频失败】\n系统错误：\(String(describing: error))"
        case .userCancel:
            return
        }
        JPProgressHUD.showError(withStatus: errorMsg, userInteractionEnabled: true)
    }
}
