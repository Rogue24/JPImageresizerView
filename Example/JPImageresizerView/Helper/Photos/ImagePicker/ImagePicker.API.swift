//
//  ImagePicker.API.swift
//  ImagePickerDemo
//
//  Created by aa on 2022/12/31.
//

import UIKit

// MARK: - async/await
extension ImagePicker {
    /// Open album -> 图片
    static func openAlbum() async throws -> UIImage {
        try await ImagePicker.Controller<UIImage>.openAlbum(.photo)
    }
    
    /// Open album -> 图片/GIF数据
    static func openAlbum() async throws -> Data {
        try await ImagePicker.Controller<Data>.openAlbum(.photo)
    }
    
    /// Open album -> 视频路径
    static func openAlbum() async throws -> URL {
        try await ImagePicker.Controller<URL>.openAlbum(.video)
    }
    
    /// Open album -> 图片/GIF数据 or 视频路径
    static func openAlbum() async throws -> AlbumObject {
        try await ImagePicker.Controller<AlbumObject>.openAlbum(.all)
    }
    
    /// Photograph -> 图片
    static func photograph() async throws -> UIImage {
        try await ImagePicker.Controller<UIImage>.photograph()
    }
}

// MARK: - Closure
extension ImagePicker {
    /// Open album -> 图片
    static func openAlbumForImage(completion: @escaping ImagePicker.Completion<UIImage>) {
        ImagePicker.Controller<UIImage>.openAlbum(.photo, completion: completion)
    }
    
    /// Open album -> 图片/GIF数据
    static func openAlbumForImageData(completion: @escaping ImagePicker.Completion<Data>) {
        ImagePicker.Controller<Data>.openAlbum(.photo, completion: completion)
    }
    
    /// Open album -> 视频路径
    static func openAlbumForVideoURL(completion: @escaping ImagePicker.Completion<URL>) {
        ImagePicker.Controller<URL>.openAlbum(.video, completion: completion)
    }
    
    /// Open album -> 图片/GIF数据 or 视频路径
    static func openAlbumForObject(completion: @escaping ImagePicker.Completion<AlbumObject>) {
        ImagePicker.Controller<AlbumObject>.openAlbum(.all, completion: completion)
    }
    
    /// Photograph -> 图片
    static func photograph(completion: @escaping ImagePicker.Completion<UIImage>) {
        ImagePicker.Controller<UIImage>.photograph(completion: completion)
    }
}

// MARK: - OC
extension NSObject {
    /// Open album -> 图片
    @objc static func openAlbumForImage(completion: @escaping (_ image: UIImage?) -> Void) {
        ImagePicker.openAlbumForImage { result in
            switch result {
            case let .success(image):
                completion(image)
            case let .failure(error):
                error.showErrorHUD()
                completion(nil)
            }
        }
    }
    
    /// Open album -> 图片/GIF数据
    @objc static func openAlbumForImageData(completion: @escaping (_ imageData: Data?) -> Void) {
        ImagePicker.openAlbumForImageData { result in
            switch result {
            case let .success(imageData):
                completion(imageData)
            case let .failure(error):
                error.showErrorHUD()
                completion(nil)
            }
        }
    }
    
    /// Open album -> 视频路径
    @objc static func openAlbumForVideoURL(completion: @escaping (_ videoURL: URL?) -> Void) {
        ImagePicker.openAlbumForVideoURL { result in
            switch result {
            case let .success(videoURL):
                completion(videoURL)
            case let .failure(error):
                error.showErrorHUD()
                completion(nil)
            }
        }
    }
    
    /// Open album -> 图片/GIF数据 or 视频路径
    @objc static func openAlbumForObject(completion: @escaping (_ imageData: Data?, _ videoURL: URL?) -> Void) {
        ImagePicker.openAlbumForObject { result in
            switch result {
            case let .success(obj):
                completion(obj.imageData, obj.videoURL)
            case let .failure(error):
                error.showErrorHUD()
                completion(nil, nil)
            }
        }
    }
    
    /// Photograph -> 图片
    @objc static func photograph(completion: @escaping (_ image: UIImage?) -> Void) {
        ImagePicker.photograph { result in
            switch result {
            case let .success(image):
                completion(image)
            case let .failure(error):
                error.showErrorHUD()
                completion(nil)
            }
        }
    }
}
