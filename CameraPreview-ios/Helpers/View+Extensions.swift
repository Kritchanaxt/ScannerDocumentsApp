//
//  View+Extensions.swift
//  CameraPreview-ios
//
//  Created by Kritchanat on 4/3/2568 BE.
//

import SwiftUI

/// Useful View Extension
extension View {
    @ViewBuilder
    func hSpacing(_ alignment: Alignment) -> some View {
        self
            .frame(maxWidth: . infinity, alignment: alignment)
    }
    
    @ViewBuilder
    func vSpacing(_ alignment: Alignment) -> some View {
        self
            .frame(maxHeight: .infinity, alignment: alignment)
    }
    
    /// Easy - to - use overlayed Loading Screen
    @ViewBuilder
    func loadingScreen(status: Binding<Bool>) -> some View {
        self
            .overlay {
                ZStack {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .frame(width: 40, height: 40)
                        .background(.bar, in: .rect(cornerRadius: 10))
                }
                .opacity(status.wrappedValue ? 1 : 0)
                .allowsHitTesting(status.wrappedValue)
                .animation(snappy, value: status.wrappedValue)
            }
    }
    
    var snappy: Animation {
        .snappy(duration: 0.25, extraBounce: 0)
    }
}
