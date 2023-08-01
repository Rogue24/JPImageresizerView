//
//  CropView.swift
//  JPImageresizerView_Example
//
//  Created by aa on 2022/6/27.
//  Copyright © 2022 ZhouJianPing. All rights reserved.
//

import SwiftUI
import JPBasic

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
    @State var isUseJPCrop: Bool = false
    @Environment(\.presentationMode) var presentationMode
    var saveOneDayImage: ((_ oneDayImage: UIImage?) -> ())?
    
    var body: some View {
        VStack(spacing: 20) {
            sizeBar
            oneDayView
            operationBar
            switchCrop
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .background(background)
        .navigationBarHidden(true)
        .overlay(navigationBar)
        .ignoresSafeArea()
    }
}

@available(iOS 15.0.0, *)
extension CropView {
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
    
    @ViewBuilder
    var oneDayView: some View {
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
        .readFrame(.global, key: OneDayPreferenceKey.self) { value in
            oneDayFrame = value
        }
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
                ImageCroperView(cropImage: $photo, resizeWHScale: oneDaySize.imageWidth / oneDaySize.imageHeight, isUseJPCrop: isUseJPCrop)
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
    
    var switchCrop: some View {
        Text(isUseJPCrop ? "Use [JPCrop](https://github.com/Rogue24/JPCrop) to crop now." : "Use [JPImageresizerView](https://github.com/Rogue24/JPImageresizerView) to crop now.")
            .font(.headline)
            .foregroundColor(.white)
            .accentColor(.yellow)
            .padding(20)
            .frame(minHeight: 40)
            .background(isUseJPCrop ? Color.teal.opacity(0.8) : Color.blue.opacity(0.8), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .baseShadow()
            .onTapGesture {
                withAnimation {
                    isUseJPCrop.toggle()
                }
            }
    }
    
    var background: some View {
        Image(uiImage: currentImage)
            .resizable()
            .aspectRatio(contentMode: .fill)
    }
    
    var navigationBar: some View {
        HStack {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "chevron.backward.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.primary)
            }
            .padding()
            
            Spacer()
            
            Button {
                saveOneDay()
            } label: {
                Image(systemName: "square.and.arrow.down.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.primary)
            }
            .padding()
        }
        .frame(height: 44)
        .overlay(
            Text("[OneDay](https://github.com/Rogue24/OneDay)")
                .font(.largeTitle)
                .bold()
                .accentColor(.primary)
                .baseShadow()
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .offset(y: JPConstant.statusBarH())
    }
}
 
@available(iOS 15.0.0, *)
extension CropView {
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
        let layer = rootVC.view.layer
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
