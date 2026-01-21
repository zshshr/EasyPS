import XCTest
@testable import QuickStampSign

/// Unit tests for ImageProcessor
final class ImageProcessorTests: XCTestCase {
    
    var imageProcessor: ImageProcessor!
    
    override func setUp() {
        super.setUp()
        imageProcessor = ImageProcessor()
    }
    
    override func tearDown() {
        imageProcessor = nil
        super.tearDown()
    }
    
    func testImageProcessorInitialization() {
        XCTAssertNotNil(imageProcessor, "ImageProcessor should be initialized")
    }
    
    func testRemoveBackgroundWithValidImage() async throws {
        // Create a simple test image
        let testImage = createTestImage(color: .red, size: CGSize(width: 100, height: 100))
        
        // Test background removal
        let result = try await imageProcessor.removeBackground(from: testImage)
        
        XCTAssertNotNil(result, "Result should not be nil")
        XCTAssertEqual(result.size, testImage.size, "Size should be preserved")
    }
    
    func testOptimizeStampWithValidImage() async throws {
        let testImage = createTestImage(color: .red, size: CGSize(width: 100, height: 100))
        
        let result = try await imageProcessor.optimizeStamp(testImage)
        
        XCTAssertNotNil(result, "Result should not be nil")
    }
    
    func testBulkProcessing() async throws {
        let images = [
            createTestImage(color: .red, size: CGSize(width: 100, height: 100)),
            createTestImage(color: .red, size: CGSize(width: 100, height: 100))
        ]
        
        let results = try await imageProcessor.processBulkStamps(images)
        
        XCTAssertEqual(results.count, images.count, "Should process all images")
    }
    
    // MARK: - Helper Methods
    
    private func createTestImage(color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
}
