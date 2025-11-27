# Driver Location Tracking

This document describes the implementation of real-time driver location tracking in the Restaurant Store Flutter application.

## Overview

The driver location tracking feature enables delivery drivers to share their real-time GPS coordinates with customers, allowing them to track the delivery progress on a map or view the driver's current position.

## Features

- **Real-time Location Updates**: Drivers can update their location via REST API
- **WebSocket Broadcasting**: Location updates are automatically broadcast to subscribed clients
- **Latitude/Longitude Coordinates**: GPS coordinates are stored and transmitted in standard format
- **Live Tracking Widget**: Dedicated UI component for displaying driver location information
- **Delivery Destination Display**: Shows the customer's delivery address from checkout
- **Route Mapping**: View route from driver's current location to delivery destination
- **Map Integration**: Quick link to view driver location or full route on Google Maps

## API Endpoints

### Update Driver Location

**Endpoint**: `PUT /api/deliveries/{deliveryId}/driver-location`

**Description**: Updates the driver's current location with GPS coordinates.

**Request Body**:
```json
{
  "latitude": 11.5564,
  "longitude": 104.9282,
  "currentLocation": "Near Central Market, Phnom Penh"
}
```

**Response**:
```json
{
  "success": true,
  "message": "Location updated successfully",
  "data": {
    "id": 123,
    "orderId": 456,
    "driverName": "John Doe",
    "driverPhone": "+855 12 345 678",
    "vehicleInfo": "Honda Wave - 1A-1234",
    "status": "ON_THE_WAY",
    "currentLocation": "Near Central Market, Phnom Penh",
    "latitude": 11.5564,
    "longitude": 104.9282,
    "estimatedArrivalTime": "2024-01-15T14:30:00Z",
    "createdAt": "2024-01-15T13:00:00Z",
    "updatedAt": "2024-01-15T14:15:00Z"
  }
}
```

## Data Model

### DeliveryInfo

The `DeliveryInfo` model has been enhanced with location fields:

```dart
class DeliveryInfo {
  final int id;
  final int orderId;
  final String? driverName;
  final String? driverPhone;
  final String? vehicleInfo;
  final String status;
  final DateTime? pickupTime;
  final DateTime? estimatedArrivalTime;
  final DateTime? actualDeliveryTime;
  final String? deliveryNotes;
  final String? currentLocation;
  final double? latitude;        // New field
  final double? longitude;       // New field
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
```

## WebSocket Integration

### Real-time Updates

When a driver updates their location, the updated `DeliveryInfo` is automatically broadcast to:

- `/topic/deliveries/{orderId}` - Full delivery updates
- `/topic/deliveries/{orderId}/location` - Location-specific updates

### Subscribing to Updates

```dart
// Using StompTrackingService
final stompService = StompTrackingService();
stompService.deliveryStream.listen((delivery) {
  print('Driver location: ${delivery.latitude}, ${delivery.longitude}');
  print('Current area: ${delivery.currentLocation}');
});

stompService.connectAndTrack(
  orderId: orderId,
  authToken: authToken,
  onConnected: () => print('Connected'),
  onError: (error) => print('Error: $error'),
);
```

## Flutter Implementation

### OrderProvider

The `OrderProvider` has been updated with a new method for updating driver location:

```dart
Future<bool> updateDriverLocation({
  required int deliveryId,
  required double latitude,
  required double longitude,
  String? currentLocation,
}) async {
  final updatedDelivery = await ApiService.updateDriverLocation(
    deliveryId: deliveryId,
    latitude: latitude,
    longitude: longitude,
    currentLocation: currentLocation,
  );
  _deliveryInfo = updatedDelivery;
  notifyListeners();
  return true;
}
```

### UI Components

#### DriverLocationTracker Widget

A dedicated widget for displaying live driver location:

