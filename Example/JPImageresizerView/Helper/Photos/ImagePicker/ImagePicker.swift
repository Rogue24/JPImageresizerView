//
//  ImagePicker.swift
//  ImagePickerDemo
//
//  Created by aa on 2022/12/29.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

enum ImagePicker {
    // MARK: - ImagePicker.PickType
    enum PickType {
        case photo // 照片
        case video // 视频
        case all // 图片+视频
        
        var types: [String] {
            if #available(iOS 14.0, *) {
                switch self {
                case .photo:
                    return [
                        UTType.image.identifier,
                        UTType.livePhoto.identifier,
                    ]
                case .video:
                    return [
                        UTType.movie.identifier,
                        UTType.video.identifier,
                    ]
                case .all:
                    return [
                        UTType.movie.identifier,
                        UTType.video.identifier,
                        UTType.image.identifier,
                        UTType.livePhoto.identifier,
                    ]
                }
            } else {
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
    }
    
    // MARK: - ImagePicker.Completion
    typealias Completion<T: ImagePickerObject> = (_ result: Result<T, ImagePicker.PickError>) -> Void
    
    // MARK: - ImagePicker.PickError
    enum PickError: Error {
        case nullParentVC // 没有父控制器
        case objFetchFaild // obj查找失败
        case objConvertFaild(_ error: Error?) // obj转换失败
        case other(_ error: Error?) // 其他错误
        case userCancel // 用户取消
    }
}

// MARK: - ImagePicker.Controller
extension ImagePicker {
    class Controller<T: ImagePickerObject>: UIImagePickerController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        // 完成闭包，用于返回结果
        private var completion: ImagePicker.Completion<T>? = nil
        
        // MARK: Life cycle
        deinit {
            print("jpjpjp ImagePicker.Controller deinit")
        }
        
        // MARK: UIImagePickerControllerDelegate
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // 1.获取结果
            let result: Result<T, ImagePicker.PickError>
            do {
                result = .success(try T.fetchFromPicker(info))
            } catch let pickError as ImagePicker.PickError {
                result = .failure(pickError)
            } catch {
                result = .failure(.other(error))
            }
            
            // 2.返回结果
            completion?(result)
            
            // 3.关闭控制器
            dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            // 1.返回结果：用户点击取消
            completion?(.failure(.userCancel))
            
            // 2.关闭控制器
            dismiss(animated: true)
        }
    }
}

// MARK: - Open album
extension ImagePicker.Controller {
    static func openAlbum<T: ImagePickerObject>(_ mediaType: ImagePicker.PickType) async throws -> T {
        let picker: ImagePicker.Controller<T> = try showAlbumPicker(mediaType: mediaType)
        return try await picker.pickObject()
    }
    
    static func openAlbum<T: ImagePickerObject>(_ mediaType: ImagePicker.PickType, completion: @escaping ImagePicker.Completion<T>) {
        do {
            let picker: ImagePicker.Controller<T> = try showAlbumPicker(mediaType: mediaType)
            picker.pickObject(completion: completion)
        } catch let pickError as ImagePicker.PickError {
            completion(.failure(pickError))
        } catch {
            completion(.failure(.other(error)))
        }
    }
}

// MARK: - Photograph
extension ImagePicker.Controller {
    static func photograph() async throws -> UIImage {
        let picker = try showPhotographPicker()
        return try await picker.pickObject()
    }
    
    static func photograph(completion: @escaping ImagePicker.Completion<UIImage>) {
        do {
            let picker = try showPhotographPicker()
            picker.pickObject(completion: completion)
        } catch let pickError as ImagePicker.PickError {
            completion(.failure(pickError))
        } catch {
            completion(.failure(.other(error)))
        }
    }
}

// MARK: - Show picker
private extension ImagePicker.Controller {
    static func showAlbumPicker<T>(mediaType: ImagePicker.PickType) throws -> ImagePicker.Controller<T> {
        let parentVC = try getParentVC()
        let picker = ImagePicker.Controller<T>()
        picker.modalPresentationStyle = .overFullScreen
        picker.mediaTypes = mediaType.types
        picker.videoQuality = .typeHigh
        picker.delegate = picker
        parentVC.present(picker, animated: true)
        return picker
    }
    
    static func showPhotographPicker() throws -> ImagePicker.Controller<UIImage> {
        let parentVC = try getParentVC()
        let picker = ImagePicker.Controller<UIImage>()
        picker.modalPresentationStyle = .overFullScreen
        picker.sourceType = .camera
        picker.delegate = picker
        parentVC.present(picker, animated: true)
        return picker
    }
    
    static func getParentVC() throws -> UIViewController {
        guard var parentVC = UIApplication.shared.delegate?.window??.rootViewController else {
            throw ImagePicker.PickError.nullParentVC
        }
        while let next = parentVC.presentedViewController {
            parentVC = next
        }
        return parentVC
    }
}

// MARK: - Pick object handle
private extension ImagePicker.Controller {
    func pickObject(completion: @escaping ImagePicker.Completion<T>) {
        self.completion = completion
    }
    
    func pickObject() async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            pickObject() { result in
                continuation.resume(with: result)
            }
        }
    }
}
