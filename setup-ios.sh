#!/bin/bash

# iOS Setup Script for Pocketa Expense Tracker
# This script helps automate the iOS setup process

set -e

echo "🚀 Pocketa Expense Tracker - iOS Setup"
echo "========================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

# Check prerequisites
echo "📋 Checking prerequisites..."
echo ""

# Check Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    print_success "Node.js installed: $NODE_VERSION"
else
    print_error "Node.js not found. Please install Node.js 18+ from https://nodejs.org"
    exit 1
fi

# Check Flutter
if command -v flutter &> /dev/null; then
    FLUTTER_VERSION=$(flutter --version | head -n 1)
    print_success "Flutter installed: $FLUTTER_VERSION"
else
    print_error "Flutter not found. Please install Flutter from https://flutter.dev"
    exit 1
fi

# Check Xcode
if command -v xcodebuild &> /dev/null; then
    XCODE_VERSION=$(xcodebuild -version | head -n 1)
    print_success "Xcode installed: $XCODE_VERSION"
else
    print_error "Xcode not found. Please install Xcode from Mac App Store"
    exit 1
fi

# Check CocoaPods
if command -v pod &> /dev/null; then
    POD_VERSION=$(pod --version)
    print_success "CocoaPods installed: $POD_VERSION"
else
    print_info "CocoaPods not found. Installing..."
    sudo gem install cocoapods
    print_success "CocoaPods installed"
fi

echo ""
echo "📦 Setting up backend..."
echo ""

# Backend setup
if [ -d "backend" ]; then
    cd backend
    
    if [ ! -f ".env" ]; then
        print_info "Creating .env file from .env.example..."
        cp .env.example .env
        print_info "⚠️  Please edit backend/.env with your configuration"
    else
        print_success ".env file exists"
    fi
    
    print_info "Installing backend dependencies..."
    npm install
    
    print_info "Generating Prisma client..."
    npm run prisma:generate || print_error "Prisma generate failed. Make sure DATABASE_URL is set in .env"
    
    print_success "Backend setup complete"
    cd ..
else
    print_error "Backend directory not found"
    exit 1
fi

echo ""
echo "📱 Setting up iOS app..."
echo ""

# Frontend setup
if [ -d "frontend" ]; then
    cd frontend
    
    print_info "Installing Flutter dependencies..."
    flutter pub get
    
    print_info "Checking for GoogleService-Info.plist..."
    if [ -f "ios/Runner/GoogleService-Info.plist" ]; then
        print_success "GoogleService-Info.plist found"
    else
        print_error "GoogleService-Info.plist not found!"
        print_info "Please download it from Firebase Console and place it in:"
        print_info "  frontend/ios/Runner/GoogleService-Info.plist"
    fi
    
    cd ios
    
    print_info "Installing CocoaPods dependencies..."
    pod install
    
    print_success "iOS setup complete"
    cd ../..
else
    print_error "Frontend directory not found"
    exit 1
fi

echo ""
echo "🔍 Running Flutter doctor..."
flutter doctor

echo ""
echo "✨ Setup complete!"
echo ""
echo "📝 Next steps:"
echo "1. Configure backend/.env with your database, Firebase, and Claude API keys"
echo "2. Ensure GoogleService-Info.plist is in frontend/ios/Runner/"
echo "3. Start backend: cd backend && npm run dev"
echo "4. Run iOS app: cd frontend && flutter run -d ios"
echo ""
echo "For detailed instructions, see SETUP_IOS.md"
