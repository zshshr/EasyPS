# QuickStamp & Sign - Technical Documentation

## Architecture Overview

### MVVM Pattern

The application follows the Model-View-ViewModel (MVVM) architectural pattern:

- **Models**: SwiftData models for data persistence (`StampModel`, `SignatureModel`, `PDFDocumentModel`)
- **Views**: SwiftUI views for UI presentation
- **ViewModels**: Observable objects managing business logic and state

### Data Flow

```
User Interaction → View → ViewModel → Core Services → Storage
                    ↑                                      ↓
                    └──────────── State Updates ──────────┘
```

## Core Components

### 1. Image Processing Engine

**File**: `QuickStampSign/Core/ImageProcessor/ImageProcessor.swift`

The `ImageProcessor` class provides comprehensive image processing capabilities:

#### Key Methods

```swift
// Edge detection using Vision framework
func detectStampEdges(in image: UIImage) async throws -> VNContoursObservation?

// Background removal with color masking
func removeBackground(from image: UIImage) async throws -> UIImage

// Stamp optimization (noise reduction, color enhancement, anti-aliasing)
func optimizeStamp(_ image: UIImage) async throws -> UIImage

// Concurrent bulk processing
func processBulkStamps(_ images: [UIImage]) async throws -> [UIImage]
```

#### Processing Pipeline

1. **Edge Detection**
   - Uses `VNDetectContoursRequest` from Vision framework
   - Detects stamp boundaries with configurable contrast adjustment
   - Returns contour observations for further processing

2. **Background Removal**
   - Converts image to HSV color space
   - Creates color mask for red tones (typical stamp color)
   - Applies mask to generate transparent PNG

3. **Optimization**
   - **Noise Reduction**: `CIFilter.noiseReduction()`
   - **Red Enhancement**: Color controls with saturation boost
   - **Anti-aliasing**: Gaussian blur with minimal radius
   - **Sharpening**: Luminance sharpening filter

4. **Bulk Processing**
   - Uses Swift Concurrency `TaskGroup`
   - Processes multiple stamps in parallel
   - Maintains original order in results

### 2. PDF Processing Engine

**File**: `QuickStampSign/Features/PDFEditor/PDFProcessor.swift`

The `PDFProcessor` class handles all PDF-related operations:

#### Key Methods

```swift
// Single image to PDF
func convertImageToPDF(_ image: UIImage) -> Data?

// Multiple images to single PDF
func convertImagesToPDF(_ images: [UIImage]) -> Data?

// Add overlay to specific page
func addOverlayToPDF(
    _ pdfData: Data,
    overlayImage: UIImage,
    pageIndex: Int,
    position: CGPoint,
    size: CGSize,
    rotation: CGFloat,
    alpha: CGFloat
) -> Data?

// Add overlay to all pages
func addOverlayToAllPages(
    _ pdfData: Data,
    overlayImage: UIImage,
    position: CGPoint,
    size: CGSize,
    rotation: CGFloat,
    alpha: CGFloat
) -> Data?

// Utility methods
func getPageCount(from pdfData: Data) -> Int
func generateThumbnail(from pdfData: Data, pageIndex: Int) -> UIImage?
func mergePDFs(_ pdfDataArray: [Data]) -> Data?
```

#### PDF Generation Process

1. **Image to PDF Conversion**
   - Creates PDF context with `UIGraphicsBeginPDFContextToData`
   - Draws each image as a separate page
   - Returns PDF data

2. **Overlay Application**
   - Loads existing PDF using PDFKit
   - Draws original page content
   - Applies transformations (position, rotation, scale, alpha)
   - Draws overlay image
   - Generates new PDF with modifications

### 3. Storage Layer

**File**: `QuickStampSign/Core/Storage/Models.swift`

SwiftData models for persistent storage:

#### StampModel

```swift
@Model
class StampModel {
    var id: UUID
    var name: String
    var imageData: Data
    var createdDate: Date
    var lastUsedDate: Date?
    var category: String
    var isFavorite: Bool
}
```

#### SignatureModel

```swift
@Model
class SignatureModel {
    var id: UUID
    var name: String
    var imageData: Data
    var createdDate: Date
    var lastUsedDate: Date?
    var style: String
    var isFavorite: Bool
}
```

#### PDFDocumentModel

```swift
@Model
class PDFDocumentModel {
    var id: UUID
    var name: String
    var pdfData: Data
    var createdDate: Date
    var modifiedDate: Date
    var pageCount: Int
    var thumbnailData: Data?
}
```

### 4. Storage Manager

**File**: `QuickStampSign/Core/Storage/StorageManager.swift`

Singleton manager for SwiftData operations:

