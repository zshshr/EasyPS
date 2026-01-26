# QuickStamp & Sign - Electronic Contract Signing iOS App

<div align="center">

**EasyPS (快捷签章)** - A professional iOS application focused on electronic contract signing with AI-powered stamp processing and handwritten signature capabilities.

[![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)](https://www.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-3.0+-green.svg)](https://developer.apple.com/xcode/swiftui/)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](LICENSE)

</div>

## 📋 Overview

QuickStamp & Sign is a modern iOS application designed to streamline the electronic contract signing process. It combines AI-powered image processing with intuitive user interfaces to provide a seamless experience for managing stamps, signatures, and PDF documents.

## ✨ Core Features

### 1. 🎯 Intelligent Seal Processing

- **AI-Powered Edge Detection**: Automatically detect stamp boundaries using Vision framework
- **Background Removal**: Generate transparent PNG images with clean backgrounds
- **Stamp Optimization**: 
  - Anti-aliasing for smooth edges
  - Red color enhancement for traditional stamps
  - Noise reduction and cleaning
- **Bulk Processing**: Process multiple stamps simultaneously
- **Stamp Library**: Manage and organize frequently used stamps

**Technology Stack**: Vision framework, Core Image filters, HSV color space adjustments

### 2. ✍️ Handwritten Signature

- **Apple Pencil Integration**: Full pressure sensitivity support for natural writing
- **Smooth Canvas**: PencilKit-powered drawing experience
- **Signature Management**: Save and organize multiple signature styles
- **Drag & Drop Placement**: Intuitive signature placement on PDFs and images
- **Advanced Controls**: 
  - Resize signatures
  - Rotate to any angle
  - Adjust transparency

**Technology Stack**: PencilKit, SwiftUI DragGesture

### 3. 📄 PDF Document Processing

- **Image to PDF Conversion**: Convert single or multiple images to PDF
- **PDF Merging**: Combine multiple images into a single PDF document
- **Stamp & Signature Overlay**: Add stamps and signatures to existing PDFs
- **PDF Preview**: View and manage PDF pages
- **Page Management**: Navigate and organize PDF documents

**Technology Stack**: PDFKit framework

## 🏗️ Architecture

### Project Structure

```
EasyPS/
├── QuickStampSign/              # Main Project
│   ├── App/                     # Application Entry Point
│   │   └── QuickStampSignApp.swift
│   ├── Features/                # Functional Modules
│   │   ├── StampProcessing/     # Stamp Processing Feature
│   │   │   ├── StampProcessingViewModel.swift
│   │   │   └── StampProcessingView.swift
│   │   ├── Signature/           # Handwritten Signature Feature
│   │   │   └── SignatureView.swift
│   │   └── PDFEditor/           # PDF Editing Feature
│   │       ├── PDFProcessor.swift
│   │       └── PDFEditorView.swift
│   ├── Core/                    # Core Components
│   │   ├── ImageProcessor/      # Image Processing Engine
│   │   │   └── ImageProcessor.swift
│   │   ├── Storage/             # Data Storage Layer
│   │   │   ├── Models.swift
│   │   │   └── StorageManager.swift
│   │   └── Utils/               # Utility Classes
│   │       └── Extensions.swift
│   └── Resources/               # Asset Files
│       └── Info.plist
├── QuickStampSignTests/         # Unit Tests
│   ├── ImageProcessorTests.swift
│   └── PDFProcessorTests.swift
└── Package.swift                # Swift Package Configuration
```

### Technology Stack

| Component | Technology |
|-----------|-----------|
| **UI Framework** | SwiftUI 3.0+ |
| **Image Processing** | Vision, Core Image, Core Graphics |
| **Handwriting Input** | PencilKit |
| **PDF Handling** | PDFKit |
| **Data Storage** | SwiftData (iOS 17+) |
| **Concurrency** | Swift Concurrency (async/await) |
| **Minimum iOS** | iOS 17.0+ |
| **Language** | Swift 5.9+ |

## 🚀 Getting Started

### Prerequisites

- Xcode 15.0 or later
- iOS 17.0+ deployment target
- macOS Sonoma or later (for development)
- Apple Developer account (for device testing)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/zshshr/EasyPS.git
   cd EasyPS
   ```

2. **Open in Xcode**
   ```bash
   open Package.swift
   ```
   Or open the project in Xcode manually.

3. **Build and Run**
   - Select your target device or simulator
   - Press `Cmd + R` to build and run

### Swift Package Manager

This project uses Swift Package Manager for dependency management. All dependencies are Apple frameworks included with iOS, so no additional packages need to be installed.

## 📱 Usage Guide

### Stamp Processing

1. **Add a Stamp**
   - Tap the "+" button in the Stamps tab
   - Select "Add Single Stamp" or "Add Multiple Stamps"
   - Choose an image from your photo library
   - Enter a name for your stamp
   - The app will automatically process the stamp (remove background, enhance colors, optimize)

2. **Manage Stamps**
   - View all stamps in the grid view
   - Tap and hold for context menu options
   - Delete unwanted stamps by swiping left

### Creating Signatures

1. **Create New Signature**
   - Navigate to the Signatures tab
   - Tap the "+" button
   - Draw your signature using Apple Pencil or your finger
   - Tap "Clear" to start over if needed
   - Tap "Save" and enter a name

2. **Manage Signatures**
   - View all saved signatures
   - Delete signatures using the context menu

### PDF Document Management

1. **Create PDF from Images**
   - Go to the PDF tab
   - Tap the "+" button
   - Select one or multiple images
   - The app creates a PDF with all selected images

2. **Add Stamps/Signatures to PDF**
   - Tap on any PDF document
   - Use "Add Stamp" or "Add Signature" buttons
   - Select from your library
   - Adjust size, rotation, and opacity
   - Tap "Save" to apply changes

## 🧪 Testing

### Running Tests

```bash
# Run all tests
swift test

# Run specific test file
swift test --filter ImageProcessorTests
swift test --filter PDFProcessorTests
```

### Test Coverage

- **ImageProcessor**: Tests for background removal, stamp optimization, and bulk processing
- **PDFProcessor**: Tests for PDF creation, merging, and overlay operations
- **Storage**: Data model and persistence tests

## 🔧 Core Components

### ImageProcessor

The `ImageProcessor` class handles all image processing operations:

```swift
let processor = ImageProcessor()

// Remove background
let cleanImage = try await processor.removeBackground(from: image)

// Optimize stamp
let optimized = try await processor.optimizeStamp(image)

// Bulk processing
let processed = try await processor.processBulkStamps(images)
```

### PDFProcessor

The `PDFProcessor` class manages PDF operations:

```swift
let pdfProcessor = PDFProcessor()

// Convert images to PDF
let pdfData = pdfProcessor.convertImagesToPDF(images)

// Add overlay
let modified = pdfProcessor.addOverlayToPDF(
    pdfData,
    overlayImage: stamp,
    pageIndex: 0,
    position: CGPoint(x: 100, y: 100),
    size: CGSize(width: 100, height: 100)
)
```

### Storage Models

SwiftData models for persistent storage:

- **StampModel**: Store and manage stamp images
- **SignatureModel**: Store and manage signatures
- **PDFDocumentModel**: Store and manage PDF documents

## 🎨 UI Components

### StampProcessingView
- Grid-based stamp library
- Image picker integration
- Processing progress indicator
- Stamp management controls

### SignatureView
- PencilKit canvas for drawing
- Pressure-sensitive input
- Signature library grid
- Save and manage signatures

### PDFEditorView
- PDF document list
- Document preview with PDFKit
- Stamp/signature picker
- Overlay adjustment controls

## 🛠️ Development

### Code Style

- Follow Swift API Design Guidelines
- Use SwiftUI best practices
- Implement MVVM architecture pattern
- Use async/await for asynchronous operations
- Comprehensive error handling

### Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Apple for the excellent frameworks (Vision, Core Image, PencilKit, PDFKit)
- SwiftUI for modern declarative UI development
- SwiftData for seamless data persistence

## 📮 Contact

Project Link: [https://github.com/zshshr/EasyPS](https://github.com/zshshr/EasyPS)

---

<div align="center">
Made with ❤️ for the iOS development community
</div>