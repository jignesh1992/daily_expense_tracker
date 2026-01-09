#!/bin/bash

# Quick fix for PhaseScriptExecution errors

cd "/Users/jignesh/Documents/Personal Projects/daily_expense_tracker/frontend/ios"

echo "🔧 Fixing build script errors..."
echo ""

# Ensure files are synced
echo "1. Syncing Podfile.lock..."
cp Podfile.lock Pods/Manifest.lock 2>/dev/null || true

# Verify scripts exist
echo "2. Checking scripts..."
if [ ! -f "Pods/Target Support Files/Pods-Runner/Pods-Runner-resources.sh" ]; then
    echo "   ⚠️  Resources script missing - reinstalling pods..."
    pod install
fi

# Clean everything
echo "3. Cleaning build artifacts..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*
flutter clean 2>/dev/null || true

echo ""
echo "✅ Done! Now:"
echo "   1. Close Xcode completely"
echo "   2. Run: open Runner.xcworkspace"
echo "   3. Product → Clean Build Folder (⇧⌘K)"
echo "   4. Build again (⌘ + R)"
echo ""
echo "If error persists, check Xcode build log for the specific script name."
