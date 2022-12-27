//
//  JPExample.VideoFix.swift
//  JPImageresizerView_Example
//
//  Created by aa on 2022/12/26.
//  Copyright © 2022 ZhouJianPing. All rights reserved.
//

extension JPExample {
    static func videoFix(_ videoURL: URL) async throws -> JPImageresizerConfigure {
        let asset = AVURLAsset(url: videoURL)
        let transform = try await fetchVideoPreferredTransform(asset)
        
        if CGAffineTransformIsIdentity(transform) {
            return .defaultConfigure(withVideoAsset: asset, make: nil, fixErrorBlock: nil, fixStart: nil, fixProgressBlock: nil)
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            videoFix(asset) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    private static func videoFix(_ asset: AVURLAsset, completion: @escaping (Result<JPImageresizerConfigure, Error>) -> Void) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                videoFix(asset, completion: completion)
            }
            return
        }
        
        let alertCtr = UIAlertController(title: "该视频方向需要先修正", message: nil, preferredStyle: .alert)
        
        alertCtr.addAction(.init(title: "先进页面再修正", style: .default, handler: { _ in
            let configure = JPImageresizerConfigure.defaultConfigure(withVideoURL: asset.url, make: nil) { cacheURL, reason in
                JPImageresizerViewController.showErrorMsg(reason, pathExtension: cacheURL?.pathExtension ?? "")
            } fixStart: {
                JPProgressHUD.show()
            } fixProgressBlock: { progress in
                JPProgressHUD.showProgress(progress, status: String(format: "修正方向中...%.0lf%%", progress * 100))
            } fixComplete: { _ in
                JPProgressHUD.dismiss()
            }
            completion(.success(configure))
        }))
        
        alertCtr.addAction(.init(title: "先修正再进页面", style: .default, handler: { _ in
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
                
                let configure = JPImageresizerConfigure
                    .defaultConfigure(withVideoAsset: AVURLAsset(url: cacheURL),
                                      make: nil,
                                      fixErrorBlock: nil,
                                      fixStart: nil,
                                      fixProgressBlock: nil)
                
                completion(.success(configure))
            }
        }))
        
        mainVC.present(alertCtr, animated: true, completion: nil)
    }
}

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

