# Fix Applied: PODS_ROOT Not Defined

## Problem
Xcode error: `Unable to load contents of file list: '/Target Support Files/Pods-Runner/Pods-Runner-resources-Debug-input-files.xcfilelist'`

## Root Cause
The Flutter `Debug.xcconfig` and `Release.xcconfig` files were not including the Pods configuration files, so `PODS_ROOT` was never defined during the build. This caused Xcode to try resolving `${PODS_ROOT}/Target Support Files/...` as an absolute path `/Target Support Files/...` instead of the correct relative path.

## Fix Applied
Updated the Flutter configuration files to include the Pods xcconfig:

### `Flutter/Debug.xcconfig`
```xcconfig
#include "Generated.xcconfig"
#include "Pods/Target Support Files/Pods-Runner/Pods-Runner.debug.xcconfig"
```

### `Flutter/Release.xcconfig`
```xcconfig
#include "Generated.xcconfig"
#include "Pods/Target Support Files/Pods-Runner/Pods-Runner.release.xcconfig"
```

This ensures that `PODS_ROOT = ${SRCROOT}/Pods` is defined, allowing Xcode to correctly resolve paths like `${PODS_ROOT}/Target Support Files/...`.

## Verification

1. **Close Xcode completely** (⌘ + Q)

2. **Clean build folder:**
   ```bash
   cd "/Users/jignesh/Documents/Personal Projects/daily_expense_tracker/frontend/ios"
   rm -rf ~/Library/Developer/Xcode/DerivedData/*
   ```

3. **Reopen workspace:**
   ```bash
   open Runner.xcworkspace
   ```

4. **In Xcode:**
   - Product → Clean Build Folder (⇧⌘K)
   - Select a simulator
   - Press ⌘ + R to build

The error should now be resolved!

## Important Note

⚠️ **Flutter may regenerate these config files** when you run `flutter clean` or `flutter pub get`. If the error returns after running Flutter commands, you'll need to re-add the Pods xcconfig includes.

### Quick Re-apply Fix

If Flutter regenerates the config files, run:

```bash
cd "/Users/jignesh/Documents/Personal Projects/daily_expense_tracker/frontend/ios"

# Add Pods config to Debug.xcconfig
echo '#include "Pods/Target Support Files/Pods-Runner/Pods-Runner.debug.xcconfig"' >> Flutter/Debug.xcconfig

# Add Pods config to Release.xcconfig  
echo '#include "Pods/Target Support Files/Pods-Runner/Pods-Runner.release.xcconfig"' >> Flutter/Release.xcconfig
```

## Why This Happens

Flutter projects use custom xcconfig files, and CocoaPods warns:
```
[!] CocoaPods did not set the base configuration of your project because your project already has a custom config set.
```

This means CocoaPods doesn't automatically include its config in Flutter's config files. We need to manually include them.

## Alternative Solution (If Above Doesn't Work)

If manually including the Pods config doesn't work, you can try setting PODS_ROOT directly in the Flutter config files:

```xcconfig
#include "Generated.xcconfig"
PODS_ROOT = ${SRCROOT}/Pods
#include "Pods/Target Support Files/Pods-Runner/Pods-Runner.debug.xcconfig"
```

But the include method is preferred as it ensures all Pods settings are properly loaded.
