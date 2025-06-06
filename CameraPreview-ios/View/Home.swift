//
//  Home.swift
//  CameraPreview-ios
//
//  Created by Kritchanat on 4/3/2568 BE.
//

import SwiftUI
import SwiftData
import VisionKit

struct Home: View {
    
    /// View Properties
    @State private var showScannerView: Bool = false
    @State private var scanDocument: VNDocumentCameraScan?
    @State private var documentName: String = "New Document"
    @State private var askDocumentName: Bool = false
    @State private var isLoading: Bool = false
    @Query(sort: [.init(\Document.createdAt, order: .reverse)], animation: .snappy(duration: 0.25, extraBounce: 0))
    private var documents: [Document]
    
    // Environment Values
    @Namespace private var animationID
    @Environment(\.modelContext) private var context
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                LazyVGrid(columns: Array(repeating: GridItem(spacing: 10), count: 2), spacing: 15) {
                    ForEach(documents) { document in
                        NavigationLink {
                            DocumentDetailView(document: document)
                                .navigationTransition(.zoom(sourceID: document.uniqueViewID, in: animationID))
                        } label: {
                            DocumentCardView(document: document, animationID: animationID)
                                .foregroundStyle(Color.primary )
                        }
                    }
                }
                .padding(15)
            }
            .navigationTitle("Documents")
            .safeAreaInset(edge: .bottom) {
                CreateButton()
            }
        }
        .fullScreenCover(isPresented: $showScannerView)  {
            ScannerView { error in
                
            } didCancel: {
                /// Closing View
                showScannerView = false
            } didFinish: { scan in
                scanDocument = scan
                showScannerView = false
                askDocumentName = true
            }
            .ignoresSafeArea()
        }
        .alert("Document Name", isPresented: $askDocumentName) {
            TextField("New Document", text: $documentName)
            
            Button("Save") {
                createDocument()
            }
            .disabled(documentName.isEmpty)
        }
        .loadingScreen(status: $isLoading)
    }
    
    /// Custom Scan Document Button
    @ViewBuilder
    private func CreateButton() -> some View {
        
        VStack(spacing: 5) {
            Button(action: {
                showScannerView.toggle()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "document.viewfinder.fill")
                        .font(.title3)
                    
                    Text("Scan Document")
                }
                .foregroundStyle(.white)
                .fontWeight(.semibold)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(.purple.gradient, in: .capsule)
            }
            .hSpacing(.center)
            .padding(.vertical, 10)
            
            Button(action: {
                showScannerView.toggle()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "document.viewfinder.fill")
                        .font(.title3)
                    
                    Text("Scan Passport")
                }
                .foregroundStyle(.white)
                .fontWeight(.semibold)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(.blue.gradient, in: .capsule)
            }
            .hSpacing(.center)
            .padding(.vertical, 10)
        }
        
        
        /// Custom Progressive Background Effact
        .background {
            Rectangle()
                .fill(.background)
                .mask {
                    Rectangle()
                        .fill(.linearGradient(colors: [
                            .white.opacity(0),
                            .white.opacity(0.5),
                            .white,
                            .white
                        ], startPoint: .top, endPoint: .bottom))
                }
                .ignoresSafeArea()
        }
    }
    
    /// Helper Methods
    private func createDocument() {
        guard let scanDocument else { return }
        isLoading = true
        Task.detached(priority: .high) { [documentName] in
            let document = Document(name: documentName)
            var pages: [DocumentPage] = []
            
            for pageIndex in 0..<scanDocument.pageCount {
                let pageImage = scanDocument.imageOfPage(at: pageIndex)
                /// Coverting Image into Data
                /// Modify the compression value as per your needs.
                guard let pageData = pageImage.jpegData(compressionQuality: 0.65) else { return }
                let documentPage = DocumentPage(document: document, pageIndex: pageIndex, pageData: pageData)
                pages.append(documentPage)
            }
            
            document.pages = pages
            
            /// Saving data on main thread
            await MainActor.run {
                context.insert(document)
                try? context.save()
                
                /// Resetting Data
                self.scanDocument = nil
                isLoading = false
                self.documentName = "New Document"
            }
        }
    }
}

#Preview {
    ContentView()
}

