//
//  Error+.swift
//  JPImageresizerView_Example
//
//  Created by aa on 2023/1/6.
//  Copyright © 2023 ZhouJianPing. All rights reserved.
//

import JPBasic
import JPImageresizerView

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

extension JPProgressHUD {
    @objc class func showImageresizerError(_ reason: JPImageresizerErrorReason, pathExtension: String? = nil) {
        switch reason {
        case .JPIEReason_NilObject:
            showError(withStatus: "资源为空", userInteractionEnabled: true)
            
        case .JPIEReason_CacheURLAlreadyExists:
            showError(withStatus: "缓存路径已存在其他文件", userInteractionEnabled: true)
            
        case .JPIEReason_NoSupportedFileType:
            showError(withStatus: pathExtension.map({ "“\($0)”：" }) ?? "" + "不支持的文件格式", userInteractionEnabled: true)
            
        case .JPIEReason_VideoAlreadyDamage:
            showError(withStatus: "视频文件已损坏", userInteractionEnabled: true)
            
        case .JPIEReason_VideoExportFailed:
            showError(withStatus: "视频导出失败", userInteractionEnabled: true)
            
        case .JPIEReason_VideoExportCancelled:
            showError(withStatus: "视频导出取消", userInteractionEnabled: true)
            
        case .JPIEReason_VideoDurationTooShort:
            showError(withStatus: "视频截取时间过短（至少1s）", userInteractionEnabled: true)
            
        @unknown default:
            break
        }
    }
}
