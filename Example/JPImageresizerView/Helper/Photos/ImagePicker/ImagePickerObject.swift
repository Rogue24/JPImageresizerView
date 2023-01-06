//
//  ImagePickerObject.swift
//  ImagePickerDemo
//
//  Created by aa on 2022/12/29.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

protocol ImagePickerObject {
    static func fetchFromPicker(_ info: [UIImagePickerController.InfoKey: Any]) throws -> Self
}

// MARK: - URL
extension URL: ImagePickerObject {
    static func fetchFromPicker(_ info: [UIImagePickerController.InfoKey: Any]) throws -> Self {
        guard let url = info[.mediaURL] as? Self else {
            throw ImagePicker.PickError.objFetchFaild
        }
        return url
    }
}

// MARK: - Data
extension Data: ImagePickerObject {
    static func fetchFromPicker(_ info: [UIImagePickerController.InfoKey: Any]) throws -> Self {
        guard let url = info[.imageURL] as? URL else {
            throw ImagePicker.PickError.objFetchFaild
        }
        do {
            return try Self.init(contentsOf: url)
        } catch {
            throw ImagePicker.PickError.objConvertFaild(error)
        }
    }
}

// MARK: - UIImage
extension UIImage: ImagePickerObject {
    static func fetchFromPicker(_ info: [UIImagePickerController.InfoKey: Any]) throws -> Self {
        do {
            let data = try Data.fetchFromPicker(info)
            guard let image = Self.init(data: data) else {
                throw ImagePicker.PickError.objConvertFaild(nil)
            }
            return image
        } catch ImagePicker.PickError.objFetchFaild {
            guard let image = info[.originalImage] as? Self else {
                throw ImagePicker.PickError.objFetchFaild
            }
            return image
        }
    }
}

// MARK: - AlbumObject
struct AlbumObject {
    let imageData: Data? // 图片
    let videoURL: URL? // 视频
}
extension AlbumObject: ImagePickerObject {
    static func fetchFromPicker(_ info: [UIImagePickerController.InfoKey: Any]) throws -> Self {
        var imageData: Data?
        var videoURL: URL?
        if #available(iOS 14.0, *) {
            if let mediaType = info[.mediaType] as? String, mediaType == UTType.image.identifier {
                imageData = try Data.fetchFromPicker(info)
            } else {
                videoURL = try URL.fetchFromPicker(info)
            }
        } else {
            if let mediaType = info[.mediaType] as? String, mediaType == (kUTTypeImage as String) {
                imageData = try Data.fetchFromPicker(info)
            } else {
                videoURL = try URL.fetchFromPicker(info)
            }
        }
        return Self.init(imageData: imageData, videoURL: videoURL)
    }
}

// MARK: - Other...
