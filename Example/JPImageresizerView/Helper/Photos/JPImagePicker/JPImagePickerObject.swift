//
//  JPImagePickerObject.swift
//  JPImageresizerView_Example
//
//  Created by aa on 2022/12/26.
//  Copyright © 2022 ZhouJianPing. All rights reserved.
//

import MobileCoreServices

protocol JPImagePickerObject {
    static func fetchFromPicker(_ info: [UIImagePickerController.InfoKey: Any]) -> Self?
}
extension JPImagePickerObject {
    static func fetchFromPicker(_ info: [UIImagePickerController.InfoKey: Any]) -> Self? { nil }
}

// MARK: - URL
extension URL: JPImagePickerObject {
    static func fetchFromPicker(_ info: [UIImagePickerController.InfoKey: Any]) -> Self? {
        return info[.mediaURL] as? Self
    }
}

// MARK: - Data
extension Data: JPImagePickerObject {
    static func fetchFromPicker(_ info: [UIImagePickerController.InfoKey: Any]) -> Self? {
        guard let url = info[.imageURL] as? URL else {
            return nil
        }
        return try? Self.init(contentsOf: url)
    }
}

// MARK: - UIImage
extension UIImage: JPImagePickerObject {
    static func fetchFromPicker(_ info: [UIImagePickerController.InfoKey: Any]) -> Self? {
        guard let data = Data.fetchFromPicker(info) else {
            return info[.originalImage] as? Self
        }
        return Self.init(data: data)
    }
}

// MARK: - JPAlbumObject
struct JPAlbumObject {
    let imageData: Data?
    let videoURL: URL?
}
extension JPAlbumObject: JPImagePickerObject {
    static func fetchFromPicker(_ info: [UIImagePickerController.InfoKey: Any]) -> Self? {
        var imageData: Data?
        var videoURL: URL?
        if let mediaType = info[.mediaType] as? String, mediaType == (kUTTypeImage as String) {
            if let url = info[.imageURL] as? URL {
                imageData = try? Data(contentsOf: url)
            }
        } else {
            videoURL = info[.mediaURL] as? URL
        }
        return Self.init(imageData: imageData, videoURL: videoURL)
    }
}

extension JPAlbumObject {
    
}

// MARK: - Other...
