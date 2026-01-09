# Quick Start Guide - iOS Testing

## Prerequisites Check

Run this command to verify everything is installed:
```bash
./setup-ios.sh
```

## 5-Minute Setup

### 1. Backend (Terminal 1)

```bash
cd backend

# Install dependencies
npm install

# Create .env file
cp .env.example .env

# Edit .env - Add these minimum required values:
# DATABASE_URL="postgresql://user:pass@localhost:5432/expense_tracker"
# FIREBASE_PROJECT_ID="your-project-id"
# FIREBASE_PRIVATE_KEY="your-key"
# FIREBASE_CLIENT_EMAIL="your-email"
# CLAUDE_API_KEY="your-claude-key"

# Setup database
npm run prisma:generate
npm run prisma:migrate dev --name init

# Start server
npm run dev
```

### 2. Firebase Setup (5 minutes)

1. Go to https://console.firebase.google.com
2. Create new project: "Pocketa Expense Tracker"
3. Add iOS app with Bundle ID: `com.example.pocketaExpenseTracker`
4. Download `GoogleService-Info.plist`
5. Place it: `frontend/ios/Runner/GoogleService-Info.plist`
6. Enable Authentication → Email/Password
7. Get Admin SDK credentials → Add to backend `.env`

### 3. iOS App (Terminal 2)

```bash
cd frontend

# Install dependencies
flutter pub get

# Install iOS pods
cd ios
pod install
cd ..

# Run on simulator
flutter run -d ios
```

## Testing Checklist

### ✅ Basic Flow
- [ ] App launches
- [ ] Can create account
- [ ] Can log in
- [ ] Home screen shows

### ✅ Expense Management
- [ ] Add manual expense
- [ ] View expense list
- [ ] Delete expense (swipe)
- [ ] View summary

### ✅ Voice Input
- [ ] Grant microphone permission
- [ ] Record voice: "₹500 food"
- [ ] See parsed result
- [ ] Confirm and save

## Common Issues & Quick Fixes

### Backend won't start
```bash
# Check if port 3000 is in use
lsof -i :3000

# Check database connection
psql $DATABASE_URL -c "SELECT 1;"
```

### iOS build fails
```bash
cd frontend/ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter pub get
flutter run
```

### Firebase not initialized
- Verify `GoogleService-Info.plist` is in `ios/Runner/`
- Check Bundle ID matches in Xcode and Firebase
- Clean build: `flutter clean && flutter pub get`

### API connection fails
- Backend running? Check: `curl http://localhost:3000/health`
- For physical device, use Mac's IP, not localhost
- Update `CORS_ORIGIN` in backend `.env`

## Device Testing

### Find Mac's IP:
```bash
ipconfig getifaddr en0
```

### Run with custom API URL:
```bash
flutter run --dart-define=API_BASE_URL=http://YOUR_MAC_IP:3000
```

### Update backend CORS:
```env
CORS_ORIGIN=http://YOUR_MAC_IP:3000
```

## Test Voice Input

1. Open Voice Input screen
2. Tap microphone
3. Say: **"₹500 food"** or **"500 rupees for food"**
4. Wait for parsing
5. Confirm to save

**Note:** Requires internet connection for Claude API.

## Debug Commands

```bash
# View backend logs
cd backend && npm run dev

# View Flutter logs
flutter logs

# Open Xcode for debugging
cd frontend/ios && open Runner.xcworkspace

# Check iOS simulator logs
xcrun simctl spawn booted log stream --predicate 'processImagePath contains "Runner"'
```

## Next Steps

Once basic testing works:
1. Test offline mode (disable network)
2. Test sync functionality
3. Test all summary views
4. Test on physical device
5. Review SETUP_IOS.md for detailed configuration
