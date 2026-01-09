# Testing on Physical iOS Device - Step by Step Guide

## Prerequisites

✅ **Before you start, make sure:**
- [ ] Your Mac and iPhone are on the **same Wi-Fi network**
- [ ] iPhone is connected via USB cable
- [ ] You have an Apple ID (free account works)
- [ ] Xcode is installed on your Mac
- [ ] Backend server is running on your Mac

---

## Step 1: Prepare Your Mac

### 1.1 Find Your Mac's IP Address

Open Terminal and run:
```bash
ipconfig getifaddr en0
```

**Example output:** `192.168.1.100`

**Note this IP address** - you'll need it in the next steps.

### 1.2 Ensure Backend is Running

```bash
cd backend
npm run dev
```

You should see: `Server running on port 3000`

**Keep this terminal open** - the backend must stay running.

---

## Step 2: Update Backend Configuration

### 2.1 Update CORS Settings

Edit `backend/.env` file:
```env
CORS_ORIGIN=http://YOUR_MAC_IP:3000
```

**Example:**
```env
CORS_ORIGIN=http://192.168.1.100:3000
```

**Restart the backend** after making this change:
- Press `Ctrl+C` in the backend terminal
- Run `npm run dev` again

---

## Step 3: Connect Your iPhone

### 3.1 Physical Connection

1. Connect your iPhone to your Mac using a **USB cable**
2. On your iPhone, if prompted: **"Trust This Computer?"** → Tap **Trust**
3. Enter your iPhone passcode if asked

### 3.2 Verify Connection

Open Terminal and run:
```bash
flutter devices
```

You should see your iPhone listed, something like:
```
iPhone (mobile) • 00008030-001234567890ABCD • ios • iOS 17.0
```

**Note the device ID** (the long string) - you'll use it to run the app.

---

## Step 4: Configure Xcode Signing

### 4.1 Open Xcode Project

```bash
cd frontend
open ios/Runner.xcworkspace
```

**Important:** Use `.xcworkspace`, NOT `.xcodeproj`

### 4.2 Configure Signing

1. In Xcode, click **Runner** in the left sidebar (blue icon at the top)
2. Select the **Runner** target (under "TARGETS")
3. Click the **"Signing & Capabilities"** tab
4. Check ✅ **"Automatically manage signing"**
5. Select your **Team** from the dropdown:
   - If you see your Apple ID, select it
   - If not, click **"Add Account..."** and sign in with your Apple ID
6. Xcode will automatically create a provisioning profile

**You should see:** ✅ "Signing certificate is valid"

### 4.3 Select Your Device

1. At the top of Xcode, next to the Run button, click the device selector
2. Select your **iPhone** from the list
3. You should see your iPhone name (e.g., "Jignesh's iPhone")

---

## Step 5: Update API URL for Device

### Option A: Build with Command Line (Recommended)

```bash
cd frontend

# Replace YOUR_MAC_IP with your actual IP from Step 1.1
flutter run --dart-define=API_BASE_URL=http://YOUR_MAC_IP:3000 -d YOUR_DEVICE_ID
```

**Example:**
```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.100:3000 -d 00008030-001234567890ABCD
```

### Option B: Update Code Permanently

Edit `frontend/lib/utils/constants.dart`:

```dart
static const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://YOUR_MAC_IP:3000', // Replace with your Mac's IP
);
```

**Example:**
```dart
defaultValue: 'http://192.168.1.100:3000',
```

Then run:
```bash
flutter run -d YOUR_DEVICE_ID
```

---

## Step 6: Build and Install on Device

### 6.1 Using Flutter CLI (Easiest)

```bash
cd frontend

# List devices to get your device ID
flutter devices

# Run on your device (replace with your device ID)
flutter run --dart-define=API_BASE_URL=http://YOUR_MAC_IP:3000 -d YOUR_DEVICE_ID
```

**First build will take 5-10 minutes** - be patient!

### 6.2 Using Xcode (Alternative)

1. In Xcode, select your iPhone from the device dropdown (top left)
2. Click the **Play button** (▶️) or press `Cmd+R`
3. Wait for the build to complete
4. The app will install and launch on your iPhone

**Note:** If using Xcode, you still need to set the API URL using Option B from Step 5.

---

## Step 7: Grant Permissions on iPhone

### 7.1 First Launch

When the app launches for the first time:

1. **Microphone Permission:**
   - Tap **"Allow"** when prompted
   - Or go to: Settings → Privacy & Security → Microphone → Enable for your app

