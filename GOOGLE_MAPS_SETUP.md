# Google Maps Setup

This application uses Google Maps for location picking during checkout. To enable this feature, you need to configure Google Maps API keys.

## Getting Your Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the following APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Geocoding API
4. Create credentials (API Key)
5. Restrict the API key to your application (recommended for production)

## Configuration

### Android

Update the API key in `/android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ACTUAL_API_KEY_HERE" />
```

### iOS

Update the API key in `/ios/Runner/AppDelegate.swift`:

```swift
GMSServices.provideAPIKey("YOUR_ACTUAL_API_KEY_HERE")
```

### Web (Optional)

For web support, add the API key to `/web/index.html` in the `<head>` section:

```html
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_ACTUAL_API_KEY_HERE"></script>
```

## Testing Without API Key

The location picker will still work but:
- The map tiles won't load properly
- You'll see "For development purposes only" watermark
- Consider adding a test/development API key for better experience

## Features

The location picker allows users to:
- View their current location
- Pick a delivery location by tapping on the map
- Drag the marker to adjust location
- Get a formatted address from coordinates
- See GPS coordinates of the selected location
