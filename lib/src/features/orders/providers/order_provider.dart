import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:restaurant_store_flutter/src/core/constants/app_constants.dart';
import 'package:restaurant_store_flutter/src/core/exceptions/app_exception.dart';
import 'package:restaurant_store_flutter/src/data/models/cart.dart';
import 'package:restaurant_store_flutter/src/data/models/order.dart';
import 'package:restaurant_store_flutter/src/data/services/api_service.dart';
import 'package:restaurant_store_flutter/src/data/services/order_tracking_service.dart';
import 'package:restaurant_store_flutter/src/data/services/storage_service.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  Order? _selectedOrder;
  DeliveryInfo? _deliveryInfo;
  bool _isLoading = false;
  bool _isLoadingOrders = false;
  bool _isCreatingOrder = false;
  bool _isCancellingOrder = false;
  String? _errorMessage;
  OrderStatus? _statusFilter;
  final OrderTrackingService _trackingService = OrderTrackingService();
  int? _trackedOrderId;
  bool _isTrackingOrder = false;
  String? _trackingError;

  List<Order> get orders => _orders;
  Order? get selectedOrder => _selectedOrder;
  DeliveryInfo? get deliveryInfo => _deliveryInfo;
  bool get isLoading => _isLoading;
  bool get isLoadingOrders => _isLoadingOrders;
  bool get isCreatingOrder => _isCreatingOrder;
  bool get isCancellingOrder => _isCancellingOrder;
  String? get errorMessage => _errorMessage;
  OrderStatus? get statusFilter => _statusFilter;
  bool get isTrackingOrder => _isTrackingOrder;
  String? get trackingError => _trackingError;
  int? get trackedOrderId => _trackedOrderId;

  List<Order> get activeOrders => _orders.where((order) => order.isActive).toList();
  List<Order> get completedOrders => _orders.where((order) => !order.isActive).toList();
  List<Order> get pendingOrders =>
      _orders.where((order) => order.status == OrderStatus.pending || order.status == OrderStatus.confirmed).toList();
  List<Order> get inProgressOrders => _orders
      .where((order) =>
          order.status == OrderStatus.preparing ||
          order.status == OrderStatus.ready ||
          order.status == OrderStatus.outForDelivery)
      .toList();

  OrderProvider() {
    _initializeData();
  }

  @override
  void dispose() {
    _trackingService.close();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await loadOrders();
  }

  Future<void> loadOrders({OrderStatus? status}) async {
    _isLoadingOrders = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedOrders = await ApiService.getOrders(status: status ?? _statusFilter);
      _orders = fetchedOrders;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e, stackTrace) {
      debugPrint('Failed to load orders: $e');
      FlutterError.reportError(FlutterErrorDetails(exception: e, stack: stackTrace));
      _errorMessage = AppConstants.generalError;
    } finally {
      _isLoadingOrders = false;
      notifyListeners();
    }
  }

  Future<void> loadOrderDetails(int orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedOrder = await ApiService.getOrderDetails(orderId);
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e, stackTrace) {
      debugPrint('Failed to load order details: $e');
      FlutterError.reportError(FlutterErrorDetails(exception: e, stack: stackTrace));
      _errorMessage = AppConstants.generalError;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Order?> createOrder({
    required List<CartItem> items,
    String orderType = 'DELIVERY',
    String? deliveryAddress,
    String? phoneNumber,
    String? specialInstructions,
  }) async {
    _isCreatingOrder = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final orderItems = items
          .map((cartItem) => CreateOrderItemRequest(
                productId: cartItem.productId,
                quantity: cartItem.quantity,
              ))
          .toList();

      final request = CreateOrderRequest(
        orderItems: orderItems,
        orderType: orderType,
        deliveryAddress: deliveryAddress,
        phoneNumber: phoneNumber,
        specialInstructions: specialInstructions,
      );

      final order = await ApiService.createOrder(request);
      _orders.insert(0, order);
      _selectedOrder = order;
      startOrderTracking(order.id);
      return order;
    } on AppException catch (e) {
      _errorMessage = e.message;
      return null;
    } catch (e, stackTrace) {
      debugPrint('Failed to create order: $e');
      FlutterError.reportError(FlutterErrorDetails(exception: e, stack: stackTrace));
      _errorMessage = AppConstants.generalError;
      return null;
    } finally {
      _isCreatingOrder = false;
      notifyListeners();
    }
  }

  Future<bool> cancelOrder(int orderId, {String? reason}) async {
    _isCancellingOrder = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ApiService.cancelOrder(orderId, reason: reason);
      final refreshedOrder = await ApiService.getOrderDetails(orderId);
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _orders[index] = refreshedOrder;
      } else {
        _orders.insert(0, refreshedOrder);
      }
      if (_selectedOrder?.id == orderId) {
        _selectedOrder = refreshedOrder;
      }
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e, stackTrace) {
      debugPrint('Failed to cancel order: $e');
      FlutterError.reportError(FlutterErrorDetails(exception: e, stack: stackTrace));
      _errorMessage = AppConstants.generalError;
      return false;
    } finally {
      _isCancellingOrder = false;
      notifyListeners();
    }
  }

  Future<void> loadDeliveryInfo(int orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _deliveryInfo = await ApiService.getDeliveryInfo(orderId);
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e, stackTrace) {
      debugPrint('Failed to load delivery info: $e');
      FlutterError.reportError(FlutterErrorDetails(exception: e, stack: stackTrace));
      _errorMessage = AppConstants.generalError;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateDeliveryLocation(int deliveryId, String location) async {
    try {
      await ApiService.updateDeliveryLocation(deliveryId, location);
      final orderId = _deliveryInfo?.orderId ?? _selectedOrder?.id;
      if (orderId != null) {
        await loadDeliveryInfo(orderId);
      }
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e, stackTrace) {
      debugPrint('Failed to update delivery location: $e');
      FlutterError.reportError(FlutterErrorDetails(exception: e, stack: stackTrace));
      _errorMessage = AppConstants.generalError;
      return false;
    }
  }

  Future<bool> updateDeliveryStatus(int deliveryId, String status) async {
    try {
      await ApiService.updateDeliveryStatus(deliveryId, status);
      final orderId = _deliveryInfo?.orderId ?? _selectedOrder?.id;
      if (orderId != null) {
        await loadDeliveryInfo(orderId);
      }
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e, stackTrace) {
      debugPrint('Failed to update delivery status: $e');
      FlutterError.reportError(FlutterErrorDetails(exception: e, stack: stackTrace));
      _errorMessage = AppConstants.generalError;
      return false;
    }
  }

  Future<void> filterByStatus(OrderStatus? status) async {
    _statusFilter = status;
    await loadOrders(status: status);
  }

  void clearSelection() {
    _selectedOrder = null;
    _deliveryInfo = null;
    stopOrderTracking(notifyListenersOnStop: false);
    notifyListeners();
  }

  void clearOrders() {
    stopOrderTracking(notifyListenersOnStop: false);
    _orders = [];
    _selectedOrder = null;
    _deliveryInfo = null;
    notifyListeners();
  }

  void startOrderTracking(int orderId) {
    if (_trackedOrderId == orderId && _isTrackingOrder) {
      return;
    }

    stopOrderTracking(notifyListenersOnStop: false);
    _trackedOrderId = orderId;
    _isTrackingOrder = true;
    _trackingError = null;
    notifyListeners();

    final token = StorageService.getAuthToken();
    final uri = ApiService.buildOrderTrackingWebSocketUri(orderId, authToken: kIsWeb ? token : null);
    final headers = !kIsWeb && token != null ? {'Authorization': 'Bearer $token'} : null;

    try {
      _trackingService.connect(
        uri: uri,
        headers: headers,
        onEvent: (event) => _handleTrackingEvent(event, orderId),
        onError: (error, stackTrace) => _handleTrackingError(error),
        onDone: _handleTrackingClosed,
      );
    } catch (error) {
      _trackingError = 'Unable to connect to live tracking.';
      _isTrackingOrder = false;
      notifyListeners();
    }
  }

  void stopOrderTracking({bool notifyListenersOnStop = true}) {
    _trackingService.close();
    _trackedOrderId = null;
    _isTrackingOrder = false;
    _trackingError = null;
    if (notifyListenersOnStop) {
      notifyListeners();
    }
  }

  void _handleTrackingEvent(dynamic event, int orderId) {
    try {
      final payload = _decodePayload(event);
      if (payload == null) {
        return;
      }

      final orderData = _extractOrderData(payload) ?? (payload['orderId'] == orderId ? payload : null);
      if (orderData is Map<String, dynamic>) {
        final updatedOrder = Order.fromJson(orderData);
        _updateOrderCollection(updatedOrder);
      }

      final deliveryData = _extractDeliveryData(payload);
      if (deliveryData != null) {
        _deliveryInfo = DeliveryInfo.fromJson(deliveryData);
      }

      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('Failed to process tracking event: $error');
      FlutterError.reportError(FlutterErrorDetails(exception: error, stack: stackTrace));
    }
  }

  void _handleTrackingError(Object error) {
    debugPrint('Order tracking error: $error');
    _trackingError = error.toString();
    _isTrackingOrder = false;
    notifyListeners();
  }

  void _handleTrackingClosed() {
    _isTrackingOrder = false;
    notifyListeners();
  }

  Map<String, dynamic>? _decodePayload(dynamic event) {
    if (event == null) return null;
    if (event is Map<String, dynamic>) {
      return Map<String, dynamic>.from(event);
    }
    if (event is String) {
      if (event.trim().isEmpty) return null;
      final decoded = jsonDecode(event);
      if (decoded is Map<String, dynamic>) {
        return Map<String, dynamic>.from(decoded);
      }
    }
    if (event is List<int>) {
      final decodedString = utf8.decode(event);
      if (decodedString.trim().isEmpty) return null;
      final decoded = jsonDecode(decodedString);
      if (decoded is Map<String, dynamic>) {
        return Map<String, dynamic>.from(decoded);
      }
    }
    return null;
  }

  Map<String, dynamic>? _extractOrderData(Map<String, dynamic> payload) {
    final possibleOrderKeys = ['order', 'orderData'];
    for (final key in possibleOrderKeys) {
      final value = payload[key];
      if (value is Map<String, dynamic>) {
        return Map<String, dynamic>.from(value);
      }
    }

    if (payload['data'] is Map<String, dynamic>) {
      final data = Map<String, dynamic>.from(payload['data'] as Map<String, dynamic>);
      for (final key in possibleOrderKeys) {
        final value = data[key];
        if (value is Map<String, dynamic>) {
          return Map<String, dynamic>.from(value);
        }
      }
      if (_looksLikeOrder(data)) {
        return data;
      }
    }

    if (_looksLikeOrder(payload)) {
      return payload;
    }

    return null;
  }

  Map<String, dynamic>? _extractDeliveryData(Map<String, dynamic> payload) {
    final possibleDeliveryKeys = ['delivery', 'deliveryInfo'];
    for (final key in possibleDeliveryKeys) {
      final value = payload[key];
      if (value is Map<String, dynamic>) {
        return Map<String, dynamic>.from(value);
      }
    }

    if (payload['data'] is Map<String, dynamic>) {
      final data = Map<String, dynamic>.from(payload['data'] as Map<String, dynamic>);
      for (final key in possibleDeliveryKeys) {
        final value = data[key];
        if (value is Map<String, dynamic>) {
          return Map<String, dynamic>.from(value);
        }
      }
    }

    return null;
  }

  bool _looksLikeOrder(Map<String, dynamic> payload) {
    return payload.containsKey('id') &&
        (payload.containsKey('status') || payload.containsKey('orderStatus'));
  }

  void _updateOrderCollection(Order updatedOrder) {
    final index = _orders.indexWhere((order) => order.id == updatedOrder.id);
    if (index != -1) {
      _orders[index] = updatedOrder;
    } else {
      _orders.insert(0, updatedOrder);
    }
    _selectedOrder = updatedOrder;
  }
}
