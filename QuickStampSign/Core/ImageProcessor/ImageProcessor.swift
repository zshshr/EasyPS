import UIKit
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins

/// Core image processing engine for stamp detection and optimization
public class ImageProcessor {
    
    public init() {}
    
    // Create context on demand for better concurrency
    private var context: CIContext {
        CIContext(options: [.useSoftwareRenderer: false])
    }
    
    // MARK: - Stamp Edge Detection
    
    /// Detect stamp edges using Vision framework
    /// - Parameter image: Input image containing a stamp
    /// - Returns: Detected contours as VNContoursObservation
    public func detectStampEdges(in image: UIImage) async throws -> VNContoursObservation? {
        guard let ciImage = CIImage(image: image) else {
            throw ImageProcessorError.invalidImage
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectContoursRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let results = request.results as? [VNContoursObservation],
                      let topContour = results.first else {
                    continuation.resume(returning: nil)
                    return
                }
                
                continuation.resume(returning: topContour)
            }
            
            request.contrastAdjustment = 2.0
            request.detectsDarkOnLight = false
            
            let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    // MARK: - Background Removal
    
    /// Remove background and generate transparent PNG
    /// - Parameter image: Input image
    /// - Returns: Image with transparent background
    public func removeBackground(from image: UIImage) async throws -> UIImage {
        guard let ciImage = CIImage(image: image) else {
            throw ImageProcessorError.invalidImage
        }
        
        // Create mask for red areas (typical stamp color)
        let redMask = createRedColorMask(from: ciImage)
        
        // Apply mask to create transparent background
        let outputImage = applyTransparency(to: ciImage, using: redMask)
        
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            throw ImageProcessorError.processingFailed
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    // MARK: - Stamp Optimization
    
    /// Optimize stamp: anti-aliasing, red enhancement, noise cleaning
    /// - Parameter image: Input stamp image
    /// - Returns: Optimized stamp image
    public func optimizeStamp(_ image: UIImage) async throws -> UIImage {
        guard let ciImage = CIImage(image: image) else {
            throw ImageProcessorError.invalidImage
        }
        
        var processedImage = ciImage
        
        // Step 1: Noise reduction
        processedImage = reduceNoise(in: processedImage)
        
        // Step 2: Enhance red color
        processedImage = enhanceRedColor(in: processedImage)
        
        // Step 3: Anti-aliasing (smooth edges)
        processedImage = applyAntiAliasing(to: processedImage)
        
        // Step 4: Sharpen details
        processedImage = sharpenImage(processedImage)
        
        guard let cgImage = context.createCGImage(processedImage, from: processedImage.extent) else {
            throw ImageProcessorError.processingFailed
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    // MARK: - Bulk Processing
    
    /// Process multiple stamps simultaneously
    /// - Parameter images: Array of input images
    /// - Returns: Array of processed images
    public func processBulkStamps(_ images: [UIImage]) async throws -> [UIImage] {
        try await withThrowingTaskGroup(of: (Int, UIImage).self) { group in
            for (index, image) in images.enumerated() {
                group.addTask {
                    let noBackground = try await self.removeBackground(from: image)
                    let optimized = try await self.optimizeStamp(noBackground)
                    return (index, optimized)
                }
            }
            
            var results: [(Int, UIImage)] = []
            for try await result in group {
                results.append(result)
            }
            
            return results.sorted { $0.0 < $1.0 }.map { $0.1 }
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func createRedColorMask(from image: CIImage) -> CIImage {
        // Create color cube filter for red isolation
        let hueRange: Float = 0.05 // Red hue tolerance
        let size = 64
        var cubeData = [Float](repeating: 0, count: size * size * size * 4)
        
        var offset = 0
        for blue in 0..<size {
            for green in 0..<size {
                for red in 0..<size {
                    let r = Float(red) / Float(size - 1)
                    let g = Float(green) / Float(size - 1)
                    let b = Float(blue) / Float(size - 1)
                    
                    // Calculate HSV
                    let maxVal = max(r, g, b)
                    let minVal = min(r, g, b)
                    let delta = maxVal - minVal
                    
                    var hue: Float = 0
                    if delta > 0 {
                        if maxVal == r {
                            hue = (g - b) / delta
                            if hue < 0 { hue += 6.0 }
                        }
                    }
                    hue /= 6.0
                    
                    let saturation = maxVal > 0 ? delta / maxVal : 0
                    
                    // Keep red colors (hue near 0 or 1), high saturation
                    let isRed = (hue < hueRange || hue > (1.0 - hueRange)) && saturation > 0.3
                    let alpha: Float = isRed ? 1.0 : 0.0
                    
                    cubeData[offset] = r
                    cubeData[offset + 1] = g
                    cubeData[offset + 2] = b
                    cubeData[offset + 3] = alpha
                    offset += 4
                }
            }
        }
        
        let data = Data(bytes: cubeData, count: cubeData.count * MemoryLayout<Float>.size)
        let filter = CIFilter.colorCube()
        filter.inputImage = image
        filter.cubeDimension = Float(size)
        filter.cubeData = data
        
        return filter.outputImage ?? image
    }
    
    private func applyTransparency(to image: CIImage, using mask: CIImage) -> CIImage {
        let filter = CIFilter.blendWithMask()
        filter.inputImage = image
        filter.backgroundImage = CIImage(color: .clear).cropped(to: image.extent)
        filter.maskImage = mask
        return filter.outputImage ?? image
    }
    
    private func reduceNoise(in image: CIImage) -> CIImage {
        let filter = CIFilter.noiseReduction()
        filter.inputImage = image
        filter.noiseLevel = 0.02
        filter.sharpness = 0.4
        return filter.outputImage ?? image
    }
    
    private func enhanceRedColor(in image: CIImage) -> CIImage {
        // Use color controls to boost red channel
        let filter = CIFilter.colorControls()
        filter.inputImage = image
        filter.saturation = 1.2
        filter.brightness = 0.05
        filter.contrast = 1.1
        
        guard let saturatedImage = filter.outputImage else { return image }
        
        // Apply hue adjustment to intensify red
        let hueFilter = CIFilter.hueAdjust()
        hueFilter.inputImage = saturatedImage
        hueFilter.angle = 0.0
        
        return hueFilter.outputImage ?? saturatedImage
    }
    
    private func applyAntiAliasing(to image: CIImage) -> CIImage {
        let filter = CIFilter.gaussianBlur()
        filter.inputImage = image
        filter.radius = 0.5
        return filter.outputImage ?? image
    }
    
    private func sharpenImage(_ image: CIImage) -> CIImage {
        let filter = CIFilter.sharpenLuminance()
        filter.inputImage = image
        filter.sharpness = 0.4
        return filter.outputImage ?? image
    }
}

// MARK: - Error Types

public enum ImageProcessorError: Error {
    case invalidImage
    case processingFailed
    case noEdgesDetected
    
    public var localizedDescription: String {
        switch self {
        case .invalidImage:
            return "Invalid image format"
        case .processingFailed:
            return "Image processing failed"
        case .noEdgesDetected:
            return "No edges detected in image"
        }
    }
}
