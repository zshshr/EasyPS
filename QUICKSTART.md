# QuickStamp & Sign - Quick Start Guide

This guide will help you get QuickStamp & Sign up and running on your development machine.

## Prerequisites

Before you begin, ensure you have:

- **macOS Sonoma (14.0)** or later
- **Xcode 15.0** or later
- **iOS 17.0+** SDK
- **Apple Developer Account** (for device testing)

## Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/zshshr/EasyPS.git
cd EasyPS
```

### 2. Open the Project

```bash
open Package.swift
```

Xcode will automatically resolve dependencies.

### 3. Configure Signing (Optional for Simulator)

If testing on a physical device:

1. Select the project in Xcode navigator
2. Select the QuickStampSign target
3. Go to "Signing & Capabilities"
4. Select your development team
5. Choose automatic signing

### 4. Build and Run

1. Select a simulator or connected device
2. Press `Cmd + R` or click the Play button
3. Wait for the build to complete

## First Run

### Using the Simulator

The iOS Simulator is sufficient for most development tasks:

1. **Stamp Processing**: Use the Photos app to add sample images
2. **Signature**: Works with mouse/trackpad (not pressure-sensitive without Pencil)
3. **PDF**: Full functionality available

### Using a Physical Device

For the complete experience, especially Apple Pencil support:

1. Connect your iPad or iPhone
2. Select it as the run destination
3. Build and run
4. Accept the developer certificate on device (Settings > General > VPN & Device Management)

## Testing Features

### 1. Stamp Processing

```
1. Tap "Stamps" tab
2. Tap "+" button
3. Select "Add Single Stamp"
4. Choose an image from Photos
5. Enter a name
6. Tap "Process"
7. View processed stamp in library
```

### 2. Signatures

```
1. Tap "Signatures" tab
2. Tap "+" button
3. Draw signature on canvas
4. Tap "Save"
5. Enter a name
6. View signature in library
```

### 3. PDF Creation

```
1. Tap "PDF" tab
2. Tap "+" button
3. Select one or more images
4. PDF is automatically created
5. Tap PDF to view/edit
```

### 4. Adding Stamps/Signatures to PDF

```
1. Open a PDF from the list
2. Tap "Add Stamp" or "Add Signature"
3. Select from your library
4. Adjust size, rotation, opacity
5. Tap "Save"
```

## Running Tests

### Unit Tests

```bash
# Command line
swift test

# Or in Xcode
Cmd + U
```

### Manual Testing Checklist

- [ ] Create and process a stamp
- [ ] Create a signature with drawing
- [ ] Convert images to PDF
- [ ] Add stamp to PDF
- [ ] Add signature to PDF
- [ ] Delete stamp from library
- [ ] Delete signature from library
- [ ] Delete PDF document

## Common Issues

### Build Failures

**Issue**: "Swift Compiler Error"
- **Solution**: Clean build folder (`Cmd + Shift + K`), then rebuild

**Issue**: "No such module 'SwiftData'"
- **Solution**: Ensure iOS deployment target is 17.0+

### Runtime Issues

**Issue**: "Photos access denied"
- **Solution**: In simulator Settings > Privacy > Photos, grant access

**Issue**: Blank screen on launch
- **Solution**: Check console for errors, ensure SwiftData container initialized

### Performance Issues

**Issue**: Slow image processing
- **Solution**: Use smaller test images initially, optimize in Core Image

## Development Workflow

### Making Changes

1. Create a feature branch
   ```bash
   git checkout -b feature/my-feature
   ```

2. Make your changes

3. Run tests
   ```bash
   swift test
   ```

4. Commit changes
   ```bash
   git add .
   git commit -m "feat: add my feature"
   ```

5. Push to remote
   ```bash
   git push origin feature/my-feature
   ```

6. Create Pull Request on GitHub

### Code Organization

```
QuickStampSign/
├── App/              # App entry point and main navigation
├── Features/         # Feature modules (Stamp, Signature, PDF)
├── Core/            # Shared components and utilities
└── Resources/       # Assets and configuration
```

### Adding New Features

1. Create feature directory under `Features/`
2. Add ViewModel for business logic
3. Add View for UI
4. Update main navigation if needed
5. Add tests in `QuickStampSignTests/`

## Debugging Tips

### Using Xcode Debugger

1. Set breakpoints by clicking line numbers
2. Use `po` command to print values
3. Use View Hierarchy debugger for UI issues

### Performance Profiling

1. Product > Profile (Cmd + I)
2. Select "Time Profiler"
3. Record and analyze

### Memory Debugging

1. Product > Profile (Cmd + I)
2. Select "Leaks"
3. Check for memory leaks

## Next Steps

1. **Explore the Code**: Start with `QuickStampSignApp.swift`
2. **Read Documentation**: Check `TECHNICAL.md` for architecture details
3. **Try Modifications**: Change colors, add features
4. **Contribute**: See `CONTRIBUTING.md` for guidelines

## Getting Help

- **Issues**: Check GitHub Issues
- **Questions**: Create a discussion
- **Bugs**: Report with reproduction steps

## Resources

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [PencilKit Documentation](https://developer.apple.com/documentation/pencilkit)
- [PDFKit Documentation](https://developer.apple.com/documentation/pdfkit)
- [Vision Framework](https://developer.apple.com/documentation/vision)
- [Core Image](https://developer.apple.com/documentation/coreimage)

---

Happy coding! 🚀
