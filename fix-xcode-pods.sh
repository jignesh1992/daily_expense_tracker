#!/bin/bash

# Fix CocoaPods xcfilelist Error Script
# This script fixes the "Unable to load contents of file list" error in Xcode

set -e

echo "🔧 Fixing CocoaPods xcfilelist Error"
echo "===================================="
echo ""

cd "$(dirname "$0")/frontend/ios"

echo "1. Cleaning Flutter build..."
cd ..
flutter clean
flutter pub get
cd ios

echo ""
echo "2. Deintegrating and reinstalling CocoaPods..."
pod deintegrate
pod install

echo ""
echo "3. Verifying xcfilelist files exist..."
if [ -f "Pods/Target Support Files/Pods-Runner/Pods-Runner-resources-Debug-input-files.xcfilelist" ]; then
    echo "✅ xcfilelist files found"
else
    echo "❌ xcfilelist files not found - something went wrong"
    exit 1
fi

echo ""
echo "4. Opening workspace in Xcode..."
open Runner.xcworkspace

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps in Xcode:"
echo "1. Product → Clean Build Folder (⇧⌘K)"
echo "2. Close and reopen Xcode"
echo "3. Select a simulator"
echo "4. Press ⌘ + R to build"
echo ""
echo "If the error persists, try:"
echo "- Close Xcode completely"
echo "- Delete ~/Library/Developer/Xcode/DerivedData"
echo "- Reopen Runner.xcworkspace"
