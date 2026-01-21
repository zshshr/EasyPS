# Contributing to QuickStamp & Sign

Thank you for your interest in contributing to QuickStamp & Sign! This document provides guidelines for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Making Changes](#making-changes)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)

## Code of Conduct

We are committed to providing a welcoming and inclusive environment for everyone. Please be respectful and constructive in all interactions.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/EasyPS.git`
3. Add upstream remote: `git remote add upstream https://github.com/zshshr/EasyPS.git`
4. Create a feature branch: `git checkout -b feature/your-feature-name`

## Development Setup

### Prerequisites

- macOS Sonoma or later
- Xcode 15.0 or later
- iOS 17.0+ SDK
- Swift 5.9+

### Initial Setup

```bash
cd EasyPS
open Package.swift
```

The project uses Swift Package Manager, so all dependencies are automatically managed.

## Making Changes

### Branch Naming Convention

- Feature: `feature/description`
- Bug fix: `bugfix/description`
- Documentation: `docs/description`
- Refactor: `refactor/description`

### Commit Messages

Follow the conventional commits format:

```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

Examples:
```
feat(stamp): add batch export functionality
fix(pdf): resolve overlay positioning issue
docs(readme): update installation instructions
```

## Coding Standards

### Swift Style Guide

Follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/):

1. **Naming**
   - Use descriptive names
   - Prefer clarity over brevity
   - Use camelCase for variables and functions
   - Use PascalCase for types

2. **Formatting**
   - Use 4 spaces for indentation
   - Maximum line length: 120 characters
   - Add newline at end of file

3. **Documentation**
   - Document public APIs with doc comments
   - Use `///` for single-line documentation
   - Use `/** ... */` for multi-line documentation

Example:
```swift
/// Processes a stamp image to remove background and enhance colors
/// - Parameter image: The input stamp image
/// - Returns: Processed image with transparent background
/// - Throws: ImageProcessorError if processing fails
public func processStamp(_ image: UIImage) async throws -> UIImage {
    // Implementation
}
```

### SwiftUI Guidelines

1. Extract complex views into separate components
2. Use `@State` for view-local state
3. Use `@StateObject` for observable objects owned by view
4. Use `@ObservedObject` for observable objects passed to view
5. Use `@Environment` for environment values

### Architecture

- Follow MVVM pattern
- Keep ViewModels testable (no UIKit dependencies)
- Use protocols for dependency injection
- Separate business logic from UI logic

## Testing

### Running Tests

```bash
swift test
```

### Writing Tests

1. **Unit Tests**
   - Test one thing at a time
   - Use descriptive test names
   - Follow AAA pattern (Arrange, Act, Assert)

Example:
```swift
func testRemoveBackgroundWithValidImage() async throws {
    // Arrange
    let testImage = createTestImage()
    
    // Act
    let result = try await imageProcessor.removeBackground(from: testImage)
    
    // Assert
    XCTAssertNotNil(result)
    XCTAssertEqual(result.size, testImage.size)
}
```

2. **UI Tests**
   - Test user workflows
   - Verify UI state changes
   - Check accessibility

### Test Coverage

Aim for:
- Unit tests: 80% coverage for business logic
- UI tests: Critical user paths

## Submitting Changes

### Pull Request Process

1. **Before submitting:**
   - Update from upstream: `git pull upstream main`
   - Ensure all tests pass
   - Update documentation if needed
   - Add tests for new features

2. **Creating the PR:**
   - Use a descriptive title
   - Reference related issues
   - Describe what changed and why
   - Include screenshots for UI changes

3. **PR Template:**
   ```markdown
   ## Description
   Brief description of changes
   
   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Breaking change
   - [ ] Documentation update
   
   ## Testing
   - [ ] Unit tests added/updated
   - [ ] UI tests added/updated
   - [ ] Manual testing performed
   
   ## Screenshots (if applicable)
   
   ## Checklist
   - [ ] Code follows project style guidelines
   - [ ] Self-review completed
   - [ ] Documentation updated
   - [ ] No new warnings generated
   ```

### Review Process

1. Maintainers will review your PR
2. Address feedback and push changes
3. Once approved, your PR will be merged

## Areas for Contribution

### High Priority

- [ ] Additional image filters for stamps
- [ ] Cloud storage integration
- [ ] Dark mode support
- [ ] iPad optimization
- [ ] Localization (additional languages)

### Medium Priority

- [ ] Signature templates
- [ ] Custom color themes
- [ ] Export to different formats
- [ ] Batch operations improvements

### Documentation

- [ ] Code examples
- [ ] Tutorial videos
- [ ] API documentation
- [ ] Troubleshooting guide

## Questions?

If you have questions, please:
1. Check existing issues and discussions
2. Create a new issue with the `question` label
3. Reach out to maintainers

## Recognition

Contributors will be recognized in:
- README.md Contributors section
- Release notes
- Project documentation

Thank you for contributing to QuickStamp & Sign! 🎉
