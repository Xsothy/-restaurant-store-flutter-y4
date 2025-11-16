import 'package:flutter/foundation.dart';

import 'package:restaurant_store_flutter/src/core/constants/app_constants.dart';
import 'package:restaurant_store_flutter/src/core/exceptions/app_exception.dart';
import 'package:restaurant_store_flutter/src/data/models/cart.dart';
import 'package:restaurant_store_flutter/src/data/models/order.dart';
import 'package:restaurant_store_flutter/src/data/services/api_service.dart';

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

  List<Order> get orders => _orders;
  Order? get selectedOrder => _selectedOrder;
  DeliveryInfo? get deliveryInfo => _deliveryInfo;
  bool get isLoading => _isLoading;
  bool get isLoadingOrders => _isLoadingOrders;
  bool get isCreatingOrder => _isCreatingOrder;
  bool get isCancellingOrder => _isCancellingOrder;
  String? get errorMessage => _errorMessage;
  OrderStatus? get statusFilter => _statusFilter;

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
    notifyListeners();
  }

  void clearOrders() {
    _orders = [];
    _selectedOrder = null;
    _deliveryInfo = null;
    notifyListeners();
  }
}
