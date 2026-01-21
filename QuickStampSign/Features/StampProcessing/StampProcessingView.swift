import SwiftUI
import PhotosUI
import SwiftData

/// Main view for stamp processing functionality
public struct StampProcessingView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StampModel.createdDate, order: .reverse) private var stamps: [StampModel]
    @StateObject private var viewModel = StampProcessingViewModel()
    
    @State private var showingImagePicker = false
    @State private var showingBulkPicker = false
    @State private var selectedImages: [UIImage] = []
    @State private var stampName = ""
    @State private var showingNameDialog = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack {
                if stamps.isEmpty {
                    emptyStateView
                } else {
                    stampGridView
                }
            }
            .navigationTitle("Stamp Library")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingImagePicker = true }) {
                            Label("Add Single Stamp", systemImage: "plus.circle")
                        }
                        Button(action: { showingBulkPicker = true }) {
                            Label("Add Multiple Stamps", systemImage: "plus.rectangle.on.rectangle")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImages: $selectedImages) { images in
                    if let image = images.first {
                        selectedImages = [image]
                        showingNameDialog = true
                    }
                }
            }
            .sheet(isPresented: $showingBulkPicker) {
                ImagePicker(selectedImages: $selectedImages, allowsMultipleSelection: true) { images in
                    selectedImages = images
                    showingNameDialog = true
                }
            }
            .alert("Name Your Stamp", isPresented: $showingNameDialog) {
                TextField("Stamp name", text: $stampName)
                Button("Cancel", role: .cancel) {
                    selectedImages = []
                    stampName = ""
                }
                Button("Process") {
                    processSelectedImages()
                }
            }
            .overlay {
                if viewModel.isProcessing {
                    ProcessingOverlay(progress: viewModel.processingProgress)
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "seal.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No Stamps Yet")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Add stamps to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var stampGridView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 100), spacing: 16)
            ], spacing: 16) {
                ForEach(stamps) { stamp in
                    StampCard(stamp: stamp) {
                        deleteStamp(stamp)
                    }
                }
            }
            .padding()
        }
    }
    
    private func processSelectedImages() {
        guard !selectedImages.isEmpty else { return }
        
        Task {
            if selectedImages.count == 1, let image = selectedImages.first {
                await viewModel.processStamp(image, name: stampName)
                if let imageData = image.pngData {
                    let stamp = StampModel(name: stampName, imageData: imageData)
                    modelContext.insert(stamp)
                    try? modelContext.save()
                }
            } else {
                await viewModel.processBulkStamps(selectedImages, baseName: stampName)
                for (index, image) in selectedImages.enumerated() {
                    if let imageData = image.pngData {
                        let name = "\(stampName)_\(index + 1)"
                        let stamp = StampModel(name: name, imageData: imageData)
                        modelContext.insert(stamp)
                    }
                }
                try? modelContext.save()
            }
            
            selectedImages = []
            stampName = ""
        }
    }
    
    private func deleteStamp(_ stamp: StampModel) {
        modelContext.delete(stamp)
        try? modelContext.save()
    }
}

/// Card view for displaying a single stamp
struct StampCard: View {
    let stamp: StampModel
    let onDelete: () -> Void
    
    var body: some View {
        VStack {
            if let image = stamp.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80)
            }
            Text(stamp.name)
                .font(.caption)
                .lineLimit(1)
        }
        .frame(width: 100, height: 120)
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

/// Processing overlay with progress indicator
struct ProcessingOverlay: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView(value: progress)
                    .progressViewStyle(.circular)
                    .scaleEffect(1.5)
                
                Text("Processing...")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("\(Int(progress * 100))%")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            .padding(30)
            .background(Color.gray.opacity(0.9))
            .cornerRadius(16)
        }
    }
}

/// Image picker wrapper for PhotosUI
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    var allowsMultipleSelection = false
    var completion: ([UIImage]) -> Void
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = allowsMultipleSelection ? 0 : 1
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            var images: [UIImage] = []
            let group = DispatchGroup()
            
            for result in results {
                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                    defer { group.leave() }
                    if let image = object as? UIImage {
                        images.append(image)
                    }
                }
            }
            
            group.notify(queue: .main) {
                self.parent.completion(images)
            }
        }
    }
}
