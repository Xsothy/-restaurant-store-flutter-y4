# WebSocket Integration Update Instructions

## Overview

This update implements proper WebSocket support using STOMP over SockJS to match the backend architecture. The previous implementation attempted to connect directly to REST endpoints as WebSocket connections, which caused errors.

## Changes Made

### 1. Dependencies Added

**File:** `pubspec.yaml`

Added `stomp_dart_client: ^2.0.0` for STOMP protocol support.

**Action Required:**
```bash
flutter pub get
```

### 2. New Services Created

#### WebSocketService
**File:** `lib/src/data/services/websocket_service.dart`

Low-level WebSocket service that manages STOMP client connections with:
- Automatic reconnection (exponential backoff)
- Connection state management
- Subscription management
- Error handling

#### StompTrackingService
**File:** `lib/src/data/services/stomp_tracking_service.dart`

High-level service providing type-safe streams for:
- Order updates (`Stream<Order>`)
- Delivery updates (`Stream<DeliveryInfo>`)
- Notifications (`Stream<OrderStatusMessage>`)

Automatically subscribes to all relevant topics:
- `/topic/orders/{orderId}`
- `/topic/orders/{orderId}/status`
- `/topic/orders/{orderId}/notifications`
- `/topic/deliveries/{orderId}`
- `/topic/deliveries/{orderId}/location`
- `/topic/deliveries/{orderId}/notifications`

### 3. New Models

**File:** `lib/src/data/models/websocket_message.dart`

Added models for WebSocket messages:
- `OrderStatusMessage` - Status updates and notifications
- `WebSocketInfo` - WebSocket configuration info
- `WebSocketTopic` - Topic information

### 4. Updated Services

#### ApiService
**File:** `lib/src/data/services/api_service.dart`

- Added `buildWebSocketUrl()` method - Builds correct WebSocket URL (`ws://host/ws`)
- Deprecated `buildOrderTrackingWebSocketUri()` - Old method connecting to wrong endpoint
- Added `getWebSocketInfo()` - Fetches WebSocket configuration from backend

### 5. Updated Providers

#### OrderProvider
**File:** `lib/src/features/orders/providers/order_provider.dart`

- Integrated `StompTrackingService` for real-time tracking
- Updated `startOrderTracking()` to use STOMP
- Added proper stream subscriptions for order/delivery updates
- Enhanced error handling and reconnection logic

### 6. Documentation

Created comprehensive documentation:

#### WEBSOCKET_INTEGRATION.md
**File:** `docs/WEBSOCKET_INTEGRATION.md`

Complete guide covering:
- Architecture overview
- Service usage examples
- Model descriptions
- Common mistakes and troubleshooting
- Migration guide
- Testing instructions

## Backend Compatibility

This implementation matches the backend WebSocket architecture documented in:
- Backend WebSocket endpoint: `ws://localhost:8080/ws`
- Protocol: STOMP over SockJS
- Authentication: Bearer token in headers

## Key Differences from Old Implementation

### Old Implementation (Deprecated)
```dart
// ❌ Trying to connect to REST endpoint as WebSocket
final uri = ApiService.buildOrderTrackingWebSocketUri(orderId);
// ws://localhost:8080/api/deliveries/track/506
```

**Problem:** This connects to a REST endpoint, not a WebSocket endpoint, causing:
```
WebSocketChannelException: connection was not upgraded to websocket
```

### New Implementation (Correct)
```dart
// ✅ Connect to proper WebSocket endpoint
final wsUrl = ApiService.buildWebSocketUrl();
// ws://localhost:8080/ws

// Then subscribe to STOMP topics
wsService.subscribe(destination: '/topic/deliveries/{orderId}', ...);
```

## Testing Steps

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run the App
```bash
flutter run
```

### 3. Test Order Tracking

1. Create a new order
2. Navigate to order details
3. Verify WebSocket connection in console:
   ```
   WebSocket connected
   Subscribed to: /topic/orders/123
   Subscribed to: /topic/deliveries/123
   ```

4. Trigger status update from backend
5. Verify real-time update appears in app

### 4. Test Error Handling

1. Stop backend server
2. Create/view order
3. Verify graceful error handling
4. Restart backend
5. Verify automatic reconnection

## Backwards Compatibility

The old `OrderTrackingService` is still available but deprecated. The `OrderProvider` now uses the new `StompTrackingService` by default while maintaining the same public API, so existing UI code should work without changes.

## Migration Checklist

- [x] Add STOMP client dependency
- [x] Create WebSocket service layer
- [x] Create tracking service with streams
- [x] Add WebSocket message models
- [x] Update API service with new WebSocket URL builder
- [x] Integrate STOMP tracking into OrderProvider
- [x] Add comprehensive documentation
- [ ] Run `flutter pub get` to install dependencies
- [ ] Test order creation and tracking
- [ ] Test real-time updates
- [ ] Test error handling and reconnection
- [ ] Verify delivery tracking works
- [ ] Test with production backend (wss://)

## Environment Configuration

### Development
```env
API_BASE_URL=http://localhost:8080
# WebSocket URL: ws://localhost:8080/ws
```

### Production
```env
API_BASE_URL=https://api.restaurant-store.com
# WebSocket URL: wss://api.restaurant-store.com/ws
```

The WebSocket URL is automatically derived from the API base URL:
- `http://` → `ws://`
- `https://` → `wss://`

## Troubleshooting

### "Connection was not upgraded to websocket"

This error occurred with the old implementation. The new implementation fixes this by:
1. Connecting to `/ws` instead of `/api/deliveries/track/{orderId}`
2. Using STOMP protocol instead of raw WebSocket
3. Subscribing to proper topics after connection

### No real-time updates

1. Check console for connection messages
2. Verify backend WebSocket endpoint is running
3. Check authentication token is valid
4. Trigger a status change from backend
5. Check network/CORS configuration

### Connection keeps dropping

1. Check network stability
2. Verify backend WebSocket configuration
3. Review reconnection attempts in logs
4. Consider increasing max reconnection attempts

## Additional Resources

- Backend WebSocket Documentation: Review backend docs for server configuration
- STOMP Protocol: https://stomp.github.io/
- `stomp_dart_client` Package: https://pub.dev/packages/stomp_dart_client
- Flutter WebSocket Guide: https://flutter.dev/docs/cookbook/networking/web-sockets

## Support

For questions or issues:
1. Check `docs/WEBSOCKET_INTEGRATION.md` for detailed integration guide
2. Review backend `/api/websocket/info` endpoint for current configuration
3. Check console logs for connection and subscription messages
4. Verify authentication and network connectivity

## Next Steps

1. **Install dependencies:** Run `flutter pub get`
2. **Test locally:** Create orders and verify real-time tracking works
3. **Review documentation:** Read `docs/WEBSOCKET_INTEGRATION.md`
4. **Update UI:** Consider adding connection status indicators
5. **Production testing:** Test with production backend using WSS

## Breaking Changes

None - The public API of `OrderProvider` remains unchanged. The implementation details have been updated to use STOMP, but existing code using the provider should work without modifications.

## Notes

- The old `OrderTrackingService` using direct WebSocket connection is deprecated but not removed for backwards compatibility
- All new code should use `StompTrackingService` or `OrderProvider`
- REST API endpoints remain available as fallback for polling
- WebSocket connection is optional - app works without it using REST polling
