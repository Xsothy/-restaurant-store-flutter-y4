# Drop-in Location Feature for Checkout

## Overview

This feature allows users to select their delivery location using an interactive Google Maps interface during checkout. Users can pick their precise delivery location by dropping a pin on the map, which automatically converts to a formatted address.

## Features

### 1. Interactive Map Location Picker
- **Visual map interface** using Google Maps
- **Current location detection** - Users can quickly use their current GPS location
- **Tap to select** - Simply tap anywhere on the map to set delivery location
- **Draggable marker** - Fine-tune the location by dragging the pin
- **Address geocoding** - Automatically converts GPS coordinates to readable addresses
- **GPS coordinates display** - Shows exact latitude/longitude for precision

### 2. Checkout Integration
- **"Pick location on map" button** - Easy access from the checkout screen
- **Address auto-fill** - Selected location automatically fills the delivery address field
- **GPS coordinates saved** - Location coordinates are stored with the address
- **Visual confirmation** - Shows GPS coordinates badge when location is selected
- **Edit capability** - Users can change their selection anytime before placing order

## User Flow

1. User navigates to checkout screen
2. Selects "DELIVERY" as order type
3. Clicks "Pick location on map" button
4. Location picker opens with interactive map
5. User can:
   - Tap "Use current location" icon to get GPS position
   - Tap anywhere on map to select location
   - Drag the marker to adjust position
6. Selected address appears at bottom of screen
7. User confirms location
8. Returns to checkout with address auto-filled
9. GPS coordinates displayed in info badge
10. User can modify or change location if needed

## Technical Implementation

### Dependencies Added
- `google_maps_flutter: ^2.5.0` - Interactive map widget
- `geolocator: ^10.1.0` - GPS location services
- `geocoding: ^2.1.1` - Address from coordinates conversion

### New Files
- `lib/src/presentation/widgets/location_picker.dart` - Main location picker widget
- `GOOGLE_MAPS_SETUP.md` - Google Maps API key setup instructions
- `LOCATION_PICKER_FEATURE.md` - This documentation

### Modified Files
- `lib/src/presentation/screens/checkout_screen.dart` - Added location picker integration
- `pubspec.yaml` - Added map and location dependencies
- `android/app/src/main/AndroidManifest.xml` - Added location permissions
- `ios/Runner/Info.plist` - Added location usage descriptions
- `ios/Runner/AppDelegate.swift` - Added Google Maps initialization
- `.env.example` - Added Google Maps API key placeholder

### Data Storage
The checkout screen now stores:
- `_selectedLocation: LatLng?` - Selected coordinates
- `_deliveryLatitude: double?` - Latitude value
- `_deliveryLongitude: double?` - Longitude value
- `_addressController.text` - Human-readable address

## Platform Configuration

### Android
1. Location permissions added to AndroidManifest.xml
2. Google Maps API key placeholder added
3. Internet permission included

### iOS
1. Location usage descriptions added to Info.plist
2. Google Maps SDK initialization in AppDelegate
3. API key placeholder configured

## Setup Instructions

### 1. Get Google Maps API Key
- Visit [Google Cloud Console](https://console.cloud.google.com/)
- Create/select project
- Enable required APIs:
  - Maps SDK for Android
  - Maps SDK for iOS
  - Geocoding API
- Create API Key

### 2. Configure API Key

**Android:** Update `/android/app/src/main/AndroidManifest.xml`
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ACTUAL_API_KEY" />
```

**iOS:** Update `/ios/Runner/AppDelegate.swift`
```swift
GMSServices.provideAPIKey("YOUR_ACTUAL_API_KEY")
```

**Environment:** Update `.env`
```env
GOOGLE_MAPS_API_KEY=your-google-maps-api-key
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Run App
```bash
flutter run
```

## Location Permissions

### Android
The app requests:
- `ACCESS_FINE_LOCATION` - For precise GPS coordinates
- `ACCESS_COARSE_LOCATION` - For approximate location
- `INTERNET` - For map tiles

### iOS
The app explains location usage:
- "This app needs access to your location to set your delivery address"
- Permissions requested only when user taps "Use current location"

## UI Components

### Location Picker Screen
- **App bar** with title and current location button
- **Full-screen map** showing selected area
- **Draggable marker** at selected position
- **Bottom sheet** showing:
  - Location icon
  - "Selected Location" label
  - Formatted address or GPS coordinates
  - "Confirm Location" button

### Checkout Screen Additions
- **"Pick location on map" button** - Opens location picker
- **GPS coordinates badge** - Shows when location selected
- **Address field** - Auto-filled from map selection

## Error Handling

The feature handles:
- **Location permission denied** - Shows error message
- **Location services disabled** - Prompts user to enable
- **Geocoding failures** - Falls back to GPS coordinates
- **No internet connection** - Map may not load, but coordinates still work
- **Invalid API key** - Shows development watermark on map

## Testing Without API Key

The app can be tested without a valid API key:
- Map tiles won't load properly
- "For development purposes only" watermark appears
- Location selection still works
- GPS coordinates are still accurate
- Geocoding may fail

For better testing experience, use a development API key.

## Future Enhancements

Potential improvements:
- Save favorite delivery locations
- Show nearby landmarks
- Display delivery radius/zone
- Integration with delivery time estimation
- Support for multiple delivery addresses
- Address search/autocomplete
- Map style customization
- Offline map support

## Benefits

1. **Better accuracy** - GPS coordinates ensure precise delivery
2. **User-friendly** - Visual map easier than typing addresses
3. **Reduced errors** - Less chance of incorrect addresses
4. **Better UX** - Modern, interactive interface
5. **Driver assistance** - Exact coordinates help delivery drivers
6. **Flexibility** - Works even with informal addresses
