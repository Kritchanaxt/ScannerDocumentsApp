//
//  IntroScreen.swift
//  CameraPreview-ios
//
//  Created by Kritchanat on 4/3/2568 BE.
//

import SwiftUI

struct IntroScreen: View {
    
    @AppStorage("showIntroView") private var showIntroView: Bool = true
    var body: some View {
        VStack(spacing: 15) {
            Text("What's New in \n Document Scanner")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .padding(.top, 65)
                .padding(.bottom, 35)
            
            /// Points
            VStack(alignment: .leading, spacing: 25) {
                PointView(
                    title: "Scan Documents",
                    image: "scanner",
                    description: "Scan any document with ease."
                )
                PointView(
                    title: "Save Documents",
                    image: "tray.full.fill",
                    description: "Persist scanned documents with the new SwiftData Model."
                )
                PointView(
                    title: "Lock Document",
                    image: "faceid",
                    description: "Protect your documents so that only you can Unloack them using FaceID."
                )
            }
            .padding(.horizontal, 25)
            
            Spacer(minLength: 0)
            
            Button {
                showIntroView = false
            } label: {
                Text("Start using Document Scanner")
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .hSpacing(.center)
                    .padding(.vertical, 12)
                    .background(.purple.gradient, in: .capsule)
            }
        }
        .padding(15)
    }
    
    @ViewBuilder
    private func PointView(title: String, image: String, description: String) -> some View {
        HStack(spacing: 15) {
            Image(systemName: image)
                .font(.largeTitle)
                .foregroundStyle(.purple)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.title)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.callout)
                    .foregroundStyle(.gray)
            }
        }
    }
}

#Preview {
    IntroScreen()
}
