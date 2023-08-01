//
//  View+.swift
//  Neves_SwiftUI
//
//  Created by 周健平 on 2023/6/13.
//

import SwiftUI

extension View {
    func sheet(item: Binding<(some View & Identifiable)?>) -> some View {
        self.sheet(item: item) { $0 }
    }
    
    /// 设置为【可至最大宽度】，并推至【目标对齐】位置
    /// - Tag: xPush
    func xPush(to alignment: HorizontalAlignment) -> some View {
        switch alignment {
        case .leading:
            return frame(maxWidth: .infinity, alignment: .leading)
        case .trailing:
            return frame(maxWidth: .infinity, alignment: .trailing)
        default:
            return frame(maxWidth: .infinity, alignment: .center)
        }
    }
    
    /// 设置为【可至最大宽度】，并【居中】对齐
    /// Shortcut: [xPush(to: .center)](x-source-tag://xPush)
    func maxWidth() -> some View {
        xPush(to: .center)
    }
    
    /// 设置为【可至最大高度】，并推至【目标对齐】位置
    /// - Tag: yPush
    func yPush(to alignment: VerticalAlignment) -> some View {
        switch alignment {
        case .top:
            return frame(maxHeight: .infinity, alignment: .top)
        case .bottom:
            return frame(maxHeight: .infinity, alignment: .bottom)
        default:
            return frame(maxHeight: .infinity, alignment: .center)
        }
    }
    
    /// 设置为【可至最大高度】，并【居中】对齐
    /// Shortcut: [yPush(to: .center)](x-source-tag://yPush)
    func maxHeight() -> some View {
        yPush(to: .center)
    }
}

// MARK: - Read Geometry

@available(iOS 15.0, *)
extension View {
    // MARK: KeyPath
    
    /// 读取【目前】视图的`Geometry`信息（读取这一句之前上面这部分的视图的`Geometry`信息）
    /// 并通过`PreferenceKey`进行回传（防止在子视图里面修改父视图的`State`属性）
    func readGeometry<K: PreferenceKey, V>(_ keyPath: KeyPath<GeometryProxy, V>, key: K.Type) -> some View where K.Value == V {
        // 读取【调用`overlay`之前以上的这部分视图】的`Geometry`信息，并通过`PreferenceKey`进行回传
        overlay {
            GeometryReader { proxy in
                //【注意】：不可以直接在【子视图内部】刷新父视图的State属性
                // self.xxx = proxy.size.height
                
                // 假设`xxx`是父视图的State属性，
                // 改变该属性就会影响里面子视图的布局，
                // 然后此处子视图的布局只要发生改变，又会改变这个State属性，
                // 从而又会让父视图重复去改变里面子视图的布局，周而复始，导致死循环。
                // 参考：https://zhuanlan.zhihu.com/p/447836445
                
                // 解决方案：使用`PreferenceKey` ---【能够在视图之间传递值】
                // PS：需要在`GeometryReader`里面放入一个视图才能读取到其坐标变化值，
                // 因此放一个透明颜色，同时也可以防止遮挡到底下视图。
                Color.clear
                    .preference(key: key, // PreferenceKey类型
                                value: proxy[keyPath: keyPath]) // 监听的值
            }
        }
    }
    
    func readGeometry<K: PreferenceKey, V: Equatable>(_ keyPath: KeyPath<GeometryProxy, V>, key: K.Type, perform action: @escaping (K.Value) -> Void) -> some View where K.Value == V {
        readGeometry(keyPath, key: key)
            .onPreferenceChange(key, perform: action)
    }
    
    // MARK: - Size
    
    func readSize<P: PreferenceKey>(key: P.Type) -> some View where P.Value == CGSize {
        readGeometry(\.size, key: key)
    }
    
    func readSize<P: PreferenceKey>(key: P.Type, perform action: @escaping (P.Value) -> Void) -> some View where P.Value == CGSize {
        readGeometry(\.size, key: key)
            .onPreferenceChange(key, perform: action)
    }
    
    // MARK: - Size.Width
    
    func readWidth<P: PreferenceKey>(key: P.Type) -> some View where P.Value == CGFloat {
        readGeometry(\.size.width, key: key)
    }
    
    func readWidth<P: PreferenceKey>(key: P.Type, perform action: @escaping (P.Value) -> Void) -> some View where P.Value == CGFloat {
        readGeometry(\.size.width, key: key)
            .onPreferenceChange(key, perform: action)
    }
    
    // MARK: - Size.Height
    
    func readHeight<P: PreferenceKey>(key: P.Type) -> some View where P.Value == CGFloat {
        readGeometry(\.size.height, key: key)
    }
    
    func readHeight<P: PreferenceKey>(key: P.Type, perform action: @escaping (P.Value) -> Void) -> some View where P.Value == CGFloat {
        readGeometry(\.size.height, key: key)
            .onPreferenceChange(key, perform: action)
    }
    
    // MARK: - SafeAreaInsets
    
    func readSafeAreaInsets<P: PreferenceKey>(key: P.Type) -> some View where P.Value == EdgeInsets {
        readGeometry(\.safeAreaInsets, key: key)
    }
    
    func readSafeAreaInsets<P: PreferenceKey>(key: P.Type, perform action: @escaping (P.Value) -> Void) -> some View where P.Value == EdgeInsets {
        readGeometry(\.safeAreaInsets, key: key)
            .onPreferenceChange(key, perform: action)
    }
    
    // MARK: - Frame
    
    func readFrame<P: PreferenceKey>(_ coordinateSpace: CoordinateSpace, key: P.Type) -> some View where P.Value == CGRect {
        self.overlay {
            GeometryReader { proxy in
                Color.clear
                    .preference(key: key, value: proxy.frame(in: coordinateSpace))
            }
        }
    }
    
    func readFrame<P: PreferenceKey>(_ coordinateSpace: CoordinateSpace, key: P.Type, perform action: @escaping (P.Value) -> Void) -> some View where P.Value == CGRect {
        readFrame(coordinateSpace, key: key)
            .onPreferenceChange(key, perform: action)
    }
    
}
