# Quick Start: Driver Location Tracking

This guide helps you quickly get started with the driver location tracking feature.

## For Backend Developers

### 1. Implement the Endpoint

Add this endpoint to your Spring Boot backend:

```java
@PutMapping("/api/deliveries/{deliveryId}/driver-location")
@PreAuthorize("hasRole('DRIVER') or hasRole('ADMIN')")
public ResponseEntity<ApiResponse<DeliveryResponse>> updateDriverLocation(
    @PathVariable Long deliveryId,
    @RequestBody @Valid DriverLocationUpdateRequest request
) {
    DeliveryResponse delivery = deliveryService.updateDriverLocation(
        deliveryId,
        request.getLatitude(),
        request.getLongitude(),
        request.getCurrentLocation()
    );
    
    // Broadcast to WebSocket subscribers
    messagingTemplate.convertAndSend(
        "/topic/deliveries/" + delivery.getOrderId(),
        delivery
    );
    
    return ResponseEntity.ok(ApiResponse.success(delivery));
}
```

### 2. Request/Response DTOs

```java
@Data
@AllArgsConstructor
@NoArgsConstructor
public class DriverLocationUpdateRequest {
    @NotNull(message = "Latitude is required")
    @Min(-90) @Max(90)
    private Double latitude;
    
    @NotNull(message = "Longitude is required")
    @Min(-180) @Max(180)
    private Double longitude;
    
    private String currentLocation;
}
```

### 3. Update Delivery Entity

```java
@Entity
@Table(name = "deliveries")
public class Delivery {
    // ... existing fields ...
    
    @Column(name = "latitude")
    private Double latitude;
    
    @Column(name = "longitude")
    private Double longitude;
    
    @Column(name = "current_location")
    private String currentLocation;
    
    // ... getters and setters ...
}
```

## For Flutter Developers

### 1. Update Driver Location

```dart
// In a driver app or admin panel
final orderProvider = context.read<OrderProvider>();

await orderProvider.updateDriverLocation(
  deliveryId: delivery.id,
  latitude: currentPosition.latitude,
  longitude: currentPosition.longitude,
  currentLocation: 'Near Central Market',
);
```

### 2. Display Location in Customer App

The location is automatically displayed if coordinates are available:

```dart
// In OrderTrackingScreen
if (delivery != null && delivery.latitude != null && delivery.longitude != null) {
  DriverLocationTracker(delivery: delivery),
}
```

### 3. Listen to Real-time Updates

WebSocket updates are handled automatically by `OrderProvider`:

```dart
// Start tracking (automatically subscribes to WebSocket)
orderProvider.startOrderTracking(orderId);

// Listen to delivery updates
Consumer<OrderProvider>(
  builder: (context, provider, child) {
    final delivery = provider.deliveryInfo;
    if (delivery != null) {
      print('Driver at: ${delivery.latitude}, ${delivery.longitude}');
    }
    return YourWidget();
  },
)
```

## Testing

### 1. Quick API Test

```bash
# Update driver location
curl -X PUT http://localhost:8080/api/deliveries/1/driver-location \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "latitude": 11.5564,
    "longitude": 104.9282,
    "currentLocation": "Near Central Market"
  }'

# Get delivery info
curl -X GET http://localhost:8080/api/deliveries/1 \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### 2. Flutter Test

```dart
// test/features/orders/providers/order_provider_test.dart
test('should update driver location', () async {
  final provider = OrderProvider();
  
  final success = await provider.updateDriverLocation(
    deliveryId: 1,
    latitude: 11.5564,
    longitude: 104.9282,
    currentLocation: 'Test Location',
  );
  
  expect(success, true);
  expect(provider.deliveryInfo?.latitude, 11.5564);
  expect(provider.deliveryInfo?.longitude, 104.9282);
});
```

## Sample GPS Coordinates

Use these coordinates for testing in Phnom Penh:

```dart
// Central Market
final centralMarket = LatLng(11.5686, 104.9260);

// Royal Palace
final royalPalace = LatLng(11.5564, 104.9282);

// Riverside
final riverside = LatLng(11.5724, 104.9200);

// BKK1
final bkk1 = LatLng(11.5449, 104.9308);
```

## Simulating Real-time Updates

### Backend Simulation

Create a test endpoint or scheduled task:

```java
@Scheduled(fixedDelay = 5000) // Every 5 seconds
public void simulateDriverMovement() {
    // Get active deliveries
    List<Delivery> activeDeliveries = deliveryRepository
        .findByStatus(DeliveryStatus.ON_THE_WAY);
    
    for (Delivery delivery : activeDeliveries) {
        // Simulate movement (add small random offset)
        double newLat = delivery.getLatitude() + (Math.random() - 0.5) * 0.001;
        double newLng = delivery.getLongitude() + (Math.random() - 0.5) * 0.001;
        
        delivery.setLatitude(newLat);
        delivery.setLongitude(newLng);
        deliveryRepository.save(delivery);
        
        // Broadcast update
        messagingTemplate.convertAndSend(
            "/topic/deliveries/" + delivery.getOrderId(),
            new DeliveryResponse(delivery)
        );
    }
}
```

### Flutter Simulation

```dart
// For testing without backend
Timer.periodic(Duration(seconds: 5), (timer) {
  if (delivery.latitude != null && delivery.longitude != null) {
    final random = Random();
    orderProvider.updateDriverLocation(
      deliveryId: delivery.id,
      latitude: delivery.latitude! + (random.nextDouble() - 0.5) * 0.001,
      longitude: delivery.longitude! + (random.nextDouble() - 0.5) * 0.001,
      currentLocation: 'Moving towards destination',
    );
  }
});
```

## Common Issues

### Location Not Showing

1. Check that `latitude` and `longitude` are not null
2. Verify API response includes location fields
3. Ensure WebSocket is connected
4. Check browser/app console for errors

### WebSocket Not Receiving Updates

1. Verify WebSocket URL is correct
2. Check authentication token is valid
3. Ensure subscribing to correct topic: `/topic/deliveries/{orderId}`
4. Check backend is broadcasting updates

### Map Link Not Working

The current implementation shows a SnackBar with the Google Maps URL. To open in browser/app:

```dart
import 'package:url_launcher/url_launcher.dart';

final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
if (await canLaunchUrl(Uri.parse(url))) {
  await launchUrl(Uri.parse(url));
}
```

## Next Steps

1. **Full Map Integration**: Add Google Maps or Mapbox widget
2. **Route Display**: Show driver's route to destination
3. **ETA Calculation**: Calculate ETA based on current location
4. **Push Notifications**: Notify when driver is close
5. **Location History**: Store location trail for analysis

## Resources

- [Full Documentation](DRIVER_LOCATION_TRACKING.md)
- [Implementation Summary](../IMPLEMENTATION_SUMMARY.md)
- [OpenAPI Specification](../api.json)
- [WebSocket Integration](WEBSOCKET_INTEGRATION.md)
