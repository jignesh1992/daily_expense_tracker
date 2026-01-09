#!/bin/bash

# Script to help run Flutter app on physical iOS device
# Usage: ./run-on-device.sh

set -e

echo "📱 Flutter iOS Device Runner"
echo "============================"
echo ""

# Check if we're in the right directory
if [ ! -d "frontend" ]; then
    echo "❌ Error: Please run this script from the project root directory"
    exit 1
fi

# Step 1: Get Mac's IP address
echo "Step 1: Finding Mac's IP address..."
MAC_IP=$(ipconfig getifaddr en0)
if [ -z "$MAC_IP" ]; then
    MAC_IP=$(ipconfig getifaddr en1)
fi

if [ -z "$MAC_IP" ]; then
    echo "❌ Error: Could not find Mac's IP address"
    echo "Please check your network connection"
    exit 1
fi

echo "✅ Mac IP Address: $MAC_IP"
echo ""

# Step 2: Check if backend is running
echo "Step 2: Checking if backend is running..."
if curl -s http://localhost:3000/health > /dev/null 2>&1; then
    echo "✅ Backend is running on port 3000"
else
    echo "⚠️  Warning: Backend doesn't seem to be running"
    echo "Please start the backend in another terminal:"
    echo "  cd backend && npm run dev"
    echo ""
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi
echo ""

# Step 3: List available devices
echo "Step 3: Checking for connected devices..."
echo ""
flutter devices
echo ""

# Step 4: Get device ID
echo "Step 4: Select your device"
echo "Please enter your device ID from the list above (or press Enter to use first iOS device):"
read -r DEVICE_ID

if [ -z "$DEVICE_ID" ]; then
    # Try to auto-detect first iOS device
    DEVICE_ID=$(flutter devices | grep -i "ios" | head -1 | awk '{print $5}')
    if [ -z "$DEVICE_ID" ]; then
        echo "❌ Error: No iOS device found"
        echo "Please connect your iPhone via USB and try again"
        exit 1
    fi
    echo "Using device: $DEVICE_ID"
fi
echo ""

# Step 5: Update backend CORS (optional)
echo "Step 5: Backend CORS configuration"
echo "Your backend CORS_ORIGIN should be set to: http://$MAC_IP:3000"
echo "Check backend/.env file and update if needed"
echo ""
read -p "Have you updated backend/.env CORS_ORIGIN? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "⚠️  Please update backend/.env before continuing:"
    echo "   CORS_ORIGIN=http://$MAC_IP:3000"
    echo ""
    read -p "Press Enter after updating .env file..."
fi
echo ""

# Step 6: Build and run
echo "Step 6: Building and running app on device..."
echo "This may take 5-10 minutes on first run..."
echo ""

cd frontend

API_URL="http://$MAC_IP:3000"

echo "Running with:"
echo "  - API URL: $API_URL"
echo "  - Device: $DEVICE_ID"
echo ""

flutter run --dart-define=API_BASE_URL="$API_URL" -d "$DEVICE_ID"
