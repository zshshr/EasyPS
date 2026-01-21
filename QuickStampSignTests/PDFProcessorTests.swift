import XCTest
@testable import QuickStampSign

/// Unit tests for PDFProcessor
final class PDFProcessorTests: XCTestCase {
    
    var pdfProcessor: PDFProcessor!
    
    override func setUp() {
        super.setUp()
        pdfProcessor = PDFProcessor()
    }
    
    override func tearDown() {
        pdfProcessor = nil
        super.tearDown()
    }
    
    func testPDFProcessorInitialization() {
        XCTAssertNotNil(pdfProcessor, "PDFProcessor should be initialized")
    }
    
    func testConvertSingleImageToPDF() {
        let testImage = createTestImage(color: .blue, size: CGSize(width: 100, height: 100))
        
        let pdfData = pdfProcessor.convertImageToPDF(testImage)
        
        XCTAssertNotNil(pdfData, "PDF data should not be nil")
        XCTAssertGreaterThan(pdfData?.count ?? 0, 0, "PDF data should have content")
    }
    
    func testConvertMultipleImagesToPDF() {
        let images = [
            createTestImage(color: .blue, size: CGSize(width: 100, height: 100)),
            createTestImage(color: .green, size: CGSize(width: 100, height: 100))
        ]
        
        let pdfData = pdfProcessor.convertImagesToPDF(images)
        
        XCTAssertNotNil(pdfData, "PDF data should not be nil")
        XCTAssertGreaterThan(pdfData?.count ?? 0, 0, "PDF data should have content")
    }
    
    func testGetPageCount() {
        let images = [
            createTestImage(color: .blue, size: CGSize(width: 100, height: 100)),
            createTestImage(color: .green, size: CGSize(width: 100, height: 100))
        ]
        
        guard let pdfData = pdfProcessor.convertImagesToPDF(images) else {
            XCTFail("Failed to create PDF")
            return
        }
        
        let pageCount = pdfProcessor.getPageCount(from: pdfData)
        XCTAssertEqual(pageCount, 2, "Should have 2 pages")
    }
    
    func testGenerateThumbnail() {
        let testImage = createTestImage(color: .blue, size: CGSize(width: 200, height: 200))
        
        guard let pdfData = pdfProcessor.convertImageToPDF(testImage) else {
            XCTFail("Failed to create PDF")
            return
        }
        
        let thumbnail = pdfProcessor.generateThumbnail(from: pdfData, pageIndex: 0)
        
        XCTAssertNotNil(thumbnail, "Thumbnail should not be nil")
    }
    
    func testMergePDFs() {
        let image1 = createTestImage(color: .blue, size: CGSize(width: 100, height: 100))
        let image2 = createTestImage(color: .green, size: CGSize(width: 100, height: 100))
        
        guard let pdf1 = pdfProcessor.convertImageToPDF(image1),
              let pdf2 = pdfProcessor.convertImageToPDF(image2) else {
            XCTFail("Failed to create PDFs")
            return
        }
        
        let mergedPDF = pdfProcessor.mergePDFs([pdf1, pdf2])
        
        XCTAssertNotNil(mergedPDF, "Merged PDF should not be nil")
        
        if let merged = mergedPDF {
            let pageCount = pdfProcessor.getPageCount(from: merged)
            XCTAssertEqual(pageCount, 2, "Merged PDF should have 2 pages")
        }
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
