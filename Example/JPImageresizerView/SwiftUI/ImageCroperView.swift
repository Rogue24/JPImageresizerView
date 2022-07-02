//
//  ImageCroperView.swift
//  JPImageresizerView_Example
//
//  Created by aa on 2022/6/27.
//  Copyright © 2022 ZhouJianPing. All rights reserved.
//

import UIKit
import SwiftUI

@available(iOS 15.0.0, *)
struct ImageCroperView: UIViewControllerRepresentable {
    
    @Binding var cropImage: UIImage?
    let resizeWHScale: CGFloat
    let isUseJPCrop: Bool
    @Environment(\.presentationMode) var isPresented
    
    func makeUIViewController(context: Context) -> JPCropViewController {
        let imageCroper = JPCropViewController.build(forCroper: isUseJPCrop)
        imageCroper.image = cropImage
        imageCroper.resizeWHScale = resizeWHScale
        imageCroper.swiftUIDelegate = context.coordinator
        return imageCroper
    }
    
    func updateUIViewController(_ uiViewController: JPCropViewController, context: Context) {
        
    }
    
    // Connecting the Coordinator class with this struct
    func makeCoordinator() -> ImageCroperCoordinator {
        return ImageCroperCoordinator(croper: self)
    }
    
}

@available(iOS 15.0.0, *)
class ImageCroperCoordinator: NSObject, JPCropViewControllerSwiftUIDelegate {
    
    var croper: ImageCroperView
    
    init(croper: ImageCroperView) {
        self.croper = croper
    }
    
    func cropViewController(_ cropVC: JPCropViewController, imageDidFinishCrop image: UIImage) {
        croper.cropImage = image
        croper.isPresented.wrappedValue.dismiss()
    }
    
    func dismissCropViewController(_ cropVC: JPCropViewController) {
        croper.cropImage = nil
        croper.isPresented.wrappedValue.dismiss()
    }
    
}
