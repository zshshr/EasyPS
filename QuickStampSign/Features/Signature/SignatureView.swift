import SwiftUI
import PencilKit
import SwiftData

/// Canvas view for creating handwritten signatures
public struct SignatureCanvasView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var canvasView = PKCanvasView()
    @State private var showingSaveDialog = false
    @State private var signatureName = ""
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack {
                // Drawing canvas
                CanvasRepresentable(canvasView: $canvasView)
                    .background(Color.white)
                    .border(Color.gray.opacity(0.3), width: 1)
                    .padding()
                
                // Instructions
                Text("Draw your signature with Apple Pencil or finger")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
            }
            .navigationTitle("Create Signature")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear") {
                        canvasView.drawing = PKDrawing()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        showingSaveDialog = true
                    }
                    .disabled(canvasView.drawing.bounds.isEmpty)
                }
            }
            .alert("Name Your Signature", isPresented: $showingSaveDialog) {
                TextField("Signature name", text: $signatureName)
                Button("Cancel", role: .cancel) {}
                Button("Save") {
                    saveSignature()
                }
            }
        }
    }
    
    private func saveSignature() {
        // Convert canvas to image
        let image = canvasView.drawing.image(
            from: canvasView.drawing.bounds,
            scale: UIScreen.main.scale
        )
        
        // Create transparent background version
        let transparentImage = createTransparentBackground(from: image)
        
        if let imageData = transparentImage.pngData {
            let signature = SignatureModel(
                name: signatureName.isEmpty ? "Signature \(Date().formatted())" : signatureName,
                imageData: imageData
            )
            modelContext.insert(signature)
            try? modelContext.save()
        }
        
        dismiss()
    }
    
    private func createTransparentBackground(from image: UIImage) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        defer { UIGraphicsEndImageContext() }
        
        image.draw(at: .zero)
        return UIGraphicsGetImageFromCurrentImageContext() ?? image
    }
}

/// UIViewRepresentable wrapper for PKCanvasView
struct CanvasRepresentable: UIViewRepresentable {
    
    @Binding var canvasView: PKCanvasView
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 3)
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        
        // Enable Apple Pencil interactions
        canvasView.drawingPolicy = .anyInput
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}

/// Main signature management view
public struct SignatureView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SignatureModel.createdDate, order: .reverse) private var signatures: [SignatureModel]
    
    @State private var showingCanvas = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack {
                if signatures.isEmpty {
                    emptyStateView
                } else {
                    signatureListView
                }
            }
            .navigationTitle("Signatures")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCanvas = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCanvas) {
                SignatureCanvasView()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "signature")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No Signatures Yet")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Create your first signature")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button(action: { showingCanvas = true }) {
                Label("Create Signature", systemImage: "pencil.tip.crop.circle")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
    
    private var signatureListView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 150), spacing: 16)
            ], spacing: 16) {
                ForEach(signatures) { signature in
                    SignatureCard(signature: signature) {
                        deleteSignature(signature)
                    }
                }
            }
            .padding()
        }
    }
    
    private func deleteSignature(_ signature: SignatureModel) {
        modelContext.delete(signature)
        try? modelContext.save()
    }
}

/// Card view for displaying a signature
struct SignatureCard: View {
    let signature: SignatureModel
    let onDelete: () -> Void
    
    var body: some View {
        VStack {
            if let image = signature.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80)
                    .padding()
            }
            
            Text(signature.name)
                .font(.caption)
                .lineLimit(1)
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
