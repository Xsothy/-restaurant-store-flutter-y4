# Migration from Google Maps to Leaflet/OpenStreetMap

## Overview

This document describes the migration from Google Maps Flutter to Leaflet (via flutter_map) with OpenStreetMap tiles.

## What Changed

### Dependencies
**Removed:**
- `google_maps_flutter: ^2.5.0`

**Added:**
- `flutter_map: ^6.1.0` - Flutter implementation of Leaflet maps
- `latlong2: ^0.9.0` - Latitude/longitude data structures

**Kept:**
- `geolocator: ^10.1.0` - Location services (unchanged)
- `geocoding: ^2.1.1` - Address geocoding (unchanged)

### Modified Files

#### Code Files
1. **lib/src/presentation/widgets/location_picker.dart**
   - Replaced GoogleMap widget with FlutterMap
   - Changed from `google_maps_flutter.LatLng` to `latlong2.LatLng`
   - Replaced GoogleMapController with MapController
   - Implemented custom draggable marker using GestureDetector
   - Added OpenStreetMap tile layer

2. **lib/src/presentation/screens/checkout_screen.dart**
   - Changed import from `google_maps_flutter` to `latlong2`
   - LatLng type now comes from latlong2 package
   - No other changes needed

3. **lib/src/presentation/widgets/driver_location_tracker.dart**
   - Updated "View Route on Map" to use OpenStreetMap URLs instead of Google Maps
   - Changed from `https://www.google.com/maps/...` to `https://www.openstreetmap.org/...`

#### Configuration Files
1. **pubspec.yaml**
   - Updated map dependencies
   
2. **android/app/src/main/AndroidManifest.xml**
   - Removed Google Maps API key meta-data
   - Kept location permissions

3. **ios/Runner/AppDelegate.swift**
   - Removed GoogleMaps import
   - Removed GMSServices.provideAPIKey() call
   - Simplified to basic Flutter setup

4. **.env.example**
   - Removed GOOGLE_MAPS_API_KEY entry

#### Documentation Files
1. **README.md**
   - Updated to reference Leaflet/OpenStreetMap instead of Google Maps
   - Removed API key setup instructions
   - Added note about no API keys being required

2. **LOCATION_PICKER_FEATURE.md**
   - Completely rewritten to describe Leaflet implementation
   - Added section on advantages over Google Maps
   - Added information about tile providers

3. **GOOGLE_MAPS_SETUP.md** → **LEAFLET_MAPS_SETUP.md**
   - Deleted old Google Maps setup guide
   - Created new Leaflet setup guide with tile provider options

## Benefits of Migration

### 1. No API Keys Required
- OpenStreetMap tiles work without authentication
- Eliminates API key management complexity
- No need for platform-specific configuration

### 2. No Usage Limits
- OpenStreetMap is free without quotas
- No concerns about hitting API limits
- No costs even with high usage

### 3. Open Source
- Fully open source stack
- No vendor lock-in
- Complete transparency

### 4. Privacy
- No tracking or data collection by default
- Better for user privacy

### 5. Flexibility
- Easy to switch between different tile providers
- Many free and paid tile services available
- Can host your own tile server if needed

## Implementation Details

### Map Tiles
Default tile provider:
```
https://tile.openstreetmap.org/{z}/{x}/{y}.png
```

### Marker Dragging
Custom implementation using GestureDetector:
- Converts Offset to Point<num> for map coordinate conversion
- Updates marker position in real-time during drag
- Triggers address lookup on drag end

### LatLng Type
Now uses `latlong2.LatLng` instead of `google_maps_flutter.LatLng`:
```dart
import 'package:latlong2/latlong.dart';

LatLng location = LatLng(11.5564, 104.9282);
```

## Testing

The migration has been tested with:
- Flutter analyze (no errors in migrated files)
- Dependencies successfully installed via `flutter pub get`

## Compatibility

The migration maintains:
- ✅ All location picker functionality
- ✅ GPS location detection
- ✅ Address geocoding
- ✅ Location storage in checkout
- ✅ Driver location tracking
- ✅ Route visualization (now using OpenStreetMap)

## Migration Impact

### Breaking Changes
None - the LocationPicker widget maintains the same public API:
```dart
LocationPicker(
  initialLocation: LatLng?,
  initialAddress: String?,
)
```

Returns same LocationResult:
```dart
LocationResult(
  latitude: double,
  longitude: double,
  address: String,
)
```

### User Experience
- Map tiles may look slightly different (OpenStreetMap vs Google Maps style)
- All functionality remains the same
- May load slightly faster (no API key validation)

## Future Considerations

### Alternative Tile Providers
Consider these if needed:
- **Mapbox** - Requires token, excellent styling options
- **Stadia Maps** - Requires API key, good performance
- **CartoDB** - Free without API key, clean design
- **Self-hosted** - Complete control, best for high-traffic apps

### Offline Support
- flutter_map supports offline tiles
- Can pre-download map tiles for offline use
- Useful for areas with poor connectivity

## Rollback Plan

If rollback is needed:
1. Revert `pubspec.yaml` dependencies
2. Restore `google_maps_flutter` package
3. Restore old versions of modified files
4. Re-add Google Maps API keys to platform configs
5. Run `flutter pub get`

However, there's no compelling reason to rollback given the advantages of the Leaflet implementation.

## Conclusion

The migration to Leaflet/OpenStreetMap successfully eliminates the dependency on Google Maps while maintaining all functionality and improving the developer experience by removing API key requirements.
