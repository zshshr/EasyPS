import Foundation
import SwiftData
import UIKit

/// Model for storing stamp information
@Model
public final class StampModel {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var imageData: Data
    public var createdDate: Date
    public var lastUsedDate: Date?
    public var category: String
    public var isFavorite: Bool
    
    public init(
        id: UUID = UUID(),
        name: String,
        imageData: Data,
        createdDate: Date = Date(),
        lastUsedDate: Date? = nil,
        category: String = "General",
        isFavorite: Bool = false
    ) {
        self.id = id
        self.name = name
        self.imageData = imageData
        self.createdDate = createdDate
        self.lastUsedDate = lastUsedDate
        self.category = category
        self.isFavorite = isFavorite
    }
    
    /// Get UIImage from stored data
    public var image: UIImage? {
        UIImage(data: imageData)
    }
}

/// Model for storing signature information
@Model
public final class SignatureModel {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var imageData: Data
    public var createdDate: Date
    public var lastUsedDate: Date?
    public var style: String
    public var isFavorite: Bool
    
    public init(
        id: UUID = UUID(),
        name: String,
        imageData: Data,
        createdDate: Date = Date(),
        lastUsedDate: Date? = nil,
        style: String = "Default",
        isFavorite: Bool = false
    ) {
        self.id = id
        self.name = name
        self.imageData = imageData
        self.createdDate = createdDate
        self.lastUsedDate = lastUsedDate
        self.style = style
        self.isFavorite = isFavorite
    }
    
    /// Get UIImage from stored data
    public var image: UIImage? {
        UIImage(data: imageData)
    }
}

/// Model for storing PDF document information
@Model
public final class PDFDocumentModel {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var pdfData: Data
    public var createdDate: Date
    public var modifiedDate: Date
    public var pageCount: Int
    public var thumbnailData: Data?
    
    public init(
        id: UUID = UUID(),
        name: String,
        pdfData: Data,
        createdDate: Date = Date(),
        modifiedDate: Date = Date(),
        pageCount: Int = 0,
        thumbnailData: Data? = nil
    ) {
        self.id = id
        self.name = name
        self.pdfData = pdfData
        self.createdDate = createdDate
        self.modifiedDate = modifiedDate
        self.pageCount = pageCount
        self.thumbnailData = thumbnailData
    }
}
