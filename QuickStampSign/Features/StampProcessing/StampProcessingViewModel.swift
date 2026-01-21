import Foundation
import UIKit
import Combine

/// ViewModel for stamp processing functionality
@MainActor
public class StampProcessingViewModel: ObservableObject {
    
    @Published public var stamps: [StampModel] = []
    @Published public var isProcessing = false
    @Published public var processingProgress: Double = 0.0
    @Published public var errorMessage: String?
    
    private let imageProcessor: ImageProcessor
    private let storageManager: StorageManager
    
    public init(
        imageProcessor: ImageProcessor = ImageProcessor(),
        storageManager: StorageManager = .shared
    ) {
        self.imageProcessor = imageProcessor
        self.storageManager = storageManager
    }
    
    /// Process a single stamp image
    public func processStamp(_ image: UIImage, name: String) async {
        isProcessing = true
        processingProgress = 0.0
        errorMessage = nil
        
        do {
            processingProgress = 0.3
            
            // Remove background
            let noBackground = try await imageProcessor.removeBackground(from: image)
            processingProgress = 0.6
            
            // Optimize stamp
            let optimized = try await imageProcessor.optimizeStamp(noBackground)
            processingProgress = 0.9
            
            // Save to storage
            if let imageData = optimized.pngData {
                let stamp = StampModel(name: name, imageData: imageData)
                // Note: Actual saving would need ModelContext from SwiftUI view
                // stamps.append(stamp)
            }
            
            processingProgress = 1.0
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isProcessing = false
    }
    
    /// Process multiple stamps in bulk
    public func processBulkStamps(_ images: [UIImage], baseName: String) async {
        isProcessing = true
        processingProgress = 0.0
        errorMessage = nil
        
        do {
            let processed = try await imageProcessor.processBulkStamps(images)
            
            for (index, processedImage) in processed.enumerated() {
                if let imageData = processedImage.pngData {
                    let name = "\(baseName)_\(index + 1)"
                    let stamp = StampModel(name: name, imageData: imageData)
                    // stamps.append(stamp)
                }
                processingProgress = Double(index + 1) / Double(processed.count)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isProcessing = false
    }
    
    /// Delete a stamp
    public func deleteStamp(_ stamp: StampModel) {
        stamps.removeAll { $0.id == stamp.id }
    }
    
    /// Toggle favorite status
    public func toggleFavorite(_ stamp: StampModel) {
        stamp.isFavorite.toggle()
    }
    
    /// Update last used date
    public func markStampAsUsed(_ stamp: StampModel) {
        stamp.lastUsedDate = Date()
    }
}
