# Final Fix: PODS_ROOT Path Resolution

## Issue
Error: `Unable to load contents of file list: '/Target Support Files/Pods-Runner/Pods-Runner-resources-Debug-input-files.xcfilelist'`

## Root Cause
The Flutter xcconfig files (`Debug.xcconfig` and `Release.xcconfig`) were not including the Pods configuration files, so `PODS_ROOT` was never defined. Additionally, the include path needed to use `${SRCROOT}` for proper resolution.

## Fix Applied

Updated both Flutter configuration files to include Pods xcconfig using `${SRCROOT}`:

### `Flutter/Debug.xcconfig`
```xcconfig
#include "Generated.xcconfig"
#include "${SRCROOT}/Pods/Target Support Files/Pods-Runner/Pods-Runner.debug.xcconfig"
```

### `Flutter/Release.xcconfig`
```xcconfig
#include "Generated.xcconfig"
#include "${SRCROOT}/Pods/Target Support Files/Pods-Runner/Pods-Runner.release.xcconfig"
```

This ensures:
1. `PODS_ROOT = ${SRCROOT}/Pods` is defined (from Pods xcconfig)
2. Xcode can resolve `${PODS_ROOT}/Target Support Files/...` correctly
3. The build phases can find the xcfilelist files

## Next Steps

1. **Close Xcode completely** (⌘ + Q)

2. **Clean DerivedData:**
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/*
   ```

3. **Reopen workspace:**
   ```bash
   cd "/Users/jignesh/Documents/Personal Projects/daily_expense_tracker/frontend/ios"
   open Runner.xcworkspace
   ```

4. **In Xcode:**
   - Product → Clean Build Folder (⇧⌘K)
   - Wait for clean to complete
   - Select a simulator (e.g., iPhone 15 Pro)
   - Press ⌘ + R to build

## Verification

After building, check that:
- ✅ No errors about missing xcfilelist files
- ✅ Build completes successfully
- ✅ App launches on simulator

## If Error Persists

If you still see the error after following the steps:

1. **Verify the files exist:**
   ```bash
   cd "/Users/jignesh/Documents/Personal Projects/daily_expense_tracker/frontend/ios"
   ls -la "Pods/Target Support Files/Pods-Runner/Pods-Runner-resources-Debug-input-files.xcfilelist"
   ```

2. **Check xcconfig content:**
   ```bash
   cat Flutter/Debug.xcconfig
   ```
   Should show the include line with `${SRCROOT}`.

3. **Reinstall pods:**
   ```bash
   pod deintegrate
   pod install
   ```

4. **Try setting PODS_ROOT directly** (if includes don't work):
   Add this line to `Flutter/Debug.xcconfig`:
   ```xcconfig
   PODS_ROOT = ${SRCROOT}/Pods
   ```

## Why This Works

- `${SRCROOT}` is a built-in Xcode variable pointing to the project root (`ios/` directory)
- Including the Pods xcconfig file loads `PODS_ROOT = ${SRCROOT}/Pods`
- This allows Xcode to resolve `${PODS_ROOT}/Target Support Files/...` correctly
- The build phases can then find the xcfilelist files

## Important Note

⚠️ **Flutter may regenerate these files** when you run `flutter clean`. If the error returns, you'll need to re-add the Pods xcconfig includes.

### Quick Re-apply Script

```bash
cd "/Users/jignesh/Documents/Personal Projects/daily_expense_tracker/frontend/ios"

# Backup original
cp Flutter/Debug.xcconfig Flutter/Debug.xcconfig.bak
cp Flutter/Release.xcconfig Flutter/Release.xcconfig.bak

# Add Pods config includes
echo '#include "${SRCROOT}/Pods/Target Support Files/Pods-Runner/Pods-Runner.debug.xcconfig"' >> Flutter/Debug.xcconfig
echo '#include "${SRCROOT}/Pods/Target Support Files/Pods-Runner/Pods-Runner.release.xcconfig"' >> Flutter/Release.xcconfig
```
