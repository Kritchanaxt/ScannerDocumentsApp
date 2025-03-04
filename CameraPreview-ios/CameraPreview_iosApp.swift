//
//  CameraPreview_iosApp.swift
//  CameraPreview-ios
//
//  Created by Kritchanat on 4/3/2568 BE.
//

import SwiftUI

@main
struct CameraPreview_iosApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Document.self)
//            TestScanner()
        }
    }
}
