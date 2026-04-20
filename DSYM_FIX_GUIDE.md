# dSYM Missing UUID Error - Resolution Guide

## Error Description
The archive is missing a dSYM for `objective_c.framework` with UUID `10A536B7-4215-3B8F-A80A-2A2E525DBE60`.

## Root Causes
1. **Stale build cache** - Flutter/Xcode cache contains mismatched binaries
2. **Pod cache corruption** - CocoaPods dependency cache is outdated
3. **iOS deployment target mismatch** - Pod requirements don't align with project settings
4. **Bitcode settings** - Inconsistent bitcode configuration
5. **Architecture mismatch** - Build architectures don't align across all targets

## Solution Steps (In Order)

### Step 1: Clean Flutter Build (Required)
```bash
flutter clean
rm -rf build/
```

### Step 2: Clean Xcode Build Cache (Required)
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

### Step 3: Clean CocoaPods Cache (Required)
```bash
cd ios/
rm -rf Pods
rm Podfile.lock
cd ..
```

### Step 4: Verify iOS Deployment Target
Check that your iOS deployment target matches minimum requirements:
- Open `ios/Podfile`
- Ensure the platform line is set to at least iOS 13
- Update if needed: `platform :ios, '13.0'`

### Step 5: Update Dependencies
```bash
cd ios/
pod repo update
pod install --repo-update
cd ..
```

### Step 6: Get Flutter Dependencies
```bash
flutter pub get
flutter pub get --no-example
```

### Step 7: Build with Clean Flags
For Debug builds:
```bash
flutter build ios --debug --clean
```

For Release builds:
```bash
flutter build ios --release --clean
```

For creating an archive:
```bash
flutter build ios --release --no-tree-shake-icons
```

### Step 8: If problem persists - Update Flutter
```bash
flutter upgrade
flutter doctor -v
```

### Step 9: Advanced Fix - Reset Xcode Settings
```bash
defaults write com.apple.dt.Xcode IDESourceTreeDisplayNames -dict-add SOURCE_ROOT "Source Root"
```

### Step 10: Rebuild the Archive
1. Open `ios/Runner.xcworkspace` (NOT .xcodeproj)
2. Select "Runner" project → "Runner" target
3. Go to Build Settings
4. Search for "Strip Linked Product"
5. Set it to "No"
6. Scheme → Archive → Release

## Quick Command Sequence (Recommended)

Run these commands in order:
```bash
# Navigate to project root
cd /Users/rahul/Documents/Nitins_Project/turf11-flutter

# Clean everything
flutter clean
rm -rf build/ ios/Pods ios/Podfile.lock ~/Library/Developer/Xcode/DerivedData/*

# Get fresh dependencies
flutter pub get

# Update iOS pods
cd ios/
pod repo update
pod install --repo-update
cd ..

# Build release
flutter build ios --release --no-tree-shake-icons
```

## Verification Checklist
- [ ] All caches cleaned (Flutter, Xcode, CocoaPods)
- [ ] Podfile.lock regenerated
- [ ] iOS deployment target is ≥ 13.0
- [ ] Dependencies updated
- [ ] Build completed without errors
- [ ] Archive created successfully with dSYM files

## If Still Having Issues
1. Check Xcode version: `xcode-select --version`
2. Verify iOS SDK: `xcrun --show-sdk-version`
3. Check Flutter version: `flutter --version`
4. Run: `flutter doctor -v`
5. Check project setup: Open in Xcode and validate target settings

## Build Settings to Verify (in Xcode)
- STRIP_INSTALLED_PRODUCT: False
- DEBUG_INFORMATION_FORMAT: dwarf-with-dsym (for Release)
- ENABLE_BITCODE: False (for Flutter iOS)
- VALID_ARCHS: arm64 (for Release on physical device)
