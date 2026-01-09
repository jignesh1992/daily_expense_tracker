# Fix: Missing Bundle ID Error

## Problem
Build succeeds but app fails to install with "Missing bundle ID" error.

## Solution

The bundle ID is set in the project, but you need to configure signing in Xcode:

### Steps:

1. **Open Xcode:**
   ```bash
   cd "/Users/jignesh/Documents/Personal Projects/daily_expense_tracker/frontend/ios"
   open Runner.xcworkspace
   ```

2. **Select Runner Target:**
   - Click **Runner** in the Project Navigator (left sidebar)
   - Select the **Runner** project (blue icon)
   - Select **Runner** target under "TARGETS"

3. **Go to Signing & Capabilities Tab:**
   - Click on **"Signing & Capabilities"** tab

4. **Configure Signing:**
   - ✅ Check **"Automatically manage signing"**
   - Select your **Team** (or add your Apple ID)
   - If you don't have a team:
     - Click **"Add Account..."**
     - Sign in with your Apple ID
     - Select it as your team

5. **Verify Bundle Identifier:**
   - Make sure **Bundle Identifier** shows: `com.example.pocketaExpenseTracker`
   - If it's different, change it to match Firebase (or update Firebase to match)

6. **Build and Run:**
   - Press `⌘ + R` to build and run

## Alternative: Use Flutter Command Line

If Xcode signing doesn't work, try:

```bash
cd "/Users/jignesh/Documents/Personal Projects/daily_expense_tracker/frontend"
flutter run -d ios
```

Flutter will handle signing automatically.

## If Still Failing

Try cleaning and rebuilding:

```bash
cd "/Users/jignesh/Documents/Personal Projects/daily_expense_tracker/frontend/ios"
rm -rf ~/Library/Developer/Xcode/DerivedData/*
cd ..
flutter clean
flutter pub get
cd ios
pod install
flutter run -d ios
```
