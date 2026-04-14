#!/bin/bash

# Exit on first error
set -e

echo "🚀 Starting Ghostty Configurator build process..."

# Configuration
APP_NAME="Ghostty Configurator"
EXECUTABLE_NAME="GhosttyConfigurator"
APP_DIR="${APP_NAME}.app"
DMG_NAME="GhosttyConfigurator.dmg"
BUNDLE_ID="com.rayhua.ghosttyconfigurator"

# Step 1: Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf "$APP_DIR"
rm -f "$DMG_NAME"

# Step 2: Build release binary
echo "🏗️  Building release binary (this may take a moment)..."
swift build -c release

# Step 3: Create app bundle structure
echo "📁 Creating App Bundle structure..."
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

# Step 4: Copy executable
echo "📦 Copying executable..."
cp ".build/release/$EXECUTABLE_NAME" "$APP_DIR/Contents/MacOS/"

# Step 5: Create Info.plist
echo "📝 Generating Info.plist..."
cat <<EOF > "$APP_DIR/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$EXECUTABLE_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

# Step 6: Code signing (Ad-Hoc)
echo "🔐 Signing application..."
codesign --force --deep --sign - "$APP_DIR"

# Step 7: Create DMG
echo "💿 Creating disk image (DMG)..."
hdiutil create -volname "$APP_NAME" -srcfolder "$APP_DIR" -ov -format UDZO "$DMG_NAME"

echo "✅ Build complete! You can find '$APP_DIR' and '$DMG_NAME' in your project folder."