2. **Speech Recognition Permission:**
   - Tap **"Allow"** when prompted
   - Or go to: Settings → Privacy & Security → Speech Recognition → Enable for your app

### 7.2 Verify Permissions

Go to iPhone Settings → Privacy & Security:
- ✅ Microphone → Your app should be listed and enabled
- ✅ Speech Recognition → Your app should be listed and enabled

---

## Step 8: Test Voice Input

### 8.1 Test Speech Recognition

1. Open the app on your iPhone
2. Log in (or create an account)
3. Tap the **"Voice"** button on the home screen
4. Tap the **microphone icon**
5. **Speak clearly:** "₹500 food" or "500 rupees for food"
6. Wait for transcription
7. Verify the parsed result appears

**✅ Success:** You should see:
- Transcribed text
- Parsed amount: ₹500
- Parsed category: food

---

## Troubleshooting

### Issue: "Cannot connect to backend"

**Solutions:**
1. ✅ Verify backend is running: `curl http://localhost:3000/health`
2. ✅ Check Mac and iPhone are on same Wi-Fi
3. ✅ Verify Mac's IP address: `ipconfig getifaddr en0`
4. ✅ Check CORS_ORIGIN in backend `.env` matches Mac's IP
5. ✅ Try disabling Mac firewall temporarily:
   ```bash
   sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate off
   ```
   (Re-enable after testing: `sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on`)

### Issue: "Speech recognition not available"

**Solutions:**
1. ✅ Grant microphone permission in Settings
2. ✅ Grant speech recognition permission in Settings
3. ✅ **Important:** Speech recognition does NOT work on iOS Simulator - you MUST use a physical device
4. ✅ Restart the app after granting permissions
5. ✅ Check iPhone Settings → Privacy & Security → Speech Recognition is enabled globally

### Issue: "Code signing error" or "Provisioning profile"

**Solutions:**
1. ✅ In Xcode, go to Signing & Capabilities
2. ✅ Check "Automatically manage signing"
3. ✅ Select your Team (Apple ID)
4. ✅ Clean build: Product → Clean Build Folder (`Shift+Cmd+K`)
5. ✅ Try again

### Issue: "Device not found"

**Solutions:**
1. ✅ Unlock your iPhone
2. ✅ Trust the computer on iPhone
3. ✅ Check USB cable connection
4. ✅ Run `flutter devices` to verify device is detected
5. ✅ Try disconnecting and reconnecting the USB cable

### Issue: "Build fails"

**Solutions:**
```bash
cd frontend

# Clean everything
flutter clean
rm -rf ios/Pods ios/Podfile.lock

# Reinstall dependencies
cd ios
pod install
cd ..

# Get Flutter packages
flutter pub get

# Try again
flutter run --dart-define=API_BASE_URL=http://YOUR_MAC_IP:3000 -d YOUR_DEVICE_ID
```

---

## Quick Reference Commands

```bash
# Find Mac's IP address
ipconfig getifaddr en0

# List connected devices
flutter devices

# Run on device with custom API URL
flutter run --dart-define=API_BASE_URL=http://YOUR_MAC_IP:3000 -d YOUR_DEVICE_ID

# Check backend is running
curl http://localhost:3000/health

# Open Xcode project
cd frontend && open ios/Runner.xcworkspace
```

---

## Testing Checklist

- [ ] Mac and iPhone on same Wi-Fi network
- [ ] iPhone connected via USB
- [ ] Backend running on Mac (port 3000)
- [ ] Mac's IP address noted
- [ ] Backend CORS_ORIGIN updated with Mac's IP
- [ ] Xcode signing configured
- [ ] App installed on iPhone
- [ ] Microphone permission granted
- [ ] Speech recognition permission granted
- [ ] Voice input works correctly

---

## Next Steps

Once voice input works on your physical device:

1. ✅ Test all features (manual entry, voice, summaries)
2. ✅ Test offline mode (disable Wi-Fi, add expense, re-enable Wi-Fi)
3. ✅ Test on different network conditions
4. ✅ Consider setting up TestFlight for easier testing

---

## Need Help?

If you encounter issues:

1. Check the console logs in Terminal
2. Check Xcode console for iOS-specific errors
3. Verify all steps above are completed
4. Check that backend logs show API requests coming through

**Common mistake:** Forgetting to update CORS_ORIGIN in backend `.env` - this is critical!