```dart
import 'package:restaurant_store_flutter/src/presentation/widgets/driver_location_tracker.dart';

DriverLocationTracker(
  delivery: deliveryInfo,
  deliveryAddress: order.deliveryAddress, // Optional: shows destination
)
```

Features:
- Live status indicator
- Current location display (from driver)
- GPS coordinates (precise lat/lng)
- Delivery destination address (from checkout)
- Smart "View Route on Map" button (shows directions when destination available)

#### Order Tracking Screen

The order tracking screen automatically displays driver location when available:

```dart
if (delivery != null && delivery.latitude != null && delivery.longitude != null) {
  DriverLocationTracker(
    delivery: delivery,
    deliveryAddress: order.deliveryAddress, // Passed from checkout
  ),
}
```

**Integration with Checkout Flow:**
- When customers place an order, they provide a delivery address
- This address is stored in `Order.deliveryAddress`
- The driver location widget displays both driver location AND destination
- The "View Route on Map" button shows directions from driver to destination
- Customers can see how far the driver is from their location

## Usage Example

### For Drivers (Backend/Driver App)

```dart
final orderProvider = context.read<OrderProvider>();
await orderProvider.updateDriverLocation(
  deliveryId: 123,
  latitude: 11.5564,
  longitude: 104.9282,
  currentLocation: 'Near Central Market, approaching delivery address',
);
```

### For Customers (Flutter App)

1. Navigate to order tracking screen
2. View real-time driver location in the "Live Location Tracking" card
3. Tap "View on Map" to open location in Google Maps
4. Location updates automatically via WebSocket

## Testing

### Manual Testing

1. Create a test delivery order
2. Use the driver location update endpoint with test coordinates:
   ```bash
   curl -X PUT http://localhost:8080/api/deliveries/123/driver-location \
     -H "Authorization: Bearer YOUR_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{
       "latitude": 11.5564,
       "longitude": 104.9282,
       "currentLocation": "Test Location"
     }'
   ```
3. Check that the customer app receives the update via WebSocket
4. Verify the location is displayed in the tracking UI

### Coordinates for Testing (Phnom Penh)

- Central Market: `11.5686, 104.9260`
- Royal Palace: `11.5564, 104.9282`
- Riverside: `11.5724, 104.9200`
- BKK1 Area: `11.5449, 104.9308`

## Security Considerations

- Location updates require authentication (Bearer token)
- Only authorized drivers can update delivery locations
- Location data is transmitted over secure WebSocket connections
- GPS coordinates are validated on the backend

## Performance

- Location updates are lightweight (< 1KB payload)
- WebSocket connections are persistent and efficient
- Updates are broadcast to subscribed clients only
- No polling required - real-time push notifications

## Future Enhancements

- **Map Integration**: Full interactive map showing driver route
- **ETA Calculation**: Automatic ETA updates based on location
- **Route History**: Track complete delivery route
- **Geofencing**: Automatic status updates when entering zones
- **Push Notifications**: Alert customers when driver is nearby

## Troubleshooting

### Location Not Updating

1. Check WebSocket connection status
2. Verify delivery ID is correct
3. Ensure driver has location permissions
4. Check network connectivity

### Coordinates Not Displaying

1. Verify `latitude` and `longitude` fields are not null
2. Check that values are valid GPS coordinates
3. Ensure data is properly deserialized from JSON

## Related Files

- `/lib/src/data/models/order.dart` - DeliveryInfo model
- `/lib/src/data/services/api_service.dart` - API methods
- `/lib/src/features/orders/providers/order_provider.dart` - State management
- `/lib/src/presentation/widgets/driver_location_tracker.dart` - UI widget
- `/lib/src/presentation/screens/order_tracking_screen.dart` - Tracking screen
- `/api.json` - OpenAPI specification

## References

- [WebSocket Integration Documentation](WEBSOCKET_INTEGRATION.md)
- [API Documentation](../api.json)
- [STOMP Protocol](https://stomp.github.io/)
