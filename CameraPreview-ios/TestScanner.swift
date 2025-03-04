//
//  TestScanner.swift
//  CameraPreview-ios
//
//  Created by Kritchanat on 23/3/2568 BE.
//

import SwiftUI
import AVFoundation
import Vision

// Main view
struct TestScanner: View {
    @StateObject private var scannerViewModel = ScannerViewModel()
    
    var body: some View {
        ZStack {
            // Background color
            Color(UIColor.systemBackground)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Passport Scanner")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                ZStack {
                    // Camera view or result card
                    if scannerViewModel.scannedPassport == nil {
                        CameraView(scannerViewModel: scannerViewModel)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                    } else {
                        PassportCardView(passport: scannerViewModel.scannedPassport!, resetScan: {
                            scannerViewModel.reset()
                        })
                    }
                }
                .frame(height: 400)
                .padding()
                
                Spacer()
                
                // Instructions or scan button
                if scannerViewModel.scannedPassport == nil {
                    Text("Position your passport in the frame")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        scannerViewModel.scanning = true
                    }) {
                        Text("Scan Passport")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding()
                } else {
                    Button(action: {
                        scannerViewModel.reset()
                    }) {
                        Text("Scan Another")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
            
            // Loading overlay
            if scannerViewModel.isProcessing {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    ProgressView()
                        .scaleEffect(2)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    
                    Text("Processing...")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.top)
                }
            }
        }
        .alert(isPresented: $scannerViewModel.showAlert) {
            Alert(
                title: Text("Scanner Error"),
                message: Text(scannerViewModel.alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

// Camera view component
struct CameraView: View {
    @ObservedObject var scannerViewModel: ScannerViewModel
    
    var body: some View {
        CameraPreviewRepresentable(scannerViewModel: scannerViewModel)
            .overlay(
                ZStack {
                    // Passport scan frame guidance
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.yellow, lineWidth: 3)
                        .frame(width: 300, height: 200)
                    
                    // Status indicator
                    if scannerViewModel.scanning {
                        VStack {
                            Spacer()
                            Text("Scanning...")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(8)
                                .padding(.bottom)
                        }
                    }
                }
            )
    }
}

// Camera preview representable to bridge UIKit with SwiftUI
struct CameraPreviewRepresentable: UIViewRepresentable {
    @ObservedObject var scannerViewModel: ScannerViewModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 400))
        
        scannerViewModel.setupCamera(previewView: view)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Handle updates if needed
    }
}

// Passport data model
struct Passport {
    var fullName: String
    var passportNumber: String
    var nationality: String
    var dateOfBirth: String
    var expiryDate: String
    var gender: String
    var mrz: String // Machine Readable Zone text
}

// Passport result card view
struct PassportCardView: View {
    let passport: Passport
    let resetScan: () -> Void
    @State private var showCheckmark = false
    
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .shadow(radius: 5)
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("PASSPORT")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Success checkmark
                        if showCheckmark {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 28))
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    
                    Divider()
                        .background(Color.white.opacity(0.5))
                    
                    Group {
                        PassportField(label: "Full Name", value: passport.fullName)
                        PassportField(label: "Passport No.", value: passport.passportNumber)
                        PassportField(label: "Nationality", value: passport.nationality)
                        PassportField(label: "Date of Birth", value: passport.dateOfBirth)
                        PassportField(label: "Expiry Date", value: passport.expiryDate)
                        PassportField(label: "Gender", value: passport.gender)
                    }
                }
                .padding()
            }
            .padding()
            .onAppear {
                withAnimation(.spring().delay(0.5)) {
                    showCheckmark = true
                }
            }
        }
    }
}

struct PassportField: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
    }
}

