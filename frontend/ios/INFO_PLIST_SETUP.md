# iOS Info.plist Configuration

## Important Note

Flutter generates its own `Info.plist` file. You need to **add** the microphone and speech recognition permissions to the existing file, not replace it.

## How to Add Permissions

### Option 1: Edit in Xcode (Recommended)

1. Open the project in Xcode:
```bash
cd frontend/ios
open Runner.xcworkspace
```

2. In Xcode:
   - Select **Runner** in the project navigator
   - Select **Info** tab
   - Click the **+** button to add new keys
   - Add these keys:

**Key:** `Privacy - Microphone Usage Description`  
**Type:** String  
**Value:** `This app needs access to your microphone to record voice input for expense entries.`

**Key:** `Privacy - Speech Recognition Usage Description`  
**Type:** String  
**Value:** `This app needs speech recognition to convert your voice input into text.`

### Option 2: Edit Info.plist Directly

If you prefer to edit the file directly:

1. Open `frontend/ios/Runner/Info.plist`
2. Add these entries inside the `<dict>` tag:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to your microphone to record voice input for expense entries.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app needs speech recognition to convert your voice input into text.</string>
```

### Option 3: Use Flutter Configuration

You can also add these in `pubspec.yaml` (though Info.plist editing is more reliable):

```yaml
flutter:
  # ... other config
```

But for permissions, editing Info.plist directly is recommended.

## Verify Permissions

After adding, verify the file contains:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<!-- Other Flutter keys -->
	<key>CFBundleDevelopmentRegion</key>
	<string>$(DEVELOPMENT_LANGUAGE)</string>
	<!-- ... other keys ... -->
	
	<!-- Add these: -->
	<key>NSMicrophoneUsageDescription</key>
	<string>This app needs access to your microphone to record voice input for expense entries.</string>
	<key>NSSpeechRecognitionUsageDescription</key>
	<string>This app needs speech recognition to convert your voice input into text.</string>
</dict>
</plist>
```

## Testing Permissions

After adding permissions:

1. Clean build:
```bash
cd frontend
flutter clean
flutter pub get
```

2. Rebuild:
```bash
flutter run -d ios
```

3. When you first use voice input, iOS will prompt for permission.
