# Commit Message

## Title
feat: Add drop-in location picker for checkout delivery address

## Description
Implemented an interactive map-based location picker that allows users to visually select their delivery address during checkout. This feature improves accuracy and user experience by enabling GPS-based location selection with automatic address geocoding.

### Key Features
- Interactive Google Maps interface for location selection
- Current location detection using GPS
- Draggable marker for precise positioning
- Automatic geocoding (coordinates to address)
- GPS coordinates display and storage
- Seamless integration with checkout flow

### Changes Made
**New Files:**
- `lib/src/presentation/widgets/location_picker.dart` - Location picker widget
- `GOOGLE_MAPS_SETUP.md` - API key setup guide
- `LOCATION_PICKER_FEATURE.md` - Complete feature documentation
- `CHANGELOG_LOCATION_FEATURE.md` - Detailed changelog
- `QUICK_START_LOCATION_FEATURE.md` - Quick setup guide

**Modified Files:**
- `lib/src/presentation/screens/checkout_screen.dart` - Added location picker integration
- `pubspec.yaml` - Added map and location dependencies
- `android/app/src/main/AndroidManifest.xml` - Added location permissions
- `ios/Runner/Info.plist` - Added location usage descriptions
- `ios/Runner/AppDelegate.swift` - Added Google Maps initialization
- `.env.example` - Added Google Maps API key configuration

**Dependencies Added:**
- google_maps_flutter: ^2.5.0
- geolocator: ^10.1.0
- geocoding: ^2.1.1

### Setup Required
Google Maps API key must be configured in:
1. `android/app/src/main/AndroidManifest.xml`
2. `ios/Runner/AppDelegate.swift`
3. `.env` file

See `GOOGLE_MAPS_SETUP.md` for detailed instructions.

### Benefits
- Improved delivery address accuracy with GPS coordinates
- Better user experience with visual map interface
- Reduced address entry errors
- Helps delivery drivers with precise locations
- Works with informal or hard-to-describe addresses

### Testing
1. Navigate to checkout
2. Select "DELIVERY" order type
3. Click "Pick location on map" button
4. Grant location permission (optional)
5. Select location by tapping or dragging marker
6. Confirm selection
7. Verify address auto-fills in checkout

### Screenshots Needed
- [ ] Checkout screen with "Pick location on map" button
- [ ] Location picker with map and marker
- [ ] GPS coordinates badge display
- [ ] Address auto-filled after selection

### Breaking Changes
None - Feature is additive and backward compatible

### Notes
- Location coordinates are optional (users can still type addresses)
- Feature gracefully degrades without API key (coordinates still work)
- All existing functionality remains unchanged
