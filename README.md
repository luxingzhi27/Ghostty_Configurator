# Ghostty Configurator

A beautiful, native macOS GUI application for configuring the [Ghostty](https://github.com/mitchellh/ghostty) terminal emulator. Built with Swift and SwiftUI, it parses, edits, and saves your `~/.config/ghostty/config` seamlessly while preserving your existing comments and unmanaged settings.

## Features

- **Native macOS UI**: A clean, fluid interface integrating perfectly with your macOS environment.
- **Config Parser**: Reads your existing config file, parses key-value pairs, and saves back *only* the settings you've modified without deleting your comments.
- **Auto Theme Switching**: Full support for Ghostty's auto theme mappings (e.g., `theme = light:foo,dark:bar`).
- **Dynamic Localization**: Switch instantly between English, Simplified Chinese, and Japanese without restarting the app.

## Building and Packaging

This app is built using Swift Package Manager (SPM). To build the executable into a proper `.app` bundle and distribute it via a `.dmg` file, we use an automated shell script.

To build the release application and generate the DMG installer:

```bash
chmod +x build_app.sh
./build_app.sh
```

You will find `Ghostty Configurator.app` and `GhosttyConfigurator.dmg` in the root of the project.

## Requirements

- macOS 14.0 or newer.
- Swift toolchain (if building from source).

## License

This project is open-source and available under the MIT License.
