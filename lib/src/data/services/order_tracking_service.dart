import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

class OrderTrackingService {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  bool get isConnected => _channel != null;

  void connect({
    required Uri uri,
    Map<String, dynamic>? headers,
    required void Function(dynamic event) onEvent,
    void Function(Object error, StackTrace stackTrace)? onError,
    void Function()? onDone,
  }) {
    close();
    try {
      final channel = WebSocketChannel.connect(uri, headers: headers);
      _channel = channel;
      _subscription = channel.stream.listen(
        onEvent,
        cancelOnError: true,
        onDone: () {
          onDone?.call();
        },
        onError: (error, stackTrace) {
          onError?.call(error, stackTrace);
        },
      );
    } catch (error, stackTrace) {
      onError?.call(error, stackTrace);
      close();
      rethrow;
    }
  }

  void close([int code = ws_status.normalClosure]) {
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close(code);
    _channel = null;
  }
}