// View model handling camera and passport processing
class ScannerViewModel: ObservableObject {
    @Published var scanning = false
    @Published var isProcessing = false
    @Published var scannedPassport: Passport?
    @Published var showAlert = false
    @Published var alertMessage = ""
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    func setupCamera(previewView: UIView) {
        // Permission check
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch authorizationStatus {
        case .authorized:
            setupCaptureSession(previewView: previewView)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupCaptureSession(previewView: previewView)
                    }
                } else {
                    self?.handleCameraPermissionDenied()
                }
            }
        default:
            handleCameraPermissionDenied()
        }
    }
    
    private func setupCaptureSession(previewView: UIView) {
        captureSession = AVCaptureSession()
        
        guard let captureSession = captureSession,
              let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            showCameraError("Could not initialize camera")
            return
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                showCameraError("Could not add video input")
                return
            }
            
            let photoOutput = AVCapturePhotoOutput()
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
                
                // Setup preview layer
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer?.frame = previewView.bounds
                previewLayer?.videoGravity = .resizeAspectFill
                
                if let previewLayer = previewLayer {
                    previewView.layer.addSublayer(previewLayer)
                }
                
                // Start capture session
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    self?.captureSession?.startRunning()
                }
                
                // Setup a timer to capture photo when scanning flag is true
                setupScanningTimer(photoOutput: photoOutput)
                
            } else {
                showCameraError("Could not add photo output")
                return
            }
            
        } catch {
            showCameraError("Error setting up camera: \(error.localizedDescription)")
        }
    }
    
    private func setupScanningTimer(photoOutput: AVCapturePhotoOutput) {
        // Timer to periodically check if scanning flag is true
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            if self.scanning && !self.isProcessing {
                self.takePicture(with: photoOutput)
            }
        }
    }
    
    private func takePicture(with photoOutput: AVCapturePhotoOutput) {
        isProcessing = true
        
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: PhotoCaptureDelegate(
            onCaptureComplete: { [weak self] image in
                self?.processPassportImage(image)
            },
            onCaptureFail: { [weak self] error in
                self?.isProcessing = false
                self?.showCameraError("Failed to capture photo: \(error)")
            }
        ))
    }
    
    private func processPassportImage(_ image: UIImage) {
        // Simulate passport OCR and MRZ reading
        // In a real app, you would use Vision framework for text detection
        // and specialized MRZ parsing libraries
        
        // Simulating a delay for processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            // Create sample passport data
            // In a real app, this would come from OCR and MRZ parsing
            let samplePassport = Passport(
                fullName: "JOHN SMITH",
                passportNumber: "AB1234567",
                nationality: "USA",
                dateOfBirth: "01 JAN 1980",
                expiryDate: "01 JAN 2030",
                gender: "M",
                mrz: "P<USASMITH<<JOHN<<<<<<<<<<<<<<<<<<<<<<\nAB1234567USA8001015M3001017<<<<<<<<<<<<<<"
            )
            
            self?.scannedPassport = samplePassport
            self?.scanning = false
            self?.isProcessing = false
        }
    }
    
    func reset() {
        scannedPassport = nil
        scanning = false
    }
    
    private func handleCameraPermissionDenied() {
        DispatchQueue.main.async { [weak self] in
            self?.showCameraError("Camera access is required to scan passports")
        }
    }
    
    private func showCameraError(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.alertMessage = message
            self?.showAlert = true
            self?.isProcessing = false
        }
    }
    
    deinit {
        captureSession?.stopRunning()
    }
}

// Photo capture delegate to handle camera capture callbacks
class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let onCaptureComplete: (UIImage) -> Void
    private let onCaptureFail: (String) -> Void
    
    init(onCaptureComplete: @escaping (UIImage) -> Void, onCaptureFail: @escaping (String) -> Void) {
        self.onCaptureComplete = onCaptureComplete
        self.onCaptureFail = onCaptureFail
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            onCaptureFail(error.localizedDescription)
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            onCaptureFail("Could not create image from captured data")
            return
        }
        
        onCaptureComplete(image)
    }
}

// Preview provider for SwiftUI canvas
struct TestScanner_Previews: PreviewProvider {
    static var previews: some View {
        TestScanner()
    }
}
