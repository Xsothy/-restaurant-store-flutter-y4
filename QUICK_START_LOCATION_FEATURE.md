# Quick Start - Location Picker Feature

## 🚀 Quick Setup (5 minutes)

### 1. Install Dependencies
```bash
cd /home/engine/project
flutter pub get
```

### 2. Create Asset Directories (if not exists)
```bash
mkdir -p assets/images assets/animations assets/icons
```

### 3. Setup Environment File
```bash
cp .env.example .env
```

### 4. Configure Google Maps API Key

#### Get Your Free API Key
1. Go to https://console.cloud.google.com/
2. Create a project
3. Enable these APIs:
   - Maps SDK for Android
   - Maps SDK for iOS  
   - Geocoding API
4. Create API Key (free tier available)

#### Add API Key to Files

**Android:** Edit `android/app/src/main/AndroidManifest.xml` (line 40-42)
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ACTUAL_API_KEY_HERE" />
```

**iOS:** Edit `ios/Runner/AppDelegate.swift` (line 11)
```swift
GMSServices.provideAPIKey("YOUR_ACTUAL_API_KEY_HERE")
```

**Environment:** Edit `.env`
```env
GOOGLE_MAPS_API_KEY=YOUR_ACTUAL_API_KEY_HERE
```

### 5. Run the App
```bash
flutter run
```

## ✅ Testing the Feature

1. Launch app and login/register
2. Add items to cart
3. Go to checkout
4. Select **"DELIVERY"** as order type
5. Click **"Pick location on map"** button
6. Grant location permission when prompted
7. Tap **current location icon** in app bar (or tap map)
8. Tap anywhere on map to set location
9. Drag marker to fine-tune
10. Click **"Confirm Location"**
11. See address auto-filled in checkout ✨

## 🔍 What You Should See

### Checkout Screen
- "Pick location on map" button below address field
- GPS coordinates badge when location selected
- Address auto-filled from map selection

### Location Picker
- Full-screen Google Map
- Current location button (top-right)
- Draggable red marker
- Bottom sheet with selected address
- "Confirm Location" button

## 🐛 Troubleshooting

### Map Not Loading
- **Cause:** Invalid or missing API key
- **Fix:** Double-check API key in both Android and iOS files
- **Temporary:** App still works, just no map tiles

### "Location Permission Denied"
- **Cause:** User denied location access
- **Fix:** User can manually tap on map instead

### "Location Services Disabled"
- **Cause:** GPS is off on device
- **Fix:** Enable location in device settings

### Geocoding Fails
- **Cause:** No internet or API limit reached
- **Fix:** App falls back to showing GPS coordinates

### Build Errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

## 📱 Platform-Specific Notes

### Android
- Location permissions auto-requested
- Works on emulator (use extended controls to set location)
- Works on physical device with GPS

### iOS
- Permission dialog shows custom message
- Simulator: Use Features > Location > Custom Location
- Physical device: GPS must be enabled

### Web
- Not fully configured yet
- Requires additional web-specific setup
- Mobile platforms are primary target

## 🎯 Usage Tips

**For Best Results:**
1. Grant location permission for quick setup
2. Use map zoom controls to navigate
3. Drag marker for precise placement
4. Tap "current location" to quickly center on you
5. Check GPS coordinates badge to verify selection

**Without Location Permission:**
- Can still tap anywhere on map
- Default location: Phnom Penh, Cambodia (11.5564, 104.9282)
- Can manually navigate map and select location

## 📚 More Documentation

- **Complete Feature Docs:** `LOCATION_PICKER_FEATURE.md`
- **API Key Setup:** `GOOGLE_MAPS_SETUP.md`
- **Change Log:** `CHANGELOG_LOCATION_FEATURE.md`

## 🆘 Getting Help

If you encounter issues:

1. **Check API Key:** Most common issue
2. **Verify Permissions:** Android Manifest & iOS Info.plist
3. **Review Logs:** `flutter run --verbose`
4. **Clean Build:** `flutter clean && flutter pub get`
5. **Check Docs:** See files listed above

## ⚡ Development Mode

For quick development without setting up API key:

1. Map won't render (shows watermark)
2. Location selection still works
3. GPS coordinates are still captured
4. Address geocoding may fail (falls back to coordinates)

**Note:** Get an API key for production use!

## 🎉 Success Criteria

You've successfully set it up when:
- ✅ Map tiles load properly
- ✅ Current location button works
- ✅ Can tap/drag marker
- ✅ Address appears in bottom sheet
- ✅ Returns to checkout with address filled
- ✅ GPS coordinates badge shows

Ready to order! 🍕