```swift
class StorageManager {
    static let shared = StorageManager()
    
    // CRUD operations for stamps
    func saveStamp(_ stamp: StampModel, context: ModelContext)
    func deleteStamp(_ stamp: StampModel, context: ModelContext)
    func fetchStamps(context: ModelContext) -> [StampModel]
    
    // CRUD operations for signatures
    func saveSignature(_ signature: SignatureModel, context: ModelContext)
    func deleteSignature(_ signature: SignatureModel, context: ModelContext)
    func fetchSignatures(context: ModelContext) -> [SignatureModel]
    
    // CRUD operations for PDFs
    func savePDFDocument(_ document: PDFDocumentModel, context: ModelContext)
    func deletePDFDocument(_ document: PDFDocumentModel, context: ModelContext)
    func fetchPDFDocuments(context: ModelContext) -> [PDFDocumentModel]
}
```

## UI Components

### 1. Stamp Processing View

**File**: `QuickStampSign/Features/StampProcessing/StampProcessingView.swift`

Features:
- Grid-based stamp library using `LazyVGrid`
- Photo picker integration with `PHPickerViewController`
- Processing overlay with progress indicator
- Context menu for stamp management

### 2. Signature View

**File**: `QuickStampSign/Features/Signature/SignatureView.swift`

Features:
- PencilKit canvas with `PKCanvasView`
- Apple Pencil pressure sensitivity
- Drawing tools configuration
- Signature library grid

### 3. PDF Editor View

**File**: `QuickStampSign/Features/PDFEditor/PDFEditorView.swift`

Features:
- PDF document list with thumbnails
- PDF preview using `PDFView` from PDFKit
- Stamp/signature picker sheets
- Overlay adjustment controls (size, rotation, opacity)

## Performance Optimizations

### Image Processing

1. **Hardware Acceleration**
   - Uses Core Image with GPU acceleration
   - `CIContext` configured for hardware rendering

2. **Concurrent Processing**
   - Bulk processing uses `TaskGroup` for parallel execution
   - Async/await for non-blocking UI

3. **Memory Management**
   - Proper cleanup with `defer` statements
   - Context lifecycle management

### Storage

1. **Efficient Queries**
   - SwiftData `FetchDescriptor` with sorting
   - Lazy loading with `@Query` property wrapper

2. **Data Compression**
   - PNG compression for images
   - PDF optimization

## Error Handling

### ImageProcessorError

```swift
enum ImageProcessorError: Error {
    case invalidImage
    case processingFailed
    case noEdgesDetected
}
```

Error handling strategy:
- Async throws for error propagation
- User-facing error messages
- Graceful degradation

## Testing Strategy

### Unit Tests

1. **ImageProcessor Tests**
   - Background removal validation
   - Optimization pipeline testing
   - Bulk processing verification

2. **PDFProcessor Tests**
   - PDF generation from images
   - Page count verification
   - Overlay application testing
   - PDF merging validation

### Test Utilities

```swift
private func createTestImage(color: UIColor, size: CGSize) -> UIImage {
    // Creates colored test images for testing
}
```

## Future Enhancements

### Planned Features

1. **Advanced Image Processing**
   - Custom color filters for different stamp types
   - Batch auto-categorization
   - Cloud backup integration

2. **Enhanced PDF Features**
   - Multi-page editing
   - Annotation support
   - Form filling capabilities

3. **Signature Features**
   - Multiple pen types and colors
   - Signature templates
   - Auto-signature placement

4. **Collaboration**
   - Document sharing
   - Multi-user signing
   - Signing workflow management

## Dependencies

All dependencies are native Apple frameworks:

- **UIKit**: Core UI components
- **SwiftUI**: Modern UI framework
- **Vision**: AI-powered image analysis
- **Core Image**: Image processing filters
- **PencilKit**: Handwriting input
- **PDFKit**: PDF manipulation
- **SwiftData**: Data persistence
- **PhotosUI**: Photo picker

No third-party dependencies required.

## Build Configuration

### Minimum Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

### Deployment

The app can be deployed via:
- TestFlight for beta testing
- App Store for production release
- Enterprise distribution for corporate use

### Capabilities Required

- Photo Library access (for importing images)
- Camera access (optional, for capturing documents)
- File storage (for PDF export)

## Security Considerations

1. **Data Privacy**
   - All data stored locally using SwiftData
   - No network transmission of sensitive data
   - User-controlled data retention

2. **Image Processing**
   - Sanitization of input images
   - Safe handling of large images
   - Memory bounds checking

3. **PDF Handling**
   - Validation of PDF structure
   - Safe overlay operations
   - Prevention of malicious PDF injection

## Performance Metrics

Expected performance targets:

- **Single Stamp Processing**: < 2 seconds
- **Bulk Processing (10 stamps)**: < 10 seconds
- **PDF Generation**: < 1 second per page
- **Signature Creation**: Real-time (60fps)
- **App Launch**: < 2 seconds

## Accessibility

The app supports:

- VoiceOver for screen reading
- Dynamic Type for text scaling
- High contrast mode
- Reduced motion settings

## Localization

Currently supports:
- English (default)
- Chinese (Simplified) - partial

Localization framework in place for easy addition of new languages.

---

For questions or contributions, please refer to the main README.md file.
