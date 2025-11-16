import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:restaurant_store_flutter/src/data/models/order.dart';
import 'package:restaurant_store_flutter/src/data/models/websocket_message.dart';
import 'package:restaurant_store_flutter/src/data/services/api_service.dart';
import 'package:restaurant_store_flutter/src/data/services/websocket_service.dart';

class StompTrackingService {
  final WebSocketService _webSocketService = WebSocketService();
  final StreamController<Order> _orderStreamController = StreamController<Order>.broadcast();
  final StreamController<DeliveryInfo> _deliveryStreamController = StreamController<DeliveryInfo>.broadcast();
  final StreamController<OrderStatusMessage> _notificationStreamController = StreamController<OrderStatusMessage>.broadcast();
  
  int? _currentOrderId;
  bool _isConnected = false;
  
  Stream<Order> get orderStream => _orderStreamController.stream;
  Stream<DeliveryInfo> get deliveryStream => _deliveryStreamController.stream;
  Stream<OrderStatusMessage> get notificationStream => _notificationStreamController.stream;
  
  bool get isConnected => _isConnected;
  int? get currentOrderId => _currentOrderId;

  void connectAndTrack({
    required int orderId,
    String? authToken,
    VoidCallback? onConnected,
    void Function(String error)? onError,
  }) {
    if (_currentOrderId == orderId && _isConnected) {
      debugPrint('Already tracking order $orderId');
      return;
    }

    disconnect();

    _currentOrderId = orderId;
    final wsUrl = ApiService.buildWebSocketUrl(authToken: authToken);
    
    final headers = authToken != null ? {'Authorization': 'Bearer $authToken'} : null;

    debugPrint('Connecting to WebSocket: $wsUrl');

    _webSocketService.connect(
      url: wsUrl,
      headers: headers,
      onConnect: () {
        _isConnected = true;
        debugPrint('WebSocket connected, subscribing to order $orderId topics');
        _subscribeToTopics(orderId, authToken);
        onConnected?.call();
      },
      onError: (message) {
        _isConnected = false;
        debugPrint('WebSocket error: $message');
        onError?.call(message);
      },
      onDisconnect: () {
        _isConnected = false;
        debugPrint('WebSocket disconnected');
      },
    );
  }

  void _subscribeToTopics(int orderId, String? authToken) {
    // Subscribe to order updates
    _webSocketService.subscribe(
      destination: '/topic/orders/$orderId',
      callback: (frame) {
        debugPrint('Received order update: ${frame.body}');
        _handleOrderUpdate(frame.body);
      },
    );

    // Subscribe to order status updates
    _webSocketService.subscribe(
      destination: '/topic/orders/$orderId/status',
      callback: (frame) {
        debugPrint('Received order status: ${frame.body}');
        _handleStatusMessage(frame.body);
      },
    );

    // Subscribe to order notifications
    _webSocketService.subscribe(
      destination: '/topic/orders/$orderId/notifications',
      callback: (frame) {
        debugPrint('Received order notification: ${frame.body}');
        _handleNotification(frame.body);
      },
    );

    // Subscribe to delivery updates
    _webSocketService.subscribe(
      destination: '/topic/deliveries/$orderId',
      callback: (frame) {
        debugPrint('Received delivery update: ${frame.body}');
        _handleDeliveryUpdate(frame.body);
      },
    );

    // Subscribe to delivery location updates
    _webSocketService.subscribe(
      destination: '/topic/deliveries/$orderId/location',
      callback: (frame) {
        debugPrint('Received location update: ${frame.body}');
        _handleLocationUpdate(frame.body);
      },
    );

    // Subscribe to delivery notifications
    _webSocketService.subscribe(
      destination: '/topic/deliveries/$orderId/notifications',
      callback: (frame) {
        debugPrint('Received delivery notification: ${frame.body}');
        _handleNotification(frame.body);
      },
    );

    // Send subscription confirmation for orders
    _webSocketService.send(
      destination: '/app/orders/$orderId/subscribe',
      body: jsonEncode({}),
    );

    // Send subscription confirmation for deliveries
    _webSocketService.send(
      destination: '/app/deliveries/$orderId/subscribe',
      body: jsonEncode({}),
    );
  }

  void _handleOrderUpdate(String? body) {
    if (body == null || body.isEmpty) return;

    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final order = Order.fromJson(json);
      _orderStreamController.add(order);
    } catch (e, stackTrace) {
      debugPrint('Error parsing order update: $e');
      FlutterError.reportError(FlutterErrorDetails(exception: e, stack: stackTrace));
    }
  }

  void _handleDeliveryUpdate(String? body) {
    if (body == null || body.isEmpty) return;

    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final delivery = DeliveryInfo.fromJson(json);
      _deliveryStreamController.add(delivery);
    } catch (e, stackTrace) {
      debugPrint('Error parsing delivery update: $e');
      FlutterError.reportError(FlutterErrorDetails(exception: e, stack: stackTrace));
    }
  }

  void _handleStatusMessage(String? body) {
    if (body == null || body.isEmpty) return;

    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final message = OrderStatusMessage.fromJson(json);
      _notificationStreamController.add(message);
    } catch (e, stackTrace) {
      debugPrint('Error parsing status message: $e');
      FlutterError.reportError(FlutterErrorDetails(exception: e, stack: stackTrace));
    }
  }

  void _handleLocationUpdate(String? body) {
    if (body == null || body.isEmpty) return;

    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      
      // Location updates might come as OrderStatusMessage or DeliveryInfo
      if (json.containsKey('orderId') && json.containsKey('eventType')) {
        // It's an OrderStatusMessage
        final message = OrderStatusMessage.fromJson(json);
        _notificationStreamController.add(message);
      } else if (json.containsKey('id') && json.containsKey('location')) {
        // It's a DeliveryInfo
        final delivery = DeliveryInfo.fromJson(json);
        _deliveryStreamController.add(delivery);
      }
    } catch (e, stackTrace) {
      debugPrint('Error parsing location update: $e');
      FlutterError.reportError(FlutterErrorDetails(exception: e, stack: stackTrace));
    }
  }

  void _handleNotification(String? body) {
    if (body == null || body.isEmpty) return;

    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final message = OrderStatusMessage.fromJson(json);
      _notificationStreamController.add(message);
    } catch (e, stackTrace) {
      debugPrint('Error parsing notification: $e');
      FlutterError.reportError(FlutterErrorDetails(exception: e, stack: stackTrace));
    }
  }

  void disconnect() {
    _webSocketService.disconnect();
    _currentOrderId = null;
    _isConnected = false;
  }

  void dispose() {
    disconnect();
    _orderStreamController.close();
    _deliveryStreamController.close();
    _notificationStreamController.close();
  }
}
