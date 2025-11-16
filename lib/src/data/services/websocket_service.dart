import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class WebSocketService {
  StompClient? _stompClient;
  final List<StompUnsubscribe> _subscriptions = [];
  bool _isConnected = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  Timer? _reconnectTimer;

  bool get isConnected => _isConnected;

  void connect({
    required String url,
    Map<String, String>? headers,
    VoidCallback? onConnect,
    void Function(String message)? onError,
    VoidCallback? onDisconnect,
  }) {
    if (_stompClient != null && _isConnected) {
      debugPrint('WebSocket already connected');
      return;
    }

    _stompClient = StompClient(
      config: StompConfig(
        url: url,
        onConnect: (StompFrame frame) {
          debugPrint('WebSocket connected: ${frame.command}');
          _isConnected = true;
          _reconnectAttempts = 0;
          _reconnectTimer?.cancel();
          onConnect?.call();
        },
        onWebSocketError: (dynamic error) {
          debugPrint('WebSocket error: $error');
          _isConnected = false;
          onError?.call(error.toString());
          _attemptReconnect(url, headers, onConnect, onError, onDisconnect);
        },
        onStompError: (StompFrame frame) {
          debugPrint('STOMP error: ${frame.body}');
          _isConnected = false;
          onError?.call(frame.body ?? 'Unknown STOMP error');
        },
        onDisconnect: (StompFrame frame) {
          debugPrint('WebSocket disconnected');
          _isConnected = false;
          _clearSubscriptions();
          onDisconnect?.call();
        },
        stompConnectHeaders: headers,
        webSocketConnectHeaders: headers,
      ),
    );

    _stompClient?.activate();
  }

  void _attemptReconnect(
    String url,
    Map<String, String>? headers,
    VoidCallback? onConnect,
    void Function(String message)? onError,
    VoidCallback? onDisconnect,
  ) {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('Max reconnection attempts reached');
      onError?.call('Unable to connect to real-time tracking. Please refresh.');
      return;
    }

    _reconnectAttempts++;
    final delay = Duration(
      milliseconds: (1000 * (1 << _reconnectAttempts)).clamp(0, 30000),
    );

    debugPrint('Attempting to reconnect in ${delay.inMilliseconds}ms (attempt $_reconnectAttempts)');

    _reconnectTimer = Timer(delay, () {
      connect(
        url: url,
        headers: headers,
        onConnect: onConnect,
        onError: onError,
        onDisconnect: onDisconnect,
      );
    });
  }

  void subscribe({
    required String destination,
    required void Function(StompFrame frame) callback,
    Map<String, String>? headers,
  }) {
    if (_stompClient == null || !_isConnected) {
      debugPrint('Cannot subscribe: not connected to WebSocket');
      return;
    }

    final unsubscribe = _stompClient!.subscribe(
      destination: destination,
      callback: callback,
      headers: headers,
    );

    _subscriptions.add(unsubscribe);
    debugPrint('Subscribed to: $destination');
  }

  void send({
    required String destination,
    String? body,
    Map<String, String>? headers,
  }) {
    if (_stompClient == null || !_isConnected) {
      debugPrint('Cannot send: not connected to WebSocket');
      return;
    }

    _stompClient!.send(
      destination: destination,
      body: body,
      headers: headers,
    );
    debugPrint('Sent message to: $destination');
  }

  void _clearSubscriptions() {
    for (final unsubscribe in _subscriptions) {
      unsubscribe();
    }
    _subscriptions.clear();
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _clearSubscriptions();
    _stompClient?.deactivate();
    _stompClient = null;
    _isConnected = false;
    _reconnectAttempts = 0;
    debugPrint('WebSocket disconnected');
  }
}
