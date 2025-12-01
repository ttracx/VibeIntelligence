#!/bin/bash
# Build VibeIntelligence macOS App
# Part of VibeCaaS.com - "Code the Vibe. Deploy the Dream."
# © 2025 NeuralQuantum.ai LLC

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/Source"
BUILD_DIR="$SCRIPT_DIR/Build"
APP_NAME="VibeIntelligenceApp"
BUNDLE_ID="com.vibecaas.vibeintelligence"

echo "🎧 Building VibeIntelligence App..."
echo ""

# Check for Xcode
if ! command -v xcodebuild &>/dev/null; then
    echo "❌ Error: Xcode command line tools not found"
    echo "   Install with: xcode-select --install"
    exit 1
fi

# Check for Swift
if ! command -v swift &>/dev/null; then
    echo "❌ Error: Swift not found"
    exit 1
fi

# Create build directory
mkdir -p "$BUILD_DIR"

# Build the app
echo "📦 Compiling Swift sources..."
cd "$SOURCE_DIR"

# Option 1: Build with swift build (simpler)
swift build -c release

# Create app bundle
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Copy executable
cp ".build/release/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/"

# Copy Info.plist
cp "$SCRIPT_DIR/VibeIntelligenceApp.app/Contents/Info.plist" "$APP_BUNDLE/Contents/"

# Copy icon if available
if [[ -f "$SCRIPT_DIR/../assets/icon.icns" ]]; then
    cp "$SCRIPT_DIR/../assets/icon.icns" "$APP_BUNDLE/Contents/Resources/AppIcon.icns"
fi

# Sign the app (ad-hoc for local use)
echo "🔏 Signing app..."
codesign --force --deep --sign - "$APP_BUNDLE"

echo ""
echo "✅ Build complete!"
echo "   App location: $APP_BUNDLE"
echo ""
echo "To install, copy to /Applications:"
echo "   cp -r \"$APP_BUNDLE\" /Applications/"
echo ""
echo "🎵 Your vibe is ready!"
