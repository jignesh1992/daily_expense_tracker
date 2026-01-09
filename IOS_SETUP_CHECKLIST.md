# iOS Setup Checklist

Use this checklist to track your setup progress.

## Phase 1: Prerequisites ✅

- [ ] Node.js 18+ installed (`node --version`)
- [ ] npm installed (`npm --version`)
- [ ] Flutter 3.0+ installed (`flutter --version`)
- [ ] Xcode installed (`xcodebuild -version`)
- [ ] CocoaPods installed (`pod --version`)
- [ ] PostgreSQL installed (or cloud database ready)
- [ ] Apple Developer account (free is fine for testing)

## Phase 2: Backend Setup ✅

- [ ] Backend dependencies installed (`cd backend && npm install`)
- [ ] `.env` file created (`cp .env.example .env`)
- [ ] Database URL configured in `.env`
- [ ] Prisma client generated (`npm run prisma:generate`)
- [ ] Database migrations run (`npm run prisma:migrate dev`)
- [ ] Backend server starts (`npm run dev`)
- [ ] Health check works (`curl http://localhost:3000/health`)

## Phase 3: Firebase Setup ✅

- [ ] Firebase project created
- [ ] iOS app added to Firebase project
- [ ] Bundle ID configured: `com.example.pocketaExpenseTracker`
- [ ] `GoogleService-Info.plist` downloaded
- [ ] File placed in: `frontend/ios/Runner/GoogleService-Info.plist`
- [ ] Email/Password authentication enabled
- [ ] Firebase Admin SDK credentials obtained
- [ ] Firebase credentials added to backend `.env`:
  - [ ] `FIREBASE_PROJECT_ID`
  - [ ] `FIREBASE_PRIVATE_KEY`
  - [ ] `FIREBASE_CLIENT_EMAIL`

## Phase 4: Claude API Setup ✅

- [ ] Anthropic account created
- [ ] API key obtained from console.anthropic.com
- [ ] API key added to backend `.env` (`CLAUDE_API_KEY`)

## Phase 5: iOS App Configuration ✅

- [ ] Flutter dependencies installed (`flutter pub get`)
- [ ] CocoaPods dependencies installed (`cd ios && pod install`)
- [ ] Xcode project opened (`open ios/Runner.xcworkspace`)
- [ ] Bundle ID verified in Xcode
- [ ] Signing configured (Automatic signing enabled)
- [ ] Team selected in Xcode
- [ ] `GoogleService-Info.plist` verified in Xcode project

## Phase 6: Testing on Simulator ✅

- [ ] iOS Simulator launched
- [ ] Backend server running (`npm run dev` in backend/)
- [ ] App builds successfully (`flutter run -d ios`)
- [ ] App launches without crashes
- [ ] Login screen displays
- [ ] Can create new account
- [ ] Can sign in with created account
- [ ] Home screen displays after login
- [ ] Daily summary shows (may be empty initially)

## Phase 7: Feature Testing ✅

### Authentication
- [ ] Create account works
- [ ] Login works
- [ ] Logout works
- [ ] Persistent login (app restart)

### Manual Expense Entry
- [ ] Manual entry screen opens
- [ ] Can enter amount
- [ ] Can select category
- [ ] Can add description
- [ ] Can select date
- [ ] Expense saves successfully
- [ ] Expense appears on home screen

### Voice Input
- [ ] Voice input screen opens
- [ ] Microphone permission granted
- [ ] Can start recording
- [ ] Can stop recording
- [ ] Transcription appears
- [ ] Parsing works (shows amount and category)
- [ ] Can confirm and save expense

### Expense List
- [ ] Expense list screen opens
- [ ] All expenses displayed
- [ ] Can filter by date
- [ ] Can filter by category
- [ ] Swipe to delete works
- [ ] Delete confirmation works

### Summary/Statistics
- [ ] Summary screen opens
- [ ] Daily tab shows data
- [ ] Weekly tab shows data
- [ ] Monthly tab shows data
- [ ] Category breakdown displays
- [ ] Totals are correct

### Offline Mode
- [ ] Can add expense offline
- [ ] Expense saves locally
- [ ] Can view offline expenses
- [ ] Sync works when online
- [ ] Offline expenses sync to server

## Phase 8: Physical Device Testing ✅

- [ ] iPhone connected via USB
- [ ] Device trusted on Mac
- [ ] Device appears in `flutter devices`
- [ ] Mac's IP address found (`ipconfig getifaddr en0`)
- [ ] Backend CORS updated with Mac's IP
- [ ] App built with device IP (`flutter run --dart-define=API_BASE_URL=...`)
- [ ] App installs on device
- [ ] App launches on device
- [ ] All features work on device
- [ ] Voice input works on device
- [ ] Network requests work

## Phase 9: Troubleshooting ✅

If you encounter issues, check:

- [ ] Backend logs for errors
- [ ] Flutter logs for errors (`flutter logs`)
- [ ] Xcode console for iOS errors
- [ ] Firebase Console for auth issues
- [ ] Network connectivity
- [ ] All environment variables set
- [ ] All configuration files in place

## Notes

Use this space to jot down any issues or notes:

```
Date: ___________

Issues encountered:
1. 
2. 
3. 

Solutions found:
1. 
2. 
3. 

```

## Completion

- [ ] All checklist items completed
- [ ] App fully functional on simulator
- [ ] App fully functional on physical device
- [ ] Ready for further development

---

**Last Updated:** ___________
**Tested By:** ___________
