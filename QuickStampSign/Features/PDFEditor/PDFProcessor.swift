import Foundation
import UIKit
import PDFKit

/// PDF processing engine for document operations
public class PDFProcessor {
    
    public init() {}
    
    // MARK: - Image to PDF Conversion
    
    /// Convert a single image to PDF
    /// - Parameter image: Input image
    /// - Returns: PDF data
    public func convertImageToPDF(_ image: UIImage) -> Data? {
        let pdfData = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)
        defer { UIGraphicsEndPDFContext() }
        
        let pageRect = CGRect(origin: .zero, size: image.size)
        UIGraphicsBeginPDFPageWithInfo(pageRect, nil)
        
        image.draw(in: pageRect)
        
        return pdfData as Data
    }
    
    /// Convert multiple images to a single PDF
    /// - Parameter images: Array of images
    /// - Returns: Merged PDF data
    public func convertImagesToPDF(_ images: [UIImage]) -> Data? {
        guard !images.isEmpty else { return nil }
        
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)
        defer { UIGraphicsEndPDFContext() }
        
        for image in images {
            let pageRect = CGRect(origin: .zero, size: image.size)
            UIGraphicsBeginPDFPageWithInfo(pageRect, nil)
            image.draw(in: pageRect)
        }
        
        return pdfData as Data
    }
    
    // MARK: - Stamp/Signature Overlay
    
    /// Add stamp or signature to PDF page
    /// - Parameters:
    ///   - pdfData: Original PDF data
    ///   - overlayImage: Stamp or signature image
    ///   - pageIndex: Page index to add overlay (0-based)
    ///   - position: Position on page
    ///   - size: Size of overlay
    ///   - rotation: Rotation angle in degrees
    ///   - alpha: Transparency (0.0 to 1.0)
    /// - Returns: Modified PDF data
    public func addOverlayToPDF(
        _ pdfData: Data,
        overlayImage: UIImage,
        pageIndex: Int,
        position: CGPoint,
        size: CGSize,
        rotation: CGFloat = 0,
        alpha: CGFloat = 1.0
    ) -> Data? {
        guard let document = PDFDocument(data: pdfData),
              pageIndex < document.pageCount,
              let page = document.page(at: pageIndex) else {
            return nil
        }
        
        let pageBounds = page.bounds(for: .mediaBox)
        
        // Create PDF context for the modified page
        let outputData = NSMutableData()
        UIGraphicsBeginPDFContextToData(outputData, pageBounds, nil)
        defer { UIGraphicsEndPDFContext() }
        
        UIGraphicsBeginPDFPage()
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        // Draw original page
        context.saveGState()
        page.draw(with: .mediaBox, to: context)
        context.restoreGState()
        
        // Draw overlay
        context.saveGState()
        
        // Apply transformations
        let overlayRect = CGRect(origin: position, size: size)
        context.translateBy(x: overlayRect.midX, y: overlayRect.midY)
        context.rotate(by: rotation * .pi / 180)
        context.translateBy(x: -overlayRect.midX, y: -overlayRect.midY)
        
        overlayImage.draw(in: overlayRect, blendMode: .normal, alpha: alpha)
        
        context.restoreGState()
        
        return outputData as Data
    }
    
    /// Add overlay to all pages of a PDF
    /// - Parameters:
    ///   - pdfData: Original PDF data
    ///   - overlayImage: Stamp or signature image
    ///   - position: Position on each page
    ///   - size: Size of overlay
    ///   - rotation: Rotation angle in degrees
    ///   - alpha: Transparency
    /// - Returns: Modified PDF data
    public func addOverlayToAllPages(
        _ pdfData: Data,
        overlayImage: UIImage,
        position: CGPoint,
        size: CGSize,
        rotation: CGFloat = 0,
        alpha: CGFloat = 1.0
    ) -> Data? {
        guard let document = PDFDocument(data: pdfData) else {
            return nil
        }
        
        let outputData = NSMutableData()
        UIGraphicsBeginPDFContextToData(outputData, .zero, nil)
        defer { UIGraphicsEndPDFContext() }
        
        for pageIndex in 0..<document.pageCount {
            guard let page = document.page(at: pageIndex) else { continue }
            
            let pageBounds = page.bounds(for: .mediaBox)
            UIGraphicsBeginPDFPageWithInfo(pageBounds, nil)
            
            guard let context = UIGraphicsGetCurrentContext() else { continue }
            
            // Draw original page
            context.saveGState()
            page.draw(with: .mediaBox, to: context)
            context.restoreGState()
            
            // Draw overlay
            context.saveGState()
            
            let overlayRect = CGRect(origin: position, size: size)
            context.translateBy(x: overlayRect.midX, y: overlayRect.midY)
            context.rotate(by: rotation * .pi / 180)
            context.translateBy(x: -overlayRect.midX, y: -overlayRect.midY)
            
            overlayImage.draw(in: overlayRect, blendMode: .normal, alpha: alpha)
            
            context.restoreGState()
        }
        
        return outputData as Data
    }
    
    // MARK: - PDF Utilities
    
    /// Get page count from PDF data
    public func getPageCount(from pdfData: Data) -> Int {
        guard let document = PDFDocument(data: pdfData) else {
            return 0
        }
        return document.pageCount
    }
    
    /// Generate thumbnail for PDF page
    /// - Parameters:
    ///   - pdfData: PDF data
    ///   - pageIndex: Page index (0-based)
    ///   - size: Desired thumbnail size
    /// - Returns: Thumbnail image
    public func generateThumbnail(
        from pdfData: Data,
        pageIndex: Int,
        size: CGSize = CGSize(width: 200, height: 200)
    ) -> UIImage? {
        guard let document = PDFDocument(data: pdfData),
              pageIndex < document.pageCount,
              let page = document.page(at: pageIndex) else {
            return nil
        }
        
        let pageBounds = page.bounds(for: .mediaBox)
        let scale = min(size.width / pageBounds.width, size.height / pageBounds.height)
        let scaledSize = CGSize(
            width: pageBounds.width * scale,
            height: pageBounds.height * scale
        )
        
        UIGraphicsBeginImageContextWithOptions(scaledSize, true, 0)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(origin: .zero, size: scaledSize))
        
        context.saveGState()
        context.scaleBy(x: scale, y: scale)
        page.draw(with: .mediaBox, to: context)
        context.restoreGState()
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// Merge multiple PDF files
    /// - Parameter pdfDataArray: Array of PDF data to merge
    /// - Returns: Merged PDF data
    public func mergePDFs(_ pdfDataArray: [Data]) -> Data? {
        guard !pdfDataArray.isEmpty else { return nil }
        
        let mergedDocument = PDFDocument()
        
        var currentPageIndex = 0
        for pdfData in pdfDataArray {
            guard let document = PDFDocument(data: pdfData) else { continue }
            
            for pageIndex in 0..<document.pageCount {
                guard let page = document.page(at: pageIndex) else { continue }
                mergedDocument.insert(page, at: currentPageIndex)
                currentPageIndex += 1
            }
        }
        
        return mergedDocument.dataRepresentation()
    }
}
