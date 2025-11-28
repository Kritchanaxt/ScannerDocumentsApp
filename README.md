# ScanDocuments-iOS 

A native iOS document scanner application built with SwiftUI and SwiftData.

---

## 📷 Live Snapshot

<img src="https://github.com/Kritchanaxt/ScannerDocumentsApp/blob/main/snapshot.PNG" width="400" />

## 🎞️ Document Scanning in Action

![Scanning GIF](https://github.com/Kritchanaxt/ScannerDocumentsApp/blob/main/video_scandocument.gif)

---

## 📌 About the App

**ScanDocuments-iOS** is a native iOS application built with Swift and SwiftUI, designed to:

- ✅ Capture and scan documents using the camera
- ✅ Apply real-time perspective correction
- ✅ Extract and export clean, high-resolution scanned images
- ✅ Save documents persistently using SwiftData
- ✅ Lock documents with FaceID for security
- ✅ Export documents as PDF

### Technologies Used

| Technology | Purpose |
|------------|---------|
| `SwiftUI` | Modern declarative UI framework |
| `SwiftData` | Data persistence and management |
| `VisionKit` | Document camera and scanning |
| `PDFKit` | PDF generation and export |
| `LocalAuthentication` | FaceID/TouchID security |

---

## 🛠️ Requirements

- **Xcode**: 16.0 or later
- **iOS**: 18.2 or later
- **Swift**: 5.9 or later
- **Device**: iPhone with camera (for scanning functionality)

---

## 📥 Installation

### 1. Clone the Repository

```bash
git clone https://github.com/Kritchanaxt/ScannerDocumentsApp.git
cd ScannerDocumentsApp
```

### 2. Open in Xcode

```bash
open CameraPreview-ios.xcodeproj
```

### 3. Configure Signing

1. Open the project in Xcode
2. Select the project in the Navigator
3. Go to **Signing & Capabilities** tab
4. Select your **Team** from the dropdown
5. Change the **Bundle Identifier** if needed (e.g., `com.yourname.ScanDocuments`)

### 4. Add Required Permissions

Ensure the following keys are in your `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan documents.</string>
<key>NSFaceIDUsageDescription</key>
<string>This app uses Face ID to protect your documents.</string>
```

### 5. Build and Run

1. Select your target device or simulator
2. Press `Cmd + R` or click the **Run** button
3. For scanning functionality, use a **physical device** (camera is required)

---

## 📁 Project Structure

```
ScannerDocumentsApp/
├── CameraPreview-ios/
│   ├── CameraPreview_iosApp.swift    # App entry point with SwiftData container
│   ├── ContentView.swift              # Main content view with intro sheet
│   ├── TestScanner.swift              # Test scanner implementation
│   │
│   ├── Model/
│   │   ├── Document.swift             # Document data model (SwiftData)
│   │   └── DocumentPage.swift         # Document page model with image data
│   │
│   ├── View/
│   │   ├── Home.swift                 # Main home screen with document grid
│   │   ├── IntroScreen.swift          # Onboarding/intro screen
│   │   ├── ScannerView.swift          # VisionKit scanner wrapper
│   │   ├── DocumentDetailView.swift   # Document detail with pages
│   │   └── Helpers/
│   │       └── DocumentCardView.swift # Reusable document card component
│   │
│   ├── Helpers/
│   │   ├── CGSize_Extensions.swift    # CGSize utility extensions
│   │   └── View+Extensions.swift      # SwiftUI View extensions
│   │
│   ├── Assets.xcassets/               # App assets and icons
│   └── Preview Content/               # SwiftUI preview assets
│
├── CameraPreview-iosTests/            # Unit tests
│   └── CameraPreview_iosTests.swift
│
├── CameraPreview-iosUITests/          # UI tests
│   ├── CameraPreview_iosUITests.swift
│   └── CameraPreview_iosUITestsLaunchTests.swift
│
└── CameraPreview-ios.xcodeproj/       # Xcode project file
```

---

## 🚀 Usage

### Scanning a Document

1. Launch the app
2. Tap **"Scan Document"** button on the home screen
3. Position the camera over your document
4. The app will automatically detect document edges
5. Capture the document (manual or auto)
6. Add more pages if needed, then tap **Save**
7. Enter a name for your document

### Viewing Documents

- Documents appear in a grid on the home screen
- Tap any document to view its pages
- Swipe left/right to navigate between pages

### Locking Documents

1. Open a document
2. Tap the **lock icon** in the header
3. Document will require FaceID to unlock

### Exporting as PDF

1. Open a document
2. Tap the **share/export** button
3. Save or share the generated PDF

---

## 🧪 Testing

### Running Unit Tests

1. Open the project in Xcode
2. Press `Cmd + U` or go to **Product > Test**
3. Tests are located in `CameraPreview-iosTests/`

```bash
# Run tests via command line
xcodebuild test \
  -project CameraPreview-ios.xcodeproj \
  -scheme CameraPreview-ios \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

### Running UI Tests

1. Select the `CameraPreview-iosUITests` scheme
2. Press `Cmd + U` to run UI tests
3. Tests are located in `CameraPreview-iosUITests/`

### Test Structure

| Test File | Description |
|-----------|-------------|
| `CameraPreview_iosTests.swift` | Unit tests for models and logic |
| `CameraPreview_iosUITests.swift` | UI interaction tests |
| `CameraPreview_iosUITestsLaunchTests.swift` | App launch performance tests |

---

## 🔧 Key Components

### Document Model

```swift
@Model
class Document {
    var name: String
    var createdAt: Date
    var pages: [DocumentPage]?
    var isLocked: Bool
}
```

### DocumentPage Model

```swift
@Model
class DocumentPage {
    var document: Document?
    var pageIndex: Int
    @Attribute(.externalStorage)
    var pageData: Data  // JPEG image data
}
```

### ScannerView (VisionKit Wrapper)

```swift
struct ScannerView: UIViewControllerRepresentable {
    var didFinishWithError: (Error) -> ()
    var didCancel: () -> ()
    var didFinish: (VNDocumentCameraScan) -> ()
}
```

---

## 🎨 Features Overview

| Feature | Description |
|---------|-------------|
| 📷 **Document Scanning** | Use VisionKit for high-quality document capture |
| 💾 **SwiftData Persistence** | Documents saved locally with SwiftData |
| 🔒 **FaceID Lock** | Protect sensitive documents with biometric |
| 📄 **PDF Export** | Export multi-page documents as PDF |
| 🎞️ **Page Navigation** | Swipe through document pages |
| 🖼️ **Thumbnail Grid** | Beautiful grid layout with thumbnails |
| ✨ **Zoom Transitions** | Smooth navigation transitions |

---

## 🐛 Troubleshooting

### Camera Not Working
- Ensure you're testing on a **physical device**
- Check that camera permission is granted in Settings

### FaceID Not Working
- Test on a device with FaceID/TouchID
- Ensure the `NSFaceIDUsageDescription` key is in Info.plist

### Documents Not Saving
- Check that SwiftData container is properly configured
- Verify storage permissions

---

## 📝 License

This project is available for educational purposes.

---

## 👨‍💻 Author

Created by **Kritchanat** - March 2025

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## ⭐ Show Your Support

Give a ⭐️ if this project helped you!

