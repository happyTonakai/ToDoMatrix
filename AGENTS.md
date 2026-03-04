# AGENTS.md - TodoMatrix Development Guide

## Project Overview
- **Project Name**: TodoMatrix
- **Platform**: macOS 15+ (Sequoia)
- **Language**: Swift (SwiftUI)
- **Data Storage**: Local JSON file at `~/Library/Application Support/TodoMatrix/tasks.json`

## Build & Development Commands

### Building the Project
```bash
# Build using xcodebuild
xcodebuild -project TodoMatrix.xcodeproj -scheme TodoMatrix -configuration Debug build

# Build for release
xcodebuild -project TodoMatrix.xcodeproj -scheme TodoMatrix -configuration Release build

# Or use xcodebuild with derivedData
xcodebuild -project TodoMatrix.xcodeproj -scheme TodoMatrix -derivedDataPath ./DerivedData build
```

### Running Tests
```bash
# Run all tests
xcodebuild test -project TodoMatrix.xcodeproj -scheme TodoMatrix

# Run tests for a specific destination
xcodebuild test -project TodoMatrix.xcodeproj -scheme TodoMatrix -destination 'platform=macOS'

# Run a single test class
xcodebuild test -project TodoMatrix.xcodeproj -scheme TodoMatrix -only-testing:TaskTests

# Run a single test method
xcodebuild test -project TodoMatrix.xcodeproj -scheme TodoMatrix -only-testing:TaskTests/testTaskCreation
```

### Code Quality Tools
```bash
# SwiftLint (if installed via Homebrew)
swiftlint

# SwiftFormat (if installed)
swiftformat .
```

## Code Style Guidelines

### General Principles
- Follow Swift API Design Guidelines: https://swift.org/documentation/api-design-guidelines/
- Use Swift's type system to eliminate nil where possible
- Prefer value types (structs) over reference types (classes) unless reference semantics are needed
- Keep functions small and focused on a single responsibility

### Naming Conventions
- **Types/Classes/Structs/Enums**: PascalCase (e.g., `Task`, `Quadrant`, `TaskViewModel`)
- **Functions/Methods**: camelCase, verbs first (e.g., `createTask()`, `moveTaskToQuadrant()`)
- **Properties/Variables**: camelCase (e.g., `isCompleted`, `taskTitle`)
- **Constants**: camelCase with appropriate prefix (e.g., `maxTaskTitleLength`)
- **Enums**: PascalCase for enum and cases (e.g., `Quadrant.q1`)
- **Avoid abbreviations**: Use `task` instead of `t`, `completed` instead of `comp`

### Imports
```swift
// Standard library first
import Foundation
import SwiftUI
import Combine

// Third-party imports (if any) after
// import SomeExternalLibrary
```

### Type Annotations
- Use explicit types for public properties and function signatures
- Prefer type inference for local variables when it improves readability
- Use `var` for mutable state, `let` for immutable state

### SwiftUI Specific
- Use `@State`, `@Binding`, `@StateObject`, `@ObservedObject` appropriately
- Keep views small and composable
- Extract reusable components into separate views
- Use `@ViewBuilder` for conditional content in views
- Follow SwiftUI naming: `ViewName` for view structs

### Error Handling
- Use `Result` type for synchronous operations that can fail
- Use `throws`/`try` for functions that may fail
- Provide meaningful error messages
- Never silently catch and ignore errors

### Code Organization
```
// File structure recommendation:
// 1. Imports
// 2. Type definitions (structs, enums, classes)
// 3. View structs
// 4. ViewModels/Managers
// 5. Extensions

// Within a type:
// 1. Properties (stored, computed)
// 2. Initializers
// 3. Public methods
// 4. Private methods
```

### Accessibility
- Add accessibility labels to interactive elements
- Support VoiceOver navigation
- Ensure sufficient color contrast (see PRD colors)
- Test with accessibility inspector

### Testing Guidelines
- Test file naming: `[Type]Tests.swift` (e.g., `TaskTests.swift`)
- Test method naming: `test[Description]()[throws]` (e.g., `testTaskCreation()`)
- Use XCTest framework
- Follow AAA pattern: Arrange, Act, Assert
- Mock external dependencies

## Data Models

### Task Model
```swift
struct Task: Identifiable, Codable {
    let id: UUID
    var title: String
    var quadrant: Quadrant
    var dueDate: Date?
    var notes: String?
    var subtasks: [Subtask]?
    var isCompleted: Bool
    let createdAt: Date
    var completedAt: Date?
}
```

### Subtask Model
```swift
struct Subtask: Identifiable, Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool
}
```

### Quadrant Enum
```swift
enum Quadrant: String, CaseIterable, Codable {
    case q1 = "重要且紧急"
    case q2 = "不重要但紧急"
    case q3 = "重要不紧急"
    case q4 = "不重要不紧急"
}
```

## UI Design Specifications

### Color Palette (from PRD)
| Element | Light Mode | Dark Mode |
|---------|------------|-----------|
| Window Background | #FFFFFF | #000000 |
| Quadrant Background | #FFFFFF | #1C1C1E |
| Task Card Background | #F9F9F9 | #2C2C2E |
| Divider | #E5E5E5 | #3A3A3C |
| Primary Text | #000000 | #FFFFFF |
| Secondary Text | #6C6C70 | #8E8E93 |

### Quadrant Border Colors
- Q1 (Do First): Red (#FF3B30 light / #FF453A dark) - Leading border
- Q2 (Delegate): Orange (#FF9500 light / #FF9F0A dark) - Top border
- Q3 (Schedule): Blue (#007AFF light / #0A84FF dark) - Leading border
- Q4 (Eliminate): Gray (#8E8E93) - Bottom border

### Dimensions
- Window: 1000x700 pt
- Quadrant corner radius: 16 pt
- Task card corner radius: 10 pt
- Border width: 4 pt
- Quadrant padding: 16 pt
- Task card spacing: 8 pt
- Task card padding: 12 pt

## Performance Requirements
- Launch time: < 1 second
- Support 1000+ tasks without lag
- Drag operation: 60fps
- Memory usage: < 200MB
