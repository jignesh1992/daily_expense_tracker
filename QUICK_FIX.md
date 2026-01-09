# Quick Fix for Podfile.lock Sync Error

## The Issue
Error: "The sandbox is not in sync with the Podfile.lock"

## Quick Solution

Run these commands:

```bash
cd "/Users/jignesh/Documents/Personal Projects/daily_expense_tracker/frontend/ios"

# Ensure files are synced
cp Podfile.lock Pods/Manifest.lock

# Clean Xcode cache
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Reopen Xcode
open Runner.xcworkspace
```

Then in Xcode:
1. Product → Clean Build Folder (⇧⌘K)
2. Build again (⌘ + R)

## If That Doesn't Work

Disable the check temporarily by editing the build phase in Xcode:

1. Open `Runner.xcworkspace` in Xcode
2. Select **Runner** project in navigator
3. Select **Runner** target
4. Go to **Build Phases** tab
5. Find **"[CP] Check Pods Manifest.lock"**
6. Uncheck the checkbox next to it (or delete the phase)
7. Build again

## Permanent Fix

The config files now have:
- `PODS_ROOT = ${SRCROOT}/Pods`
- `PODS_PODFILE_DIR_PATH = ${SRCROOT}`

This should resolve the variable resolution issue.
