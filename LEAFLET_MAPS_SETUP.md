# Leaflet Maps Setup

This application uses Leaflet (via flutter_map) with OpenStreetMap tiles for location picking during checkout. Unlike Google Maps, Leaflet with OpenStreetMap does not require API keys for basic usage.

## Dependencies

The following packages are used for maps and location functionality:

- **flutter_map**: ^6.1.0 - Flutter implementation of Leaflet maps
- **latlong2**: ^0.9.0 - Latitude/longitude handling
- **geolocator**: ^10.1.0 - Access device location
- **geocoding**: ^2.1.1 - Convert coordinates to addresses

## Configuration

### Android

Location permissions are already configured in `/android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS

Location permissions should be configured in `/ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to your location to show delivery address on the map.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs access to your location to show delivery address on the map.</string>
```

## Map Tiles

By default, the app uses OpenStreetMap tiles which are free and do not require an API key:

```
https://tile.openstreetmap.org/{z}/{x}/{y}.png
```

### Alternative Tile Providers

You can use other tile providers if needed:

1. **Mapbox** (requires API token):
   ```
   https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=YOUR_TOKEN
   ```

2. **Stadia Maps** (requires API key):
   ```
   https://tiles.stadiamaps.com/tiles/osm_bright/{z}/{x}/{y}.png?api_key=YOUR_KEY
   ```

3. **CartoDB** (free, no API key):
   ```
   https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png
   ```

To change the tile provider, update the `urlTemplate` in the `TileLayer` widget in `location_picker.dart`.

## Features

The location picker allows users to:
- View their current location using GPS
- Pick a delivery location by tapping on the map
- Drag the marker to adjust location
- Get a formatted address from coordinates using reverse geocoding
- See GPS coordinates of the selected location
- Interactive map with zoom and pan controls

## Advantages of Leaflet over Google Maps

1. **No API key required** - Works out of the box with OpenStreetMap tiles
2. **Open source** - Fully open source and customizable
3. **No usage limits** - OpenStreetMap tiles are free without quotas
4. **Multiple tile providers** - Easy to switch between different map styles
5. **Privacy** - No tracking or data collection by default

## Usage Notes

- The app uses OpenStreetMap's Nominatim service for geocoding (address lookup)
- Be respectful of OpenStreetMap's tile usage policy
- For high-traffic production apps, consider using a commercial tile provider or hosting your own tile server
- Set an appropriate `userAgentPackageName` to identify your app to tile servers
