import SwiftUI
import SwiftData

/// Main application entry point
@main
struct QuickStampSignApp: App {
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .modelContainer(for: [
                    StampModel.self,
                    SignatureModel.self,
                    PDFDocumentModel.self
                ])
        }
    }
}

/// Main tab view containing all feature modules
struct MainTabView: View {
    
    var body: some View {
        TabView {
            StampProcessingView()
                .tabItem {
                    Label("Stamps", systemImage: "seal.fill")
                }
            
            SignatureView()
                .tabItem {
                    Label("Signatures", systemImage: "signature")
                }
            
            PDFEditorView()
                .tabItem {
                    Label("PDF", systemImage: "doc.fill")
                }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [
            StampModel.self,
            SignatureModel.self,
            PDFDocumentModel.self
        ], inMemory: true)
}
