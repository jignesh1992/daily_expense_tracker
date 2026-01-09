# Firebase Setup Guide - Detailed Steps

This guide will walk you through setting up Firebase for both the iOS frontend and Node.js backend.

## Prerequisites

- A Google account
- Access to [Firebase Console](https://console.firebase.google.com/)
- Your iOS app Bundle ID (check in Xcode or `frontend/ios/Runner/GoogleService-Info.plist`)

---

## Step 1: Create a Firebase Project

1. **Go to Firebase Console**
   - Visit: https://console.firebase.google.com/
   - Sign in with your Google account

2. **Create a New Project**
   - Click **"Add project"** or **"Create a project"**
   - Enter a project name (e.g., "Daily Expense Tracker")
   - Click **"Continue"**

3. **Configure Google Analytics (Optional)**
   - Choose whether to enable Google Analytics
   - If enabled, select or create an Analytics account
   - Click **"Create project"**

4. **Wait for Project Creation**
   - Firebase will set up your project (takes ~30 seconds)
   - Click **"Continue"** when ready

---

## Step 2: Add iOS App to Firebase

1. **Open Project Settings**
   - In the Firebase Console, click the gear icon ⚙️ next to "Project Overview"
   - Select **"Project settings"**

2. **Add iOS App**
   - Scroll down to the **"Your apps"** section
   - Click the **iOS icon** (🍎) to add an iOS app

3. **Register iOS App**
   - **iOS bundle ID**: Enter your Bundle ID
     - Default: `com.example.pocketaExpenseTracker`
     - Or check in Xcode: Project Navigator → Runner → General → Bundle Identifier
   - **App nickname** (optional): "Daily Expense Tracker iOS"
   - **App Store ID** (optional): Leave blank for now
   - Click **"Register app"**

4. **Download GoogleService-Info.plist**
   - Click **"Download GoogleService-Info.plist"**
   - **IMPORTANT**: Save this file - you'll need it in the next step
   - Click **"Next"**

5. **Skip Additional Steps**
   - You can skip the "Add Firebase SDK" and "Add initialization code" steps
   - Click **"Continue to console"**

---

## Step 3: Place GoogleService-Info.plist in Your Project

1. **Locate the Downloaded File**
   - Find `GoogleService-Info.plist` in your Downloads folder

2. **Replace the Placeholder File**
   - Navigate to: `frontend/ios/Runner/GoogleService-Info.plist`
   - **Replace** the placeholder file with the downloaded file
   - You can do this by:
     - **Option A**: Drag and drop in Finder, replacing the existing file
     - **Option B**: Copy the downloaded file and paste it into `frontend/ios/Runner/`

3. **Verify the File**
   - Open `frontend/ios/Runner/GoogleService-Info.plist` in a text editor
   - It should contain real values like:
     ```xml
     <key>PROJECT_ID</key>
     <string>your-actual-project-id</string>
     <key>BUNDLE_ID</key>
     <string>com.example.pocketaExpenseTracker</string>
     <key>API_KEY</key>
     <string>AIza...</string>
     <!-- ... many more keys ... -->
     ```

---

## Step 4: Enable Firebase Authentication

1. **Navigate to Authentication**
   - In Firebase Console, click **"Authentication"** in the left sidebar
   - Click **"Get started"** if prompted

2. **Enable Email/Password Sign-in**
   - Click on the **"Sign-in method"** tab
   - Find **"Email/Password"** in the list
   - Click on it
   - Toggle **"Enable"** to ON
   - Click **"Save"**

3. **Enable Google Sign-in (Optional - for future use)**
   - Find **"Google"** in the Sign-in providers list
   - Click on it
   - Toggle **"Enable"** to ON
   - Enter a project support email
   - Click **"Save"**

---

## Step 5: Set Up Firebase Admin SDK (for Backend)

The backend needs Admin SDK credentials to verify Firebase tokens.

1. **Open Project Settings**
   - Click the gear icon ⚙️ → **"Project settings"**

2. **Go to Service Accounts Tab**
   - Click on the **"Service accounts"** tab

3. **Generate New Private Key**
   - Click **"Generate new private key"**
   - A dialog will appear warning about keeping the key secure
   - Click **"Generate key"**
   - A JSON file will download (e.g., `your-project-firebase-adminsdk-xxxxx.json`)

4. **Extract Credentials from JSON**
   - Open the downloaded JSON file in a text editor
   - You'll see something like:
     ```json
     {
       "type": "service_account",
       "project_id": "your-project-id",
       "private_key_id": "...",
       "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
       "client_email": "firebase-adminsdk-xxxxx@your-project-id.iam.gserviceaccount.com",
       ...
     }
     ```

5. **Update backend/.env File**
   - Open `backend/.env` in a text editor
   - Replace the Firebase Admin SDK placeholders with values from the JSON:

   ```env
   # Firebase Admin SDK
   FIREBASE_PROJECT_ID=your-project-id
   FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYour actual private key here\n-----END PRIVATE KEY-----\n"
   FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@your-project-id.iam.gserviceaccount.com
   ```

   **Important Notes:**
   - Copy the `project_id` value exactly
   - Copy the entire `private_key` value (including `-----BEGIN PRIVATE KEY-----` and `-----END PRIVATE KEY-----`)
   - Copy the `client_email` value exactly
   - Keep the quotes around `FIREBASE_PRIVATE_KEY`
   - The `\n` in the private key should remain as literal `\n` characters (the backend code will convert them)

6. **Secure the JSON File**
   - **Delete** the downloaded JSON file after copying the values
   - Never commit it to Git (it's already in `.gitignore`)

---

## Step 6: Verify Bundle ID Match

1. **Check Bundle ID in Xcode**
   - Open `frontend/ios/Runner.xcworkspace` in Xcode
   - Select **Runner** in the Project Navigator
   - Go to **General** tab
   - Check **Bundle Identifier** (e.g., `com.example.pocketaExpenseTracker`)

2. **Verify in GoogleService-Info.plist**
   - Open `frontend/ios/Runner/GoogleService-Info.plist`
   - Check the `BUNDLE_ID` value matches exactly

3. **If They Don't Match**
   - **Option A**: Update Bundle ID in Xcode to match Firebase
   - **Option B**: Re-register the iOS app in Firebase with the correct Bundle ID

---

## Step 7: Install CocoaPods Dependencies (iOS)

1. **Navigate to iOS Directory**
   ```bash
   cd frontend/ios
   ```

2. **Install Pods**
   ```bash
   pod install
   ```

   This will install Firebase iOS SDK dependencies.

3. **If Pod Install Fails**
   - Try: `pod repo update` then `pod install`
   - Or: `pod install --repo-update`

---

## Step 8: Verify Firebase Setup

### Frontend Verification

1. **Check GoogleService-Info.plist**
   - File exists at: `frontend/ios/Runner/GoogleService-Info.plist`
   - Contains real project values (not placeholders)

2. **Run the App**
   ```bash
   cd frontend
   flutter run
   ```
   - The app should initialize Firebase without errors
   - Check console logs for Firebase initialization messages

### Backend Verification

1. **Check .env File**
   - All Firebase Admin SDK values are set (not placeholders)
   - `FIREBASE_PROJECT_ID` matches your Firebase project
   - `FIREBASE_PRIVATE_KEY` contains the full private key
   - `FIREBASE_CLIENT_EMAIL` matches the service account email

2. **Start Backend Server**
   ```bash
   cd backend
   npm run dev
   ```
   - Check console for Firebase Admin initialization
   - Should see no Firebase errors

3. **Test Authentication Endpoint**
   - The backend should be able to verify Firebase tokens
   - Test by signing in through the app and checking backend logs

---

## Troubleshooting

### Issue: "Firebase initialization error" in Flutter
- **Solution**: Ensure `GoogleService-Info.plist` is in `frontend/ios/Runner/` and contains real values
- Verify Bundle ID matches between Xcode and Firebase

### Issue: "Firebase Admin initialization error" in Backend
- **Solution**: Check `.env` file formatting:
  - Private key should be in quotes
  - `\n` should be literal characters (not actual newlines)
  - No extra spaces or quotes inside the key

### Issue: "Invalid credentials" error
- **Solution**: 
  - Regenerate the private key in Firebase Console
  - Copy the exact values from the JSON file
  - Ensure no extra characters or formatting issues

### Issue: CocoaPods installation fails
- **Solution**:
  ```bash
   cd frontend/ios
   pod deintegrate
   pod install
   ```

### Issue: Bundle ID mismatch
- **Solution**: 
  - Update Bundle ID in Xcode to match Firebase
  - Or re-register iOS app in Firebase with correct Bundle ID
  - Re-download `GoogleService-Info.plist`

---

## Next Steps

After completing Firebase setup:

1. ✅ **Test Authentication**
   - Run the app and try signing up/signing in
   - Verify tokens are sent to backend

2. ✅ **Test Backend Token Verification**
   - Check backend logs when authenticating
   - Verify no Firebase Admin errors

3. ✅ **Configure CORS** (if needed)
   - Update `CORS_ORIGIN` in `backend/.env` if deploying frontend

4. ✅ **Set Up Claude API Key**
   - Add `CLAUDE_API_KEY` to `backend/.env` for voice input features

---

## Summary Checklist

- [ ] Firebase project created
- [ ] iOS app registered in Firebase
- [ ] `GoogleService-Info.plist` downloaded and placed in `frontend/ios/Runner/`
- [ ] Email/Password authentication enabled in Firebase Console
- [ ] Firebase Admin SDK private key generated
- [ ] Backend `.env` file updated with Firebase Admin credentials
- [ ] Bundle ID verified to match between Xcode and Firebase
- [ ] CocoaPods dependencies installed (`pod install`)
- [ ] Frontend app runs without Firebase errors
- [ ] Backend server starts without Firebase Admin errors

---

## Security Reminders

⚠️ **Never commit these files to Git:**
- `backend/.env` (already in `.gitignore`)
- Firebase Admin SDK JSON key file
- `GoogleService-Info.plist` (contains sensitive keys - consider adding to `.gitignore` if sharing repo)

✅ **Best Practices:**
- Use environment variables for all secrets
- Rotate keys periodically
- Use different Firebase projects for development and production
