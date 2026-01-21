import Foundation
import SwiftData

/// Storage manager for handling SwiftData operations
public class StorageManager {
    
    public static let shared = StorageManager()
    
    private var modelContainer: ModelContainer?
    
    private init() {
        setupModelContainer()
    }
    
    private func setupModelContainer() {
        let schema = Schema([
            StampModel.self,
            SignatureModel.self,
            PDFDocumentModel.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        do {
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            print("Failed to create ModelContainer: \(error)")
        }
    }
    
    public var container: ModelContainer? {
        return modelContainer
    }
    
    // MARK: - Stamp Operations
    
    @MainActor
    public func saveStamp(_ stamp: StampModel, context: ModelContext) {
        context.insert(stamp)
        try? context.save()
    }
    
    @MainActor
    public func deleteStamp(_ stamp: StampModel, context: ModelContext) {
        context.delete(stamp)
        try? context.save()
    }
    
    @MainActor
    public func fetchStamps(context: ModelContext) -> [StampModel] {
        let descriptor = FetchDescriptor<StampModel>(
            sortBy: [SortDescriptor(\.createdDate, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }
    
    // MARK: - Signature Operations
    
    @MainActor
    public func saveSignature(_ signature: SignatureModel, context: ModelContext) {
        context.insert(signature)
        try? context.save()
    }
    
    @MainActor
    public func deleteSignature(_ signature: SignatureModel, context: ModelContext) {
        context.delete(signature)
        try? context.save()
    }
    
    @MainActor
    public func fetchSignatures(context: ModelContext) -> [SignatureModel] {
        let descriptor = FetchDescriptor<SignatureModel>(
            sortBy: [SortDescriptor(\.createdDate, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }
    
    // MARK: - PDF Document Operations
    
    @MainActor
    public func savePDFDocument(_ document: PDFDocumentModel, context: ModelContext) {
        context.insert(document)
        try? context.save()
    }
    
    @MainActor
    public func deletePDFDocument(_ document: PDFDocumentModel, context: ModelContext) {
        context.delete(document)
        try? context.save()
    }
    
    @MainActor
    public func fetchPDFDocuments(context: ModelContext) -> [PDFDocumentModel] {
        let descriptor = FetchDescriptor<PDFDocumentModel>(
            sortBy: [SortDescriptor(\.modifiedDate, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }
}
