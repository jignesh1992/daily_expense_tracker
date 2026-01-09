# 🚀 Start Here - iOS Setup Guide

Welcome! This guide will help you set up and test the Pocketa Expense Tracker iOS app.

## Choose Your Path

### 🏃 Quick Start (15 minutes)
If you're experienced with Flutter/iOS development:
→ **[QUICK_START_IOS.md](QUICK_START_IOS.md)**

### 📚 Detailed Guide (30-45 minutes)
For step-by-step instructions with explanations:
→ **[SETUP_IOS.md](SETUP_IOS.md)**

### ✅ Checklist Format
If you prefer a checklist to track progress:
→ **[IOS_SETUP_CHECKLIST.md](IOS_SETUP_CHECKLIST.md)**

## What You'll Need

Before starting, ensure you have:

1. **Mac with macOS** (required for iOS development)
2. **Xcode** (from Mac App Store - free)
3. **Flutter SDK** (v3.0+)
4. **Node.js** (v18+)
5. **PostgreSQL** (local or cloud)
6. **Firebase account** (free tier works)
7. **Claude API key** (from Anthropic)

## Quick Overview

The setup involves 4 main steps:

1. **Backend Setup** (5 min)
   - Install dependencies
   - Configure database
   - Set environment variables

2. **Firebase Setup** (5 min)
   - Create Firebase project
   - Add iOS app
   - Download config file
   - Enable authentication

3. **iOS App Setup** (5 min)
   - Install Flutter dependencies
   - Install CocoaPods
   - Configure Xcode

4. **Testing** (5 min)
   - Run on simulator
   - Test features
   - Verify everything works

## Automated Setup

We've included a setup script to help:

```bash
./setup-ios.sh
```

This will:
- ✅ Check prerequisites
- ✅ Install dependencies
- ✅ Set up basic configuration
- ⚠️  You'll still need to configure `.env` files manually

## Common First-Time Issues

### "Flutter not found"
```bash
# Install Flutter
brew install --cask flutter

# Verify
flutter doctor
```

### "CocoaPods not found"
```bash
sudo gem install cocoapods
```

### "Xcode Command Line Tools"
```bash
xcode-select --install
```

### "Database connection failed"
- Make sure PostgreSQL is running
- Check DATABASE_URL in `.env`
- Verify database exists

## Getting Help

1. **Check the detailed guide**: [SETUP_IOS.md](SETUP_IOS.md)
2. **Review troubleshooting section** in SETUP_IOS.md
3. **Check error logs**:
   - Backend: Terminal running `npm run dev`
   - Flutter: `flutter logs`
   - Xcode: Xcode console

## Next Steps After Setup

Once everything is working:

1. ✅ Test all features (see checklist)
2. 📱 Test on physical device
3. 🔧 Customize for your needs
4. 🚀 Prepare for App Store (if desired)

## File Structure

```
daily_expense_tracker/
├── backend/              # Node.js API
│   ├── src/
│   ├── prisma/
│   └── .env             # ← Configure this
├── frontend/            # Flutter app
│   ├── lib/
│   ├── ios/
│   │   └── Runner/
│   │       └── GoogleService-Info.plist  # ← Add this
│   └── pubspec.yaml
├── SETUP_IOS.md         # Detailed guide
├── QUICK_START_IOS.md   # Quick reference
├── IOS_SETUP_CHECKLIST.md  # Checklist
└── setup-ios.sh         # Setup script
```

## Ready to Start?

1. **First time?** → Start with [SETUP_IOS.md](SETUP_IOS.md)
2. **Experienced?** → Use [QUICK_START_IOS.md](QUICK_START_IOS.md)
3. **Want checklist?** → Use [IOS_SETUP_CHECKLIST.md](IOS_SETUP_CHECKLIST.md)

Good luck! 🎉
