# WebSocket Integration Guide

This document explains how to use WebSocket connections in the Flutter app for real-time order and delivery tracking.

## Overview

The backend provides real-time updates through WebSocket connections using STOMP (Simple Text Oriented Messaging Protocol) over SockJS. The Flutter app uses the `stomp_dart_client` package to connect and subscribe to real-time updates.

## Architecture

### Backend WebSocket Endpoints

- **WebSocket Endpoint:** `ws://localhost:8080/ws` (or `wss://` for HTTPS)
- **Protocol:** STOMP over SockJS
- **Authentication:** Bearer token in headers

### Available Topics

#### Order Tracking Topics
- `/topic/orders/{orderId}` - Full order updates (OrderResponse)
- `/topic/orders/{orderId}/status` - Status change messages (OrderStatusMessage)
- `/topic/orders/{orderId}/notifications` - Order notifications (OrderStatusMessage)

#### Delivery Tracking Topics
- `/topic/deliveries/{orderId}` - Full delivery updates (DeliveryResponse)
- `/topic/deliveries/{orderId}/status` - Status change messages (OrderStatusMessage)
- `/topic/deliveries/{orderId}/location` - Real-time location updates (OrderStatusMessage)
- `/topic/deliveries/{orderId}/notifications` - Delivery notifications (OrderStatusMessage)

#### Subscription Confirmation Endpoints
- `/app/orders/{orderId}/subscribe` - Send to confirm order subscription
- `/app/deliveries/{orderId}/subscribe` - Send to confirm delivery subscription

## Flutter Implementation

### Services

#### 1. WebSocketService (`lib/src/data/services/websocket_service.dart`)

Low-level WebSocket service that manages the STOMP client connection:

```dart
final wsService = WebSocketService();

wsService.connect(
  url: 'ws://localhost:8080/ws',
  headers: {'Authorization': 'Bearer $token'},
  onConnect: () => print('Connected'),
  onError: (error) => print('Error: $error'),
  onDisconnect: () => print('Disconnected'),
);

wsService.subscribe(
  destination: '/topic/orders/123',
  callback: (frame) {
    print('Received: ${frame.body}');
  },
);

wsService.send(
  destination: '/app/orders/123/subscribe',
  body: jsonEncode({}),
);

wsService.disconnect();
```

Features:
- Automatic reconnection with exponential backoff
- Max 5 reconnection attempts
- Proper error handling
- Clean subscription management

#### 2. StompTrackingService (`lib/src/data/services/stomp_tracking_service.dart`)

High-level tracking service that provides streams for order and delivery updates:

```dart
final trackingService = StompTrackingService();

// Subscribe to streams
trackingService.orderStream.listen((order) {
  print('Order updated: ${order.id}');
});

trackingService.deliveryStream.listen((delivery) {
  print('Delivery updated: ${delivery.location}');
});

trackingService.notificationStream.listen((notification) {
  print('Notification: ${notification.title}');
});

// Connect and start tracking
trackingService.connectAndTrack(
  orderId: 123,
  authToken: 'your-token',
  onConnected: () => print('Tracking started'),
  onError: (error) => print('Error: $error'),
);

// Disconnect
trackingService.disconnect();
```

Features:
- Automatic subscription to all relevant topics
- Type-safe streams for different message types
- Handles both order and delivery updates
- Sends subscription confirmations automatically

### Models

#### OrderStatusMessage (`lib/src/data/models/websocket_message.dart`)

Represents status updates and notifications:

```dart
class OrderStatusMessage {
  final int? orderId;
  final String? eventType;  // e.g., "STATUS_CHANGED"
  final String? status;     // e.g., "OUT_FOR_DELIVERY"
  final String? title;      // e.g., "Order Out for Delivery"
  final String? message;    // e.g., "Your order is on its way!"
  final DateTime? timestamp;
}
```

### Provider Integration

#### OrderProvider (`lib/src/features/orders/providers/order_provider.dart`)

The OrderProvider automatically manages WebSocket connections for order tracking:

```dart
// Start tracking an order
orderProvider.startOrderTracking(orderId);

// Check tracking status
if (orderProvider.isTrackingOrder) {
  print('Currently tracking order: ${orderProvider.trackedOrderId}');
}

// Stop tracking
orderProvider.stopOrderTracking();
```

Features:
- Automatically connects to WebSocket when tracking starts
- Updates order and delivery info in real-time
- Handles reconnection on errors
- Cleans up connections properly
- Provides tracking status and error messages

## Usage Examples

### Example 1: Track Order After Creation

```dart
final order = await orderProvider.createOrder(
  items: cartItems,
  orderType: 'DELIVERY',
  deliveryAddress: '123 Main St',
);

if (order != null) {
  // Tracking is automatically started in createOrder
  // Listen for updates through the provider
  print('Order created: ${order.id}');
  print('Tracking: ${orderProvider.isTrackingOrder}');
}
```

### Example 2: Track Existing Order

```dart
// Load order details
await orderProvider.loadOrderDetails(orderId);

// Start tracking
orderProvider.startOrderTracking(orderId);

// The provider will automatically update when messages arrive
// UI will be notified via notifyListeners()
```

### Example 3: Handle Tracking Errors

```dart
orderProvider.startOrderTracking(orderId);

// Check for errors
if (orderProvider.trackingError != null) {
  showSnackBar('Tracking error: ${orderProvider.trackingError}');
  
  // Fall back to polling if WebSocket fails
  Timer.periodic(Duration(seconds: 10), (timer) async {
    if (!orderProvider.isTrackingOrder) {
      await orderProvider.loadOrderDetails(orderId);
    } else {
      timer.cancel();
    }
  });
}
```

