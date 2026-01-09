# iOS Setup & Testing Guide - Pocketa Expense Tracker

This guide will walk you through setting up and testing the iOS app step by step.

## Prerequisites

### 1. Install Required Software

```bash
# Check if you have the required tools
node --version    # Should be v18 or higher
npm --version     # Should be v9 or higher
flutter --version # Should be v3.0 or higher
xcodebuild -version # Should be Xcode 14 or higher
```

**Install Flutter (if not installed):**
```bash
# macOS
brew install --cask flutter

# Or download from: https://flutter.dev/docs/get-started/install/macos
```

**Install Xcode:**
- Download from Mac App Store or Apple Developer Portal
- Install Xcode Command Line Tools:
```bash
xcode-select --install
```

**Install CocoaPods (for iOS dependencies):**
```bash
sudo gem install cocoapods
```

### 2. Verify Flutter Setup

```bash
flutter doctor
```

Fix any issues shown. You should see:
- ✅ Flutter (Channel stable)
- ✅ Xcode - develop for iOS
- ✅ CocoaPods - CocoaPods installed

## Step 1: Backend Setup

### 1.1 Install Backend Dependencies

```bash
cd backend
npm install
```

### 1.2 Set Up PostgreSQL Database

**Option A: Local PostgreSQL**
```bash
# Install PostgreSQL (macOS)
brew install postgresql@14
brew services start postgresql@14

# Create database
createdb expense_tracker
```

**Option B: Use Railway/Cloud Database**
- Sign up at https://railway.app
- Create a new PostgreSQL database
- Copy the connection string

### 1.3 Configure Environment Variables

```bash
cd backend
cp .env.example .env
```

Edit `.env` file:
```env
# Database
DATABASE_URL="postgresql://username:password@localhost:5432/expense_tracker?schema=public"
# OR use Railway connection string

# Server
PORT=3000
NODE_ENV=development

# Firebase Admin SDK (we'll set this up in Step 3)
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYour private key here\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk@your-project.iam.gserviceaccount.com

# Claude API
CLAUDE_API_KEY=your-claude-api-key

# CORS - Update this to your iOS simulator/device IP if needed
CORS_ORIGIN=http://localhost:3000
```

### 1.4 Set Up Database Schema

```bash
cd backend

# Generate Prisma Client
npm run prisma:generate

# Run migrations
npm run prisma:migrate dev --name init
```

### 1.5 Start Backend Server

```bash
npm run dev
```

You should see:
```
Server running on port 3000
```

**Test the backend:**
```bash
# In another terminal
curl http://localhost:3000/health
```

Expected response:
```json
{"status":"ok","timestamp":"2024-01-01T00:00:00.000Z"}
```

## Step 2: Firebase Setup

### 2.1 Create Firebase Project

1. Go to https://console.firebase.google.com
2. Click "Add project"
3. Enter project name: "Pocketa Expense Tracker"
4. Disable Google Analytics (optional)
5. Click "Create project"

### 2.2 Add iOS App to Firebase

1. In Firebase Console, click "Add app" → iOS
2. **Bundle ID**: `com.example.pocketaExpenseTracker`
   - You can change this later in Xcode if needed
3. **App nickname**: "Pocketa iOS"
4. **App Store ID**: Leave blank for now
5. Click "Register app"

### 2.3 Download Configuration File

1. Download `GoogleService-Info.plist`
2. **Important**: Place it in the correct location:
```bash
# Navigate to frontend directory
cd frontend

# Copy the downloaded file
cp ~/Downloads/GoogleService-Info.plist ios/Runner/GoogleService-Info.plist
```

**Verify the file is in the right place:**
```bash
ls -la frontend/ios/Runner/GoogleService-Info.plist
```

### 2.4 Enable Firebase Authentication

1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. Enable **Email/Password**
3. Click "Save"

### 2.5 Set Up Firebase Admin SDK (for Backend)

1. In Firebase Console, go to **Project Settings** → **Service Accounts**
2. Click **Generate New Private Key**
3. Save the JSON file securely
4. Copy values to backend `.env`:
   - `project_id` → `FIREBASE_PROJECT_ID`
   - `private_key` → `FIREBASE_PRIVATE_KEY` (keep the `\n` characters)
   - `client_email` → `FIREBASE_CLIENT_EMAIL`

