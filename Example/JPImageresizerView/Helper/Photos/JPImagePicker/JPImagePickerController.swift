//
//  JPImagePickerController.swift
//  JPImageresizerView_Example
//
//  Created by aa on 2022/12/12.
//  Copyright © 2022 ZhouJianPing. All rights reserved.
//

import MobileCoreServices
import Combine

// MARK: - API Photograph
func PhotographImage() async throws -> UIImage {
    try await JPImagePickerController<UIImage>.photograph()
}

// MARK: - API Open album
func PickAlbumImage() async throws -> UIImage {
    try await JPImagePickerController<UIImage>.openAlbum(.photo)
}

func PickAlbumImageData() async throws -> Data {
    try await JPImagePickerController<Data>.openAlbum(.photo)
}

func PickAlbumVideoURL() async throws -> URL {
    try await JPImagePickerController<URL>.openAlbum(.video)
}

func PickAlbumObject() async throws -> JPAlbumObject {
    try await JPImagePickerController<JPAlbumObject>.openAlbum(.all)
}

// MARK: - Enum
enum JPImagePickerError: Error {
    case fetchFaild
    case cancel
}

enum JPImagePickerType {
    case photo
    case video
    case all
    
    var types: [String] {
        switch self {
        case .photo:
            return [
                kUTTypeImage as String,
                kUTTypeLivePhoto as String,
            ]
        case .video:
            return [
                kUTTypeMovie as String,
                kUTTypeVideo as String,
            ]
        case .all:
            return [
                kUTTypeMovie as String,
                kUTTypeVideo as String,
                kUTTypeImage as String,
                kUTTypeLivePhoto as String,
            ]
        }
    }
}

class JPImagePickerController<T: JPImagePickerObject>: UIImagePickerController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private var object: T? = nil
    private var isSetedObject = false
    
    private let locker = DispatchSemaphore(value: 0)
    private var isLocking = false
    
    // MARK: - Life cycle
    deinit {
        print("jpjpjp JPImagePickerController deinit")
    }
    
    // MARK: - Begin pick
    static func openAlbum<T: JPImagePickerObject>(_ mediaType: JPImagePickerType) async throws -> T {
        let picker = JPImagePickerController<T>()
        picker.modalPresentationStyle = .overFullScreen
        picker.mediaTypes = mediaType.types
        picker.videoQuality = .typeHigh
        picker.delegate = picker
        rootVC.present(picker, animated: true)
        return try await picker.pickObject()
    }
    
    static func photograph<T: JPImagePickerObject>() async throws -> T {
        let picker = JPImagePickerController<T>()
        picker.modalPresentationStyle = .overFullScreen
        picker.sourceType = .camera
        picker.delegate = picker
        rootVC.present(picker, animated: true)
        return try await picker.pickObject()
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        setupObject(info)
        tryUnlock()
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        tryUnlock()
        dismiss(animated: true)
    }
}

// MARK: - Pick handle
private extension JPImagePickerController {
    func pickObject() async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            pickObject() { result in
                continuation.resume(with: result)
            }
        }
    }
    
    func pickObject(completion: @escaping (Result<T, JPImagePickerError>) -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else {
                completion(.failure(.cancel))
                return
            }
            
            self.tryLock()
            
            if let object = self.object {
                completion(.success(object))
            } else {
                completion(.failure(self.isSetedObject ? .fetchFaild : .cancel))
            }
        }
    }
    
    func setupObject(_ info: [UIImagePickerController.InfoKey : Any]) {
        object = T.fetchFromPicker(info)
        isSetedObject = true
    }
}

// MARK: - Lock & Unlock
private extension JPImagePickerController {
    @discardableResult
    func tryLock() -> Bool {
        guard !isLocking else { return isLocking }
        guard !Thread.isMainThread else { return isLocking }
        isLocking = true
        locker.wait()
        return isLocking
    }
    
    @discardableResult
    func tryUnlock() -> Bool {
        guard Thread.isMainThread else { return !isLocking }
        guard isLocking else { return !isLocking }
        isLocking = false
        locker.signal()
        return !isLocking
    }
}
