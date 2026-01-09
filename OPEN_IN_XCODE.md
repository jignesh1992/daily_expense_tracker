# How to Open the Project in Xcode

This guide shows you how to open your Flutter iOS project in Xcode for configuration and testing.

---

## Method 1: Open via Terminal (Recommended)

This is the most reliable method and ensures CocoaPods dependencies are set up correctly.

### Step 1: Navigate to the Frontend Directory

```bash
cd "/Users/jignesh/Documents/Personal Projects/daily_expense_tracker/frontend"
```

### Step 2: Install Flutter Dependencies (if not done already)

```bash
flutter pub get
```

### Step 3: Navigate to iOS Directory

```bash
cd ios
```

### Step 4: Install CocoaPods Dependencies

```bash
pod install
```

**Note**: If you don't have CocoaPods installed, install it first:
```bash
sudo gem install cocoapods
```

### Step 5: Open the Workspace in Xcode

**IMPORTANT**: Always open the `.xcworkspace` file, NOT the `.xcodeproj` file!

```bash
open Runner.xcworkspace
```

This will launch Xcode with your project.

---

## Method 2: Open via Finder

### Step 1: Navigate to the iOS Folder

1. Open **Finder**
2. Navigate to: `/Users/jignesh/Documents/Personal Projects/daily_expense_tracker/frontend/ios`
3. Look for **`Runner.xcworkspace`** (it has a white Xcode icon)

### Step 2: Double-Click to Open

- **Double-click** `Runner.xcworkspace`
- Xcode will launch with your project

**⚠️ Important**: Make sure you open `Runner.xcworkspace`, NOT `Runner.xcodeproj`!

---

## Method 3: Open via Xcode Menu

### Step 1: Launch Xcode

- Open Xcode from Applications or Spotlight

### Step 2: Open Workspace

1. In Xcode menu: **File** → **Open** (or press `⌘ + O`)
2. Navigate to: `/Users/jignesh/Documents/Personal Projects/daily_expense_tracker/frontend/ios`
3. Select **`Runner.xcworkspace`**
4. Click **Open**

---

## Method 4: Open via Flutter Command

You can also use Flutter's built-in command:

```bash
cd "/Users/jignesh/Documents/Personal Projects/daily_expense_tracker/frontend"
flutter run
```

Then press `i` to open in iOS Simulator, or use:
```bash
flutter run -d ios
```

To open the project in Xcode specifically:
```bash
cd "/Users/jignesh/Documents/Personal Projects/daily_expense_tracker/frontend"
open ios/Runner.xcworkspace
```

---

## Why Use `.xcworkspace` Instead of `.xcodeproj`?

- Flutter uses **CocoaPods** for dependency management
- CocoaPods creates a **workspace** (`.xcworkspace`) that includes:
  - Your app project (`Runner.xcodeproj`)
  - Pods project (dependencies)
- Opening `.xcodeproj` directly will cause build errors because dependencies won't be found
- Always use `.xcworkspace` for Flutter projects!

---

## First-Time Setup Checklist

Before opening in Xcode, ensure:

- [ ] **Flutter dependencies installed**: `flutter pub get`
- [ ] **CocoaPods installed**: `pod --version` (if not, run `sudo gem install cocoapods`)
- [ ] **CocoaPods dependencies installed**: `cd ios && pod install`
- [ ] **Xcode installed**: Check with `xcode-select -p`

---

## Troubleshooting

### Issue: "Runner.xcworkspace" not found

**Solution**: Generate the workspace by running:
```bash
cd "/Users/jignesh/Documents/Personal Projects/daily_expense_tracker/frontend/ios"
pod install
```

### Issue: Pod install fails

**Solutions**:
1. Update CocoaPods: `sudo gem install cocoapods`
2. Update pod repo: `pod repo update`
3. Clean and reinstall:
   ```bash
   cd ios
   rm -rf Pods Podfile.lock
   pod install
   ```

### Issue: Xcode shows build errors

**Solutions**:
1. Make sure you opened `.xcworkspace`, not `.xcodeproj`
2. Clean build folder: **Product** → **Clean Build Folder** (`⇧⌘K`)
3. Reinstall pods: `cd ios && pod install`
4. Restart Xcode

### Issue: "No such module 'FirebaseCore'" or similar

**Solution**: 
```bash
cd "/Users/jignesh/Documents/Personal Projects/daily_expense_tracker/frontend/ios"
pod install
```

### Issue: Xcode command line tools not found

**Solution**:
```bash
xcode-select --install
```

---

## Quick Reference Commands

```bash
# Navigate to project
cd "/Users/jignesh/Documents/Personal Projects/daily_expense_tracker/frontend"

# Install Flutter dependencies
flutter pub get

# Install CocoaPods dependencies
cd ios && pod install

# Open in Xcode
open ios/Runner.xcworkspace
```

---

## What You'll See in Xcode

Once opened, you'll see:

1. **Project Navigator** (left sidebar):
   - `Runner` - Your iOS app
   - `Pods` - Dependencies (Firebase, etc.)

2. **Main Editor Area**:
   - Source files, configuration files

3. **Key Files to Configure**:
   - `Runner` → `Info.plist` - App permissions
   - `Runner` → `GoogleService-Info.plist` - Firebase config
   - `Runner` → General tab - Bundle ID, Signing

---

## Next Steps After Opening

1. **Configure Bundle ID** (if needed)
   - Select `Runner` in Project Navigator
   - Go to **General** tab
   - Set **Bundle Identifier**

2. **Configure Signing & Capabilities**
   - Still in **General** tab
   - Set up **Signing** (Team, Provisioning Profile)

3. **Add GoogleService-Info.plist** (if not done)
   - Drag the file from Firebase into `Runner` folder in Xcode

4. **Verify Info.plist Permissions**
   - Check `NSMicrophoneUsageDescription` and `NSSpeechRecognitionUsageDescription` exist

5. **Select a Simulator/Device**
   - Use the device selector at the top toolbar
   - Choose an iOS Simulator or connected device

6. **Build and Run**
   - Press `⌘ + R` or click the Play button

---

## Summary

✅ **Always use**: `Runner.xcworkspace`  
❌ **Never use**: `Runner.xcodeproj` (will cause build errors)

**Quick command to open**:
```bash
cd "/Users/jignesh/Documents/Personal Projects/daily_expense_tracker/frontend/ios" && pod install && open Runner.xcworkspace
```
