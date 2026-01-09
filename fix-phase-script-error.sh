#!/bin/bash

echo "🔧 Fixing PhaseScriptExecution errors..."
echo ""

cd "/Users/jignesh/Documents/Personal Projects/daily_expense_tracker/frontend/ios"

# 1. Sync Podfile.lock
echo "1. Syncing Podfile.lock..."
cp Podfile.lock Pods/Manifest.lock 2>/dev/null || true

# 2. Verify scripts exist
echo "2. Verifying scripts..."
SCRIPTS=(
    "Pods/Target Support Files/Pods-Runner/Pods-Runner-resources.sh"
    "Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks.sh"
)

for script in "${SCRIPTS[@]}"; do
    if [ ! -f "$script" ]; then
        echo "   ⚠️  Missing: $script"
    else
        echo "   ✅ Found: $script"
    fi
done

# 3. Clean everything
echo "3. Cleaning build artifacts..."
rm -rf ~/Library/Developer/Xcode/DerivedData/* 2>/dev/null || true
cd ..
flutter clean 2>/dev/null || true
cd ios

# 4. Verify config files
echo "4. Checking config files..."
if grep -q "PODS_ROOT" Flutter/Debug.xcconfig && grep -q "PODS_ROOT" Flutter/Release.xcconfig; then
    echo "   ✅ PODS_ROOT is defined"
else
    echo "   ❌ PODS_ROOT missing - fixing..."
    echo 'PODS_ROOT = ${SRCROOT}/Pods' >> Flutter/Debug.xcconfig
    echo 'PODS_ROOT = ${SRCROOT}/Pods' >> Flutter/Release.xcconfig
fi

echo ""
echo "✅ Done! Next steps:"
echo "   1. Close Xcode completely (⌘ + Q)"
echo "   2. Run: open Runner.xcworkspace"
echo "   3. In Xcode: Product → Clean Build Folder (⇧⌘K)"
echo "   4. Build again (⌘ + R)"
echo ""
echo "If error persists:"
echo "   - Check Xcode build log (⌘ + 9) for the specific script name"
echo "   - Share the exact error message"
