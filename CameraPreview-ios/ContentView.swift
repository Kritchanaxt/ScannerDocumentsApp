//
//  ContentView.swift
//  CameraPreview-ios
//
//  Created by Kritchanat on 4/3/2568 BE.
//

import SwiftUI

struct ContentView: View {
    
    @AppStorage("showIntroView") private var showIntroView: Bool = true
    var body: some View {
        Home()
            .sheet(isPresented: $showIntroView) {
                IntroScreen()
                    .interactiveDismissDisabled(true)
            }
    }
}

#Preview {
    ContentView()
}
