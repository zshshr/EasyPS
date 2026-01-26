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
    
    public init(imageProcessor: ImageProcessor = ImageProcessor()) {
        self.imageProcessor = imageProcessor
    }
    
    /// Process a single stamp image
    public func processStamp(_ image: UIImage, name: String) async -> UIImage? {
        isProcessing = true
        processingProgress = 0.0
        errorMessage = nil
        
        var processedImage: UIImage?
        
        do {
            processingProgress = 0.3
            
            // Remove background
            let noBackground = try await imageProcessor.removeBackground(from: image)
            processingProgress = 0.6
            
            // Optimize stamp
            let optimized = try await imageProcessor.optimizeStamp(noBackground)
            processingProgress = 0.9
            
            processedImage = optimized
            processingProgress = 1.0
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isProcessing = false
        return processedImage
    }
    
    /// Process multiple stamps in bulk
    public func processBulkStamps(_ images: [UIImage], baseName: String) async -> [UIImage] {
        isProcessing = true
        processingProgress = 0.0
        errorMessage = nil
        
        var processedImages: [UIImage] = []
        
        do {
            processedImages = try await imageProcessor.processBulkStamps(images)
            processingProgress = 1.0
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isProcessing = false
        return processedImages
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
