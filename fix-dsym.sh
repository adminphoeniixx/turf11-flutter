#!/bin/bash

# dSYM Fix Script for Flutter iOS Build
# This script automatically cleans and rebuilds the Flutter iOS project

set -e  # Exit on error

PROJECT_ROOT="$(pwd)"
XCODE_DERIVED_DATA="$HOME/Library/Developer/Xcode/DerivedData"

echo "🔧 Starting dSYM Fix Process..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Step 1: Flutter Clean
echo "📦 Step 1: Cleaning Flutter build..."
flutter clean
rm -rf build/
echo "✅ Flutter cleaned"

# Step 2: Xcode Cache Clean
echo "🗑️  Step 2: Cleaning Xcode DerivedData..."
rm -rf "$XCODE_DERIVED_DATA"
echo "✅ Xcode cache cleaned"

# Step 3: CocoaPods Clean
echo "🍫 Step 3: Cleaning CocoaPods..."
cd ios/
rm -rf Pods
rm -f Podfile.lock
cd "$PROJECT_ROOT"
echo "✅ CocoaPods cleaned"

# Step 4: Get Flutter dependencies
echo "📥 Step 4: Getting Flutter dependencies..."
flutter pub get
echo "✅ Flutter dependencies installed"

# Step 5: Update and Install Pods
echo "🍫 Step 5: Updating and installing CocoaPods..."
cd ios/
pod repo update
pod install --repo-update
cd "$PROJECT_ROOT"
echo "✅ CocoaPods dependencies installed"

# Step 6: Build iOS Release
echo "🔨 Step 6: Building iOS Release..."
flutter build ios --release --no-tree-shake-icons

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ dSYM Fix Process Complete!"
echo ""
echo "📝 Next Steps:"
echo "1. The build output is in: build/ios/iphoneos/Runner.app"
echo "2. To create an archive in Xcode:"
echo "   - Open ios/Runner.xcworkspace (NOT .xcodeproj)"
echo "   - Select Product > Archive"
echo "3. The archive should now include proper dSYM files"
echo ""
echo "🐛 If issues persist, run: flutter doctor -v"
