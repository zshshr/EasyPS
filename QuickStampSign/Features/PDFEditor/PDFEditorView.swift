import SwiftUI
import PDFKit
import PhotosUI
import SwiftData

/// Main PDF editor view with document management
public struct PDFEditorView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PDFDocumentModel.modifiedDate, order: .reverse) private var documents: [PDFDocumentModel]
    
    @State private var showingImagePicker = false
    @State private var showingDocumentEditor = false
    @State private var selectedDocument: PDFDocumentModel?
    @State private var selectedImages: [UIImage] = []
    
    private let pdfProcessor = PDFProcessor()
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack {
                if documents.isEmpty {
                    emptyStateView
                } else {
                    documentListView
                }
            }
            .navigationTitle("PDF Documents")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingImagePicker = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImages: $selectedImages, allowsMultipleSelection: true) { images in
                    createPDFFromImages(images)
                }
            }
            .sheet(item: $selectedDocument) { document in
                PDFDocumentEditorView(document: document)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No PDF Documents")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Create a PDF from images")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button(action: { showingImagePicker = true }) {
                Label("Create PDF", systemImage: "plus.circle")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
    
    private var documentListView: some View {
        List {
            ForEach(documents) { document in
                DocumentRow(document: document)
                    .onTapGesture {
                        selectedDocument = document
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            deleteDocument(document)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
    }
    
    private func createPDFFromImages(_ images: [UIImage]) {
        guard !images.isEmpty else { return }
        
        if let pdfData = pdfProcessor.convertImagesToPDF(images) {
            let document = PDFDocumentModel(
                name: "Document \(Date().formatted())",
                pdfData: pdfData,
                pageCount: images.count
            )
            
            // Generate thumbnail
            if let thumbnail = pdfProcessor.generateThumbnail(from: pdfData, pageIndex: 0),
               let thumbnailData = thumbnail.pngData {
                document.thumbnailData = thumbnailData
            }
            
            modelContext.insert(document)
            try? modelContext.save()
        }
        
        selectedImages = []
    }
    
    private func deleteDocument(_ document: PDFDocumentModel) {
        modelContext.delete(document)
        try? modelContext.save()
    }
}

/// Row view for displaying a PDF document
struct DocumentRow: View {
    let document: PDFDocumentModel
    
    var body: some View {
        HStack {
            if let thumbnailData = document.thumbnailData,
               let thumbnail = UIImage(data: thumbnailData) {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 80)
                    .cornerRadius(4)
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 80)
                    .overlay(
                        Image(systemName: "doc.fill")
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(document.name)
                    .font(.headline)
                
                Text("\(document.pageCount) pages")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Modified: \(document.modifiedDate.formatted())")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

/// PDF document editor with stamp/signature overlay
struct PDFDocumentEditorView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var stamps: [StampModel]
    @Query private var signatures: [SignatureModel]
    
    let document: PDFDocumentModel
    
    @State private var pdfView = PDFView()
    @State private var showingStampPicker = false
    @State private var showingSignaturePicker = false
    @State private var selectedOverlay: UIImage?
    @State private var overlayPosition: CGPoint = CGPoint(x: 100, y: 100)
    @State private var overlaySize: CGSize = CGSize(width: 100, height: 100)
    @State private var overlayRotation: CGFloat = 0
    @State private var overlayAlpha: CGFloat = 1.0
    
    private let pdfProcessor = PDFProcessor()
    
    var body: some View {
        NavigationView {
            VStack {
                // PDF Preview
                PDFViewRepresentable(pdfView: $pdfView, pdfData: document.pdfData)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Overlay controls
                if selectedOverlay != nil {
                    overlayControlsView
                }
                
                // Action buttons
                HStack(spacing: 20) {
                    Button(action: { showingStampPicker = true }) {
                        Label("Add Stamp", systemImage: "seal")
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: { showingSignaturePicker = true }) {
                        Label("Add Signature", systemImage: "signature")
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            }
            .navigationTitle(document.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        savePDF()
                    }
                    .disabled(selectedOverlay == nil)
                }
            }
            .sheet(isPresented: $showingStampPicker) {
                StampPickerView(stamps: stamps) { stamp in
                    selectedOverlay = stamp.image
                }
            }
            .sheet(isPresented: $showingSignaturePicker) {
                SignaturePickerView(signatures: signatures) { signature in
                    selectedOverlay = signature.image
                }
            }
        }
    }
    
    private var overlayControlsView: some View {
        VStack(spacing: 10) {
            Text("Adjust Overlay")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Text("Size:")
                Slider(value: Binding(
                    get: { overlaySize.width },
                    set: { overlaySize = CGSize(width: $0, height: $0) }
                ), in: 50...300)
            }
            
            HStack {
                Text("Rotation:")
                Slider(value: $overlayRotation, in: 0...360)
            }
            
            HStack {
                Text("Opacity:")
                Slider(value: $overlayAlpha, in: 0.1...1.0)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
    
    private func savePDF() {
        guard let overlay = selectedOverlay else { return }
        
        // Get current page index
        let currentPage = pdfView.currentPage
        let pageIndex = currentPage.flatMap { pdfView.document?.index(for: $0) } ?? 0
        
        // Apply overlay
        if let modifiedData = pdfProcessor.addOverlayToPDF(
            document.pdfData,
            overlayImage: overlay,
            pageIndex: pageIndex,
            position: overlayPosition,
            size: overlaySize,
            rotation: overlayRotation,
            alpha: overlayAlpha
        ) {
            document.pdfData = modifiedData
            document.modifiedDate = Date()
            try? modelContext.save()
        }
        
        dismiss()
    }
}

/// PDF view representable
struct PDFViewRepresentable: UIViewRepresentable {
    
    @Binding var pdfView: PDFView
    let pdfData: Data
    
    func makeUIView(context: Context) -> PDFView {
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        
        if let document = PDFDocument(data: pdfData) {
            pdfView.document = document
        }
        
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {}
}

/// Stamp picker view
struct StampPickerView: View {
    let stamps: [StampModel]
    let onSelect: (StampModel) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                    ForEach(stamps) { stamp in
                        Button(action: {
                            onSelect(stamp)
                            dismiss()
                        }) {
                            VStack {
                                if let image = stamp.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 80)
                                }
                                Text(stamp.name)
                                    .font(.caption)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Select Stamp")
        }
    }
}

/// Signature picker view
struct SignaturePickerView: View {
    let signatures: [SignatureModel]
    let onSelect: (SignatureModel) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                    ForEach(signatures) { signature in
                        Button(action: {
                            onSelect(signature)
                            dismiss()
                        }) {
                            VStack {
                                if let image = signature.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 80)
                                }
                                Text(signature.name)
                                    .font(.caption)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Select Signature")
        }
    }
}
