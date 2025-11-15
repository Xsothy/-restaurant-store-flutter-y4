import 'package:flutter/foundation.dart';

import '../models/cart.dart';
import '../models/order.dart';
import '../services/api_service.dart';

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
      _isLoadingOrders = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
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
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createOrder({
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

      _isCreatingOrder = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isCreatingOrder = false;
      notifyListeners();
      return false;
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

      _isCancellingOrder = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isCancellingOrder = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadDeliveryInfo(int orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _deliveryInfo = await ApiService.getDeliveryInfo(orderId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
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
    } catch (e) {
      _errorMessage = e.toString();
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
    } catch (e) {
      _errorMessage = e.toString();
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
