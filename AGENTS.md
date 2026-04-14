# Ghostty Configurator Agent Guidelines (AGENTS.md)

Welcome, Agent. This document defines the engineering standards, architecture, and operational commands for the Ghostty Configurator codebase.

## 1. Project Overview
- **Type**: Native macOS Application
- **Stack**: Swift, SwiftUI
- **Build System**: Swift Package Manager (SPM)
- **Purpose**: Provide a fast, native GUI to parse and edit the `~/.config/ghostty/config` configuration file.

## 2. Build, Lint & Test Commands

### Building and Running
To build the application:
```bash
swift build
```

To run the application locally:
```bash
swift run GhosttyConfigurator
```

To build a release binary:
```bash
swift build -c release
```

### Testing
To run all tests:
```bash
swift test
```

To run a specific test suite or test case (use the `--filter` flag):
```bash
# Format: swift test --filter <PackageName>.<TestClass>
swift test --filter GhosttyConfiguratorTests.ConfigManagerTests

# Format: swift test --filter <PackageName>.<TestClass>/<testMethod>
swift test --filter GhosttyConfiguratorTests.ConfigManagerTests/testConfigParsing
```

### Linting & Formatting
If SwiftLint is available on the system:
```bash
swiftlint
```
If SwiftFormat is installed, to auto-format:
```bash
swiftformat .
```
*(If tools are missing, install them via Homebrew: `brew install swiftlint swiftformat`)*

## 3. Code Style Guidelines

### 3.1 Naming Conventions
- **Types (Classes, Structs, Enums, Protocols)**: `UpperCamelCase` (e.g., `ConfigManager`, `AppTheme`).
- **Variables & Properties**: `lowerCamelCase` (e.g., `fontFamily`, `themeName`).
- **Constants**: `lowerCamelCase` (e.g., `defaultConfigPath`). No ALL_CAPS.
- **Functions & Methods**: `lowerCamelCase` (e.g., `parseConfig(file:)`, `save()`). Provide meaningful parameter labels.

### 3.2 Types & Structs
- Prefer `struct` over `class` unless you need inheritance, reference semantics, or Objective-C interoperability.
- Keep state management in `ObservableObject` classes (or use the new iOS 17/macOS 14 `@Observable` macro) to integrate easily with SwiftUI.
- Use strong typing. Avoid force-unwrapping (`!`). Always use `if let` or `guard let`.

### 3.3 Formatting
- Indent using 4 spaces.
- Place the opening brace `{` on the same line as the declaration.
- Leave one blank line between method declarations and logical blocks.
- Ensure all files end with a newline character.

### 3.4 Error Handling
- Use `do-catch` blocks extensively for File I/O operations (e.g., parsing/saving config).
- Throw descriptive custom errors (conform to `Error` and `LocalizedError`).
- Provide user-facing fallback states or error alerts in SwiftUI instead of silent failures or crashes.

### 3.5 Imports
- Group imports:
  1. Standard Library (`Foundation`)
  2. UI Frameworks (`SwiftUI`, `AppKit`)
  3. Third-party packages (if any)
- Sort imports alphabetically within their groups.

### 3.6 Documentation and Comments
- Use Markdown (`///`) for documenting types, properties, and methods.
- Document *why* complex parsing or UI logic exists, rather than *what* it does.
- Maintain a clean Git history and write meaningful commit messages ("Add XYZ", "Fix ABC").

## 4. Architecture Guidelines

- **ConfigManager.swift**: Responsible strictly for reading `~/.config/ghostty/config`, parsing the key-value pairs, and writing the file back. This is the single source of truth for the config state.
- **UI Layer (SwiftUI)**: Use `Form`, `Section`, `Toggle`, `ColorPicker`, and `TextField` to edit configuration. Bind directly to the state managed by `ConfigManager`.
- **Parsing Strategy**: Ghostty's config is a line-based key-value format (e.g., `font-family = "Fira Code"`). The parser must retain existing comments and unrecognized keys, only modifying the requested values to preserve user customization.

## 5. Agent Instructions (Copilot / Cursor)

When operating within this codebase, obey the following:
1. **Safety First**: Do NOT override or erase the user's `~/.config/ghostty/config` accidentally. Create a backup (`~/.config/ghostty/config.bak`) before saving for the first time.
2. **SwiftUI Best Practices**: Avoid overly complex view hierarchies. Break down large `ContentView` into smaller, reusable components (e.g., `FontSectionView`, `ThemeSectionView`).
3. **No Assumptions**: Do not assume additional dependencies (like Alamofire or SwiftyJSON) exist unless specified in `Package.swift`. Stick to `Foundation` and native Swift APIs.
4. **macOS Compatibility**: Ensure UI elements are appropriate for macOS (e.g., utilizing `macOS 14.0` availability where required). Use `NSWorkspace` for file system interactions that go beyond standard `FileManager` if needed.
5. **Testing**: Before finalizing a refactor or new feature, write a corresponding unit test in the `Tests` folder to verify the configuration parses and serializes correctly.

---
*End of AGENTS.md*
