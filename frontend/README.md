# Flutter Frontend - Pocketa Expense Tracker

Flutter mobile application for tracking daily expenses with voice input support.

## Setup

1. Install Flutter dependencies:
```bash
flutter pub get
```

2. Configure Firebase:
   - Download `google-services.json` from Firebase Console
   - Place it in `android/app/google-services.json`
   - Download `GoogleService-Info.plist` from Firebase Console
   - Place it in `ios/Runner/GoogleService-Info.plist`

3. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                  # Data models
│   ├── expense.dart
│   └── summary.dart
├── providers/               # Riverpod state management
│   ├── auth_provider.dart
│   ├── expense_provider.dart
│   ├── summary_provider.dart
│   ├── voice_provider.dart
│   └── network_provider.dart
├── screens/                 # UI screens
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── voice_input_screen.dart
│   ├── manual_entry_screen.dart
│   ├── expense_list_screen.dart
│   └── summary_screen.dart
├── services/                # API & local services
│   ├── api_service.dart
│   ├── firebase_service.dart
│   ├── storage_service.dart
│   ├── voice_service.dart
│   ├── local_db_service.dart
│   ├── sync_service.dart
│   └── widget_service.dart
├── widgets/                 # Reusable widgets
│   ├── expense_card.dart
│   ├── category_chip.dart
│   ├── amount_display.dart
│   ├── date_picker.dart
│   └── loading_indicator.dart
├── theme/                   # App theme
│   └── app_theme.dart
└── utils/                   # Utilities
    └── constants.dart
```

## Features

### Authentication
- Email/password authentication via Firebase
- Automatic token management
- Persistent login state

### Expense Management
- Create expenses via voice or manual entry
- View all expenses with filtering
- Edit and delete expenses
- Offline support with sync

### Voice Input
- Speech-to-text conversion
- Natural language parsing via Claude API
- Real-time transcription

### Analytics
- Daily summary with category breakdown
- Weekly summary
- Monthly summary
- Visual category representation

### Offline Support
- Local SQLite database
- Sync queue for offline operations
- Automatic sync when online

## Configuration

### API Base URL

Set the API base URL when building:
```bash
flutter build apk --dart-define=API_BASE_URL=https://your-api-url.com
```

Or set it in `lib/utils/constants.dart`:
```dart
static const String apiBaseUrl = 'https://your-api-url.com';
```

## Platform-Specific Setup

### iOS

1. Add microphone permission to `ios/Runner/Info.plist`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to your microphone...</string>
```

2. Configure Firebase:
   - Add `GoogleService-Info.plist` to `ios/Runner/`

### Android

1. Permissions are already configured in `AndroidManifest.xml`

2. Configure Firebase:
   - Add `google-services.json` to `android/app/`

## Widget Support

### iOS Widget
- Widget extension code is in `ios/Runner/WidgetExtension/`
- Requires additional Xcode configuration

### Android Widget
- Widget provider code is in `android/app/src/main/java/.../widget/`
- Requires widget layout XML files

## Testing

Run tests:
```bash
flutter test
```

## Building

### Android APK
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Dependencies

Key dependencies:
- `flutter_riverpod` - State management
- `firebase_core`, `firebase_auth` - Firebase integration
- `http` - API calls
- `sqflite` - Local database
- `speech_to_text` - Voice input
- `connectivity_plus` - Network status
- `shared_preferences` - Local storage

## Troubleshooting

### Firebase Not Initialized
- Ensure Firebase configuration files are in place
- Check Firebase project settings

### Voice Input Not Working
- Grant microphone permissions
- Check device microphone access

### API Connection Issues
- Verify API_BASE_URL is set correctly
- Check network connectivity
- Ensure backend is running
