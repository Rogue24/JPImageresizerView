//
//  OneDayView.swift
//  JPImageresizerView_Example
//
//  Created by aa on 2022/6/27.
//  Copyright © 2022 ZhouJianPing. All rights reserved.
//

import SwiftUI

let dateInfo = Date().info
let oneDayText = "Everything will be fine."

// MARK: - Small
@available(iOS 15.0.0, *)
struct OneDaySmallView: View {
    let size: OneDaySize = .small
    var namespace: Namespace.ID
    @Binding var image: UIImage
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 0) {
                Text(dateInfo.day)
                    .font(.custom("DINAlternate-Bold", size: 28))
                    .foregroundColor(.white)
                + Text(" / \(dateInfo.month)")
                    .font(.custom("DINAlternate-Bold", size: 14))
                    .foregroundColor(.white)
                Text("\(dateInfo.year), \(dateInfo.weekday)")
                    .font(.custom("PingFangSC", size: 10))
                    .foregroundColor(.white.opacity(0.9))
            }
            
            Spacer()
            
            Text(oneDayText)
                .font(.custom("PingFangSC", size: 14))
                .foregroundColor(.white)
                .lineSpacing(4)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .baseShadow()
        .padding(.horizontal, 14)
        .padding(.top, 13)
        .padding(.bottom, 18)
        .frame(width: size.viewWidth, height: size.viewHeight)
        .background(
            Color.black.opacity(0.15)
                .matchedGeometryEffect(id: "imageMask", in: namespace)
        )
        .background(
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .matchedGeometryEffect(id: "image", in: namespace)
        )
        .mask(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .matchedGeometryEffect(id: "mask", in: namespace)
        )
        .baseShadow()
    }
}

// MARK: - Medium
@available(iOS 15.0.0, *)
struct OneDayMediumView: View {
    let size: OneDaySize = .medium
    var namespace: Namespace.ID
    @Binding var image: UIImage
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 0) {
                Text(dateInfo.day)
                    .font(.custom("DINAlternate-Bold", size: 36))
                    .foregroundColor(.white)
                + Text(" / \(dateInfo.month)")
                    .font(.custom("DINAlternate-Bold", size: 18))
                    .foregroundColor(.white)
                Text("\(dateInfo.year), \(dateInfo.weekday)")
                    .font(.custom("PingFangSC", size: 11))
                    .foregroundColor(.white.opacity(0.9))
            }
            
            Spacer()
            
            Text(oneDayText)
                .font(.custom("PingFangSC", size: 14))
                .foregroundColor(.white)
                .lineSpacing(4)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .baseShadow()
        .padding(.horizontal, 31)
        .padding(.top, 15)
        .padding(.bottom, 25)
        .frame(width: size.viewWidth, height: size.viewHeight)
        .background(
            Color.black.opacity(0.15)
                .matchedGeometryEffect(id: "imageMask", in: namespace)
        )
        .background(
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .matchedGeometryEffect(id: "image", in: namespace)
        )
        .mask(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .matchedGeometryEffect(id: "mask", in: namespace)
        )
        .baseShadow()
    }
}

// MARK: - Large
@available(iOS 15.0.0, *)
struct OneDayLargeView: View {
    let size: OneDaySize = .large
    var namespace: Namespace.ID
    @Environment(\.colorScheme) var colorScheme
    @Binding var image: UIImage
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .matchedGeometryEffect(id: "image", in: namespace)
                .frame(maxWidth: .infinity)
                .frame(height: size.imageHeight)
            
            Color.black.opacity(0.15)
                .matchedGeometryEffect(id: "imageMask", in: namespace)
                .frame(maxWidth:. infinity, maxHeight: .infinity)
            
            VStack(spacing: 0) {
                VStack(alignment: .leading) {
                    Text(dateInfo.day)
                        .font(.custom("DINAlternate-Bold", size: 36))
                        .foregroundColor(.white)
                    + Text(" / \(dateInfo.month)")
                        .font(.custom("DINAlternate-Bold", size: 18))
                        .foregroundColor(.white)
                    Text("\(dateInfo.year), \(dateInfo.weekday)")
                        .font(.custom("PingFangSC", size: 11))
                        .foregroundColor(.white.opacity(0.9))
                }
                .baseShadow()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding(.bottom, 10)
                .padding(.horizontal, 24)

                HStack(alignment: .center, spacing: 10) {
                    Text(oneDayText)
                        .font(.custom("PingFangSC", size: 15))
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.25, green: 0.25, blue: 0.27))
                        .lineSpacing(5)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Text("今日\n语录")
                        .font(.custom("PingFangSC", size: 21))
                        .foregroundColor(colorScheme == .dark ? Color(red: 0.8, green: 0.8, blue: 0.8) : Color(red: 0.56, green: 0.56, blue: 0.56))
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity)
                .frame(height: size.viewHeight - size.imageHeight)
                .background(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white)
            }
            .frame(maxWidth:. infinity, maxHeight: .infinity)
        }
        .frame(width: size.viewWidth, height: size.viewHeight)
        .background(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white)
        .mask(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .matchedGeometryEffect(id: "mask", in: namespace)
        )
        .baseShadow()
    }
}

@available(iOS 15.0.0, *)
struct OneDayView_Previews: PreviewProvider {
    @Namespace static var namespace
    static var previews: some View {
        ScrollView {
            VStack(spacing: 0) {
                OneDaySmallView(namespace: namespace, image: .constant(UIImage.bundleImage("Girl1", ofType: "jpg")))
                    .padding(8)
                
                OneDayMediumView(namespace: namespace, image: .constant(UIImage.bundleImage("Girl8", ofType: "jpg")))
                    .padding(8)

                OneDayLargeView(namespace: namespace, image: .constant(UIImage.bundleImage("Girl4", ofType: "jpg")))
                    .padding(8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(.secondary)
    }
}