**Example `.env` entry:**
```env
FIREBASE_PROJECT_ID=pocketa-expense-tracker
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@pocketa-expense-tracker.iam.gserviceaccount.com
```

### 2.6 Get Claude API Key

1. Go to https://console.anthropic.com
2. Sign up or log in
3. Go to API Keys section
4. Create a new API key
5. Copy it to backend `.env`:
```env
CLAUDE_API_KEY=sk-ant-api03-xxxxx
```

## Step 3: iOS App Setup

### 3.1 Install Flutter Dependencies

```bash
cd frontend
flutter pub get
```

### 3.2 Configure iOS Project

**Update Bundle Identifier:**
1. Open Xcode:
```bash
open ios/Runner.xcworkspace
```

2. In Xcode:
   - Select **Runner** in the project navigator
   - Go to **Signing & Capabilities** tab
   - Change **Bundle Identifier** to match Firebase (or update Firebase to match)
   - Example: `com.example.pocketaExpenseTracker`

3. **Enable Signing:**
   - Check "Automatically manage signing"
   - Select your Team (Apple Developer account)
   - If you don't have a team, create a free Apple ID account

### 3.3 Install iOS Dependencies

```bash
cd ios
pod install
cd ..
```

**If you get errors:**
```bash
# Update CocoaPods repo
pod repo update

# Clean and reinstall
rm -rf Pods Podfile.lock
pod install
```

### 3.4 Configure API Base URL

**For iOS Simulator:**
The app uses `localhost:3000` by default, which works with the simulator.

**For Physical Device:**
You need to use your Mac's IP address:

1. Find your Mac's IP:
```bash
ipconfig getifaddr en0
# Example output: 192.168.1.100
```

2. Update the API base URL in the code:
```dart
// In frontend/lib/utils/constants.dart
static const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://192.168.1.100:3000', // Your Mac's IP
);
```

**Or build with dart-define:**
```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.100:3000
```

### 3.5 Update Backend CORS for Device Testing

If testing on a physical device, update backend `.env`:
```env
CORS_ORIGIN=http://192.168.1.100:3000
# Or use * for development (not recommended for production)
```

## Step 4: Run on iOS Simulator

### 4.1 Start iOS Simulator

```bash
# List available simulators
xcrun simctl list devices

# Open Simulator
open -a Simulator

# Or use Flutter to open
flutter emulators --launch apple_ios_simulator
```

### 4.2 Verify Backend is Running

In a separate terminal:
```bash
cd backend
npm run dev
```

### 4.3 Run Flutter App

```bash
cd frontend

# Run on iOS simulator
flutter run -d ios

# Or specify a device
flutter devices  # List available devices
flutter run -d "iPhone 15 Pro"
```

**First run will take longer** as it builds the app.

## Step 5: Testing the App

### 5.1 Test Authentication Flow

1. **Launch the app** - You should see the Login screen
2. **Create an account:**
   - Tap "Don't have an account? Sign Up"
   - Enter email: `test@example.com`
   - Enter password: `password123` (min 6 characters)
   - Tap "Sign Up"
3. **Verify** - You should be redirected to the Home screen

### 5.2 Test Manual Expense Entry

1. On Home screen, tap **"Manual"** button
2. Fill in the form:
   - Amount: `500`
   - Category: Select "Food"
   - Description: `Lunch`
   - Date: Today (default)
3. Tap **"Save Expense"**
4. Verify the expense appears on the Home screen

### 5.3 Test Voice Input

1. On Home screen, tap **"Voice"** button
2. **Grant microphone permission** when prompted
3. Tap the microphone button
4. Speak: **"₹500 food"** or **"500 rupees for food"**
5. Wait for transcription
6. Verify the parsed result shows:
   - Amount: ₹500
   - Category: food
7. Tap **"Confirm"** to save

**Note:** Voice input requires:
- Microphone permission (granted automatically)
- Internet connection (for Claude API parsing)

### 5.4 Test Expense List

1. Tap **"View All"** on Home screen
2. Verify all expenses are listed
3. **Swipe left** on an expense to delete
4. Confirm deletion

### 5.5 Test Summary/Statistics

1. Tap the **bar chart icon** in the app bar
2. View **Daily** tab (default)
3. Verify today's total and category breakdown
4. Switch to **Weekly** and **Monthly** tabs
5. Verify summaries are calculated correctly

### 5.6 Test Offline Mode

