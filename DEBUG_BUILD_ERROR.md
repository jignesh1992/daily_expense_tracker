# Debugging PhaseScriptExecution Error

## Step 1: Find the Exact Error

The error "Command PhaseScriptExecution failed" is generic. We need to find which script is failing:

### In Xcode:
1. Open **Report Navigator** (⌘ + 9)
2. Select the **failed build**
3. Look for red errors - find the one that says "PhaseScriptExecution"
4. **Click on it** to expand and see:
   - Which script failed (e.g., "[CP] Copy Pods Resources")
   - The actual error message

### Or check build log:
1. In Xcode: **View** → **Navigators** → **Show Report Navigator** (⌘ + 9)
2. Select the latest build
3. Look for the script name in the error

## Step 2: Common Fixes Based on Script

### If "[CP] Check Pods Manifest.lock" fails:
```bash
cd "/Users/jignesh/Documents/Personal Projects/daily_expense_tracker/frontend/ios"
cp Podfile.lock Pods/Manifest.lock
```

### If "[CP] Copy Pods Resources" fails:
The script can't find the xcfilelist files. Check:
```bash
cd "/Users/jignesh/Documents/Personal Projects/daily_expense_tracker/frontend/ios"
ls -la "Pods/Target Support Files/Pods-Runner/Pods-Runner-resources-Debug-input-files.xcfilelist"
```

If missing, run:
```bash
pod install
```

### If "[CP] Embed Pods Frameworks" fails:
Check if frameworks exist:
```bash
cd "/Users/jignesh/Documents/Personal Projects/daily_expense_tracker/frontend/ios"
ls -la Pods/*/frameworks/ 2>&1 | head -5
```

## Step 3: Quick Fix - Disable Problematic Scripts

If you can't fix the script, temporarily disable it:

1. Open `Runner.xcworkspace` in Xcode
2. Select **Runner** target
3. Go to **Build Phases** tab
4. Find the failing script (from Step 1)
5. **Uncheck the checkbox** next to it
6. Build again

## Step 4: Nuclear Option - Clean Everything

```bash
cd "/Users/jignesh/Documents/Personal Projects/daily_expense_tracker/frontend/ios"

# Remove everything
rm -rf Pods Podfile.lock
rm -rf ~/Library/Developer/Xcode/DerivedData/*
cd ..
flutter clean
cd ios

# Reinstall
flutter pub get
pod install

# Sync files
cp Podfile.lock Pods/Manifest.lock

# Open
open Runner.xcworkspace
```

Then in Xcode: Product → Clean Build Folder (⇧⌘K) → Build (⌘ + R)

---

**Please share:**
1. Which script is failing (from Xcode build log)
2. The exact error message

This will help me provide a targeted fix.