### Example 4: Direct Use of StompTrackingService

If you need more control, you can use StompTrackingService directly:

```dart
final trackingService = StompTrackingService();
final token = StorageService.getAuthToken();

// Subscribe to streams
final orderSubscription = trackingService.orderStream.listen((order) {
  print('Order ${order.id}: ${order.status}');
  // Update UI
});

final deliverySubscription = trackingService.deliveryStream.listen((delivery) {
  print('Delivery at: ${delivery.location}');
  // Update map
});

final notificationSubscription = trackingService.notificationStream.listen((notification) {
  print('${notification.title}: ${notification.message}');
  // Show notification
});

// Connect
trackingService.connectAndTrack(
  orderId: orderId,
  authToken: token,
  onConnected: () {
    print('Connected successfully');
  },
  onError: (error) {
    print('Connection error: $error');
  },
);

// Clean up when done
orderSubscription.cancel();
deliverySubscription.cancel();
notificationSubscription.cancel();
trackingService.dispose();
```

## Important Notes

### ⚠️ Common Mistakes

1. **DO NOT connect to REST endpoints as WebSocket:**
   ```dart
   // ❌ WRONG - This is a REST endpoint
   final socket = WebSocketChannel.connect(
     Uri.parse('ws://localhost:8080/api/deliveries/track/506')
   );
   
   // ✅ CORRECT - Connect to /ws and subscribe to topic
   final wsService = WebSocketService();
   wsService.connect(url: 'ws://localhost:8080/ws');
   wsService.subscribe(destination: '/topic/deliveries/506', ...);
   ```

2. **Always clean up connections:**
   ```dart
   @override
   void dispose() {
     orderProvider.stopOrderTracking();
     super.dispose();
   }
   ```

3. **Handle connection failures gracefully:**
   - Implement fallback to REST API polling
   - Show appropriate error messages to users
   - Don't retry indefinitely

### REST vs WebSocket

| Feature | REST Polling | WebSocket Real-time |
|---------|-------------|---------------------|
| Order Status | `GET /api/orders/{id}` | `/topic/orders/{orderId}` |
| Delivery Info | `GET /api/deliveries/{orderId}` | `/topic/deliveries/{orderId}` |
| Updates | Manual refresh | Automatic push |
| Connection | Stateless | Persistent |
| Bandwidth | Higher | Lower |
| Latency | Higher | Lower |

Use REST endpoints as fallback when WebSocket connection fails.

## Configuration

### Environment Variables

Add WebSocket URL to `.env`:

```properties
API_BASE_URL=http://localhost:8080
# WebSocket URL is automatically derived from API_BASE_URL
# http:// -> ws://
# https:// -> wss://
```

### Build WebSocket URL

The `ApiService.buildWebSocketUrl()` method automatically converts the HTTP base URL to WebSocket URL:

```dart
// If API_BASE_URL is http://localhost:8080
// WebSocket URL will be ws://localhost:8080/ws

// If API_BASE_URL is https://api.example.com
// WebSocket URL will be wss://api.example.com/ws
```

## Testing

### Test WebSocket Connection

```dart
// Test connection
final wsService = WebSocketService();
wsService.connect(
  url: ApiService.buildWebSocketUrl(),
  onConnect: () => print('✅ Connected'),
  onError: (error) => print('❌ Error: $error'),
);

// Test subscription
wsService.subscribe(
  destination: '/topic/orders/1',
  callback: (frame) => print('📨 Received: ${frame.body}'),
);

// Send test subscription
wsService.send(
  destination: '/app/orders/1/subscribe',
  body: jsonEncode({}),
);
```

### Trigger Backend Updates

To test real-time updates, trigger status changes from the backend or admin panel.

## Troubleshooting

### Connection Fails

1. Check if backend is running
2. Verify WebSocket endpoint is accessible: `ws://localhost:8080/ws`
3. Check network configuration and CORS settings
4. Verify authentication token is valid

### No Messages Received

1. Verify subscription to correct topic: `/topic/orders/{orderId}`
2. Check if orderId is correct
3. Trigger a status update on the backend
4. Check console logs for errors

### Messages Not Parsed

1. Check message format matches expected models
2. Verify JSON parsing in service
3. Check for null values in required fields
4. Review console logs for parsing errors

## Migration from Old WebSocket Implementation

If you were using the old `OrderTrackingService` (direct WebSocket connection):

### Before (Old Implementation)
```dart
final trackingService = OrderTrackingService();
final uri = ApiService.buildOrderTrackingWebSocketUri(orderId);
trackingService.connect(uri: uri, onEvent: (event) { ... });
```

### After (New Implementation)
```dart
// Option 1: Use OrderProvider (recommended)
orderProvider.startOrderTracking(orderId);

// Option 2: Use StompTrackingService directly
final trackingService = StompTrackingService();
trackingService.connectAndTrack(orderId: orderId, authToken: token);
trackingService.orderStream.listen((order) { ... });
```

## Additional Resources

- Backend Documentation: `/docs/WEBSOCKET_DOCUMENTATION.md`
- API Specification: `/api.json`
- WebSocket Info Endpoint: `GET /api/websocket/info`
- STOMP Protocol: https://stomp.github.io/
- stomp_dart_client: https://pub.dev/packages/stomp_dart_client

## Support

For issues or questions:
1. Check backend `/api/websocket/info` endpoint for current configuration
2. Review browser/app console for error messages
3. Verify backend is running and accessible
4. Check authentication token validity