1. **Disable Wi-Fi/Cellular** on the simulator:
   - Settings → Wi-Fi → Turn Off
2. Try adding an expense
3. Verify it saves locally
4. **Re-enable network**
5. Verify the expense syncs to the server

## Step 6: Testing on Physical iOS Device

### 6.1 Connect Your iPhone

1. Connect iPhone via USB
2. Trust the computer on your iPhone
3. In Xcode, select your device from the device list

### 6.2 Update Network Configuration

**On your Mac:**
1. Ensure Mac and iPhone are on the same Wi-Fi network
2. Find Mac's IP address:
```bash
ipconfig getifaddr en0
```

**Update backend CORS:**
```env
CORS_ORIGIN=http://YOUR_MAC_IP:3000
```

**Update frontend API URL:**
```bash
flutter run --dart-define=API_BASE_URL=http://YOUR_MAC_IP:3000
```

### 6.3 Build and Run

```bash
cd frontend
flutter run -d <your-device-id>
```

**Or build release:**
```bash
flutter build ios --release
# Then install via Xcode
```

## Troubleshooting

### Issue: "Firebase not initialized"

**Solution:**
1. Verify `GoogleService-Info.plist` is in `ios/Runner/`
2. Check Bundle ID matches in Xcode and Firebase
3. Clean and rebuild:
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter pub get
flutter run
```

### Issue: "Network request failed"

**Solution:**
1. Verify backend is running: `curl http://localhost:3000/health`
2. Check API_BASE_URL is correct
3. For physical device, use Mac's IP address, not localhost
4. Check CORS settings in backend `.env`

### Issue: "Microphone permission denied"

**Solution:**
1. Go to iOS Settings → Privacy → Microphone
2. Enable for "Pocketa Expense Tracker"
3. Restart the app

### Issue: "Voice parsing not working"

**Solution:**
1. Check Claude API key is set in backend `.env`
2. Verify backend logs for API errors
3. Check internet connection
4. Test API directly:
```bash
curl -X POST http://localhost:3000/api/voice/parse \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"text":"₹500 food"}'
```

### Issue: "Pod install fails"

**Solution:**
```bash
# Update CocoaPods
sudo gem install cocoapods

# Update repo
pod repo update

# Clean and reinstall
cd ios
rm -rf Pods Podfile.lock
pod install
```

### Issue: "Build errors in Xcode"

**Solution:**
1. Clean build folder: Product → Clean Build Folder (Shift+Cmd+K)
2. Delete DerivedData:
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData
```
3. Rebuild in Xcode

### Issue: "Database connection error"

**Solution:**
1. Verify PostgreSQL is running:
```bash
brew services list | grep postgresql
```
2. Check DATABASE_URL in `.env`
3. Test connection:
```bash
psql $DATABASE_URL -c "SELECT 1;"
```

## Quick Test Checklist

- [ ] Backend server starts without errors
- [ ] Database migrations run successfully
- [ ] Firebase project created and configured
- [ ] `GoogleService-Info.plist` in correct location
- [ ] iOS app builds successfully
- [ ] Can create user account
- [ ] Can log in
- [ ] Can add manual expense
- [ ] Can add voice expense
- [ ] Can view expense list
- [ ] Can delete expense
- [ ] Summary screens work
- [ ] Offline mode works

## Next Steps After Testing

1. **Set up production database** (Railway, Supabase, etc.)
2. **Configure production Firebase** project
3. **Set up CI/CD** for automated deployments
4. **Add App Store** preparation (icons, screenshots, etc.)
5. **Implement widget** functionality (iOS 14+)
6. **Add Siri Shortcuts** integration

## Useful Commands

```bash
# Backend
cd backend
npm run dev              # Start dev server
npm run build            # Build for production
npm test                 # Run tests
npm run prisma:studio    # Open database GUI

# Frontend
cd frontend
flutter run              # Run on default device
flutter run -d ios        # Run on iOS
flutter test             # Run tests
flutter clean             # Clean build
flutter pub get          # Get dependencies

# iOS Specific
cd ios
pod install              # Install CocoaPods dependencies
pod update               # Update dependencies
```

## Support

If you encounter issues:
1. Check the error logs in terminal
2. Check Xcode console for iOS-specific errors
3. Verify all environment variables are set
4. Ensure all dependencies are installed
5. Check Firebase Console for authentication issues
