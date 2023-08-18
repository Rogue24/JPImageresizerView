//
//  JPExample.VideoFixOrientation.swift
//  JPImageresizerView_Example
//
//  Created by aa on 2022/12/26.
//  Copyright © 2022 ZhouJianPing. All rights reserved.
//

import UIKit
import JPImageresizerView
import JPBasic

// MARK: - 修正视频方向
extension JPExample {
    static func videoFixOrientation(_ videoURL: URL) async throws -> JPImageresizerConfigure {
        let asset = AVURLAsset(url: videoURL)
        let transform = try await fetchVideoPreferredTransform(asset)
        
        if CGAffineTransformIsIdentity(transform) {
            // 视频方向没有改变，直接返回
            return .defaultConfigure(withVideoAsset: asset, make: nil, fixErrorBlock: nil, fixStart: nil, fixProgressBlock: nil)
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            videoFixOrientation(asset) { result in
                continuation.resume(with: result)
            }
        }
    }
}

private extension JPExample {
    static func videoFixOrientation(_ asset: AVURLAsset, _ completion: @escaping (Result<JPImageresizerConfigure, Error>) -> Void) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                videoFixOrientation(asset, completion)
            }
            return
        }
        
        UIAlertController.build(.alert, title: "该视频的方向需要修正后才可裁剪")
            .addAction("先进页面再修正") {
                afterIntoView_videoFixOrientation(asset, completion)
            }
            .addAction("先修正再进页面") {
                beforeIntoView_videoFixOrientation(asset, completion)
            }
            .present(from: mainVC)
    }
    
    // MARK: 1.先进去裁剪页面，再修正视频方向
    static func afterIntoView_videoFixOrientation(_ asset: AVURLAsset, _ completion: @escaping (Result<JPImageresizerConfigure, Error>) -> Void) {
        completion(.success(
            JPImageresizerConfigure.defaultConfigure(withVideoURL: asset.url, make: nil) { cacheURL, reason in
                JPImageresizerViewController.showErrorMsg(reason, pathExtension: cacheURL?.pathExtension ?? "")
            } fixStart: {
                JPProgressHUD.show()
            } fixProgressBlock: { progress in
                JPProgressHUD.showProgress(progress, status: String(format: "修正方向中...%.0lf%%", progress * 100))
            } fixComplete: { _ in
                JPProgressHUD.dismiss()
            }
        ))
    }
    
    // MARK: 2.先修正视频方向，再进去裁剪页面
    static func beforeIntoView_videoFixOrientation(_ asset: AVURLAsset, _ completion: @escaping (Result<JPImageresizerConfigure, Error>) -> Void) {
        JPProgressHUD.show()
        JPImageresizerTool.fixOrientationVideo(with: asset) { cacheURL, reason in
            JPImageresizerViewController.showErrorMsg(reason, pathExtension: cacheURL?.pathExtension ?? "")
            mainVC.isExporting = false
            completion(.failure(JPExampleError.videoFixFaild))
            
        } fixStart: { exportSession in
            mainVC.isExporting = true
            mainVC.addProgressTimer(progressBlock: { progress in
                JPProgressHUD.showProgress(progress, status: String(format: "修正方向中...%.0lf%%", progress * 100), userInteractionEnabled: true)
            }, exporterSession: exportSession)
            
        } fixComplete: { cacheURL in
            JPProgressHUD.dismiss()
            mainVC.isExporting = false
            mainVC.tmpVideoURL = cacheURL
            completion(.success(
                JPImageresizerConfigure.defaultConfigure(withVideoAsset: AVURLAsset(url: cacheURL), make: nil, fixErrorBlock: nil, fixStart: nil, fixProgressBlock: nil)
            ))
        }
    }
}

// MARK: - 获取视频的形变信息（视频方向）
private extension JPExample {
    static func fetchVideoPreferredTransform(_ asset: AVURLAsset, completion: @escaping (Result<CGAffineTransform, Error>) -> Void) {
        if #available(iOS 15.0, *) {
            asset.loadTracks(withMediaType: .video) { tracks, error in
                guard let track = tracks?.first else {
                    completion(.failure(error ?? NSError()))
                    return
                }
                
                let transform = track.preferredTransform
                completion(.success(transform))
            }
            return
        }
        
        asset.loadValuesAsynchronously(forKeys: ["tracks"]) {
            var error: NSError? = nil
            guard asset.statusOfValue(forKey: "tracks", error: &error) == .loaded,
                  let track = asset.tracks(withMediaType: .video).first else {
                completion(.failure(error ?? NSError()))
                return
            }
            
            let transform = track.preferredTransform
            completion(.success(transform))
        }
    }
    
    static func fetchVideoPreferredTransform(_ asset: AVURLAsset) async throws -> CGAffineTransform {
        if #available(iOS 16.0, *) {
            let tracks = try await asset.load(.tracks)
            guard let track = tracks.first(where: { $0.mediaType == .video }) else {
                throw JPExampleError.nonVideoFile
            }
            return try await track.load(.preferredTransform)
        }
        
        let transform = try await withCheckedThrowingContinuation { continuation in
            fetchVideoPreferredTransform(asset) { result in
                continuation.resume(with: result)
            }
        }
        return transform
    }
}

