//
//  CropView.swift
//  JPImageresizerView_Example
//
//  Created by aa on 2022/6/27.
//  Copyright © 2022 ZhouJianPing. All rights reserved.
//

import SwiftUI

@available(iOS 15.0.0, *)
struct CropView: View {
    @Namespace var namespace
    @State var smallImage: UIImage = .bundleImage("Girl1", ofType: "jpg")
    @State var mediumImage: UIImage = .bundleImage("Girl8", ofType: "jpg")
    @State var largeImage: UIImage = .bundleImage("Girl4", ofType: "jpg")
    @State var oneDaySize: OneDaySize = .small
    @State var oneDayFrame: CGRect = .zero
    @State var showImagePicker = false
    @State var showImageCroper = false
    @State var photo: UIImage? = nil
    @State var isCroped: Bool = false
    @Environment(\.presentationMode) var presentationMode
    var saveOneDayImage: ((_ oneDayImage: UIImage?) -> ())?
    
    var body: some View {
        VStack(spacing: 20) {
            sizeBar
            oneDayView
            operationBar
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .background(
            Image(uiImage: currentImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        )
        .ignoresSafeArea()
        .navigationTitle("OneDay")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "chevron.backward.circle.fill")
                    .font(.body.weight(.bold))
                    .foregroundColor(.primary)
            },
            trailing: Button {
                saveOneDay()
            } label: {
                Image(systemName: "square.and.arrow.down.fill")
                    .font(.body.weight(.bold))
                    .foregroundColor(.primary)
            }
        )
    }
    
    var sizeBar: some View {
        HStack(spacing: 20) {
            ForEach(OneDaySize.allCases, id: \.self) { size in
                Button {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.9)) {
                        oneDaySize = size
                    }
                } label: {
                    Image(systemName: {
                        switch size {
                        case .small:
                            return "s.circle"
                        case .medium:
                            return "m.circle"
                        case .large:
                            return "l.circle"
                        }
                    }())
                    .iconStyle(size: 40, cornerRadius: 10)
                }
            }
        }
        .zIndex(1)
    }
    
    @ViewBuilder var oneDayView: some View {
        Group {
            switch oneDaySize {
            case .small:
                OneDaySmallView(namespace: namespace, image: $smallImage)
            case .medium:
                OneDayMediumView(namespace: namespace, image: $mediumImage)
            case .large:
                OneDayLargeView(namespace: namespace, image: $largeImage)
            }
        }
        .overlay(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: OneDayPreferenceKey.self,
                                value: proxy.frame(in: .global))
            }
            .onPreferenceChange(OneDayPreferenceKey.self) { value in
                oneDayFrame = value
            }
        )
    }
    
    var operationBar: some View {
        HStack(spacing: 20) {
            Button {
                photo = currentImage
                showImageCroper = true
            } label: {
                Image(systemName: "crop.rotate")
                    .iconStyle(size: 50, cornerRadius: 20)
            }
            .fullScreenCover(isPresented: $showImageCroper, onDismiss: imageCropDismiss) {
                ImageCroperView(cropImage: $photo, resizeWHScale: oneDaySize.imageWidth / oneDaySize.imageHeight)
                    .ignoresSafeArea()
            }
            
            Button {
                showImagePicker = true
            } label: {
                Image(systemName: "photo.on.rectangle.angled")
                    .iconStyle(size: 50, cornerRadius: 20)
            }
            .sheet(isPresented: $showImagePicker, onDismiss: imagePickDismiss) {
                ImagePickerView(selectedImage: $photo)
            }
        }
    }
    
    var currentImage: UIImage {
        switch oneDaySize {
        case .small:
            return smallImage
        case .medium:
            return mediumImage
        case .large:
            return largeImage
        }
    }
    
    func saveOneDay() {
        guard let saveOneDayImage = saveOneDayImage else { return }
        guard let layer = UIApplication.shared.keyWindow?.rootViewController?.view.layer else {
            saveOneDayImage(nil)
            return
        }
        let path = UIBezierPath(roundedRect: oneDayFrame, cornerRadius: 20)
        let renderer = UIGraphicsImageRenderer(bounds: oneDayFrame)
        let image = renderer.image { rendererContext in
            let context = rendererContext.cgContext
            context.addPath(path.cgPath)
            context.clip()
            layer.render(in: context)
        }
        saveOneDayImage(image)
    }
}

@available(iOS 15.0.0, *)
extension CropView {
    func imagePickDismiss() {
        guard photo != nil else { return }
        showImageCroper = true
    }
    
    func imageCropDismiss() {
        guard photo != nil else { return }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.9)) {
            switch oneDaySize {
            case .small:
                smallImage = photo!
            case .medium:
                mediumImage = photo!
            case .large:
                largeImage = photo!
            }
            photo = nil
        }
    }
}

@available(iOS 15.0.0, *)
struct CropView_Previews: PreviewProvider {
    static var previews: some View {
        CropView()
    }
}
