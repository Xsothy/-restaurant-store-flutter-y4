import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/cart.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../constants/app_constants.dart';

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
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMoreOrders = true;

  // Getters
  List<Order> get orders => _orders;
  Order? get selectedOrder => _selectedOrder;
  DeliveryInfo? get deliveryInfo => _deliveryInfo;
  bool get isLoading => _isLoading;
  bool get isLoadingOrders => _isLoadingOrders;
  bool get isCreatingOrder => _isCreatingOrder;
  bool get isCancellingOrder => _isCancellingOrder;
  String? get errorMessage => _errorMessage;
  OrderStatus? get statusFilter => _statusFilter;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasMoreOrders => _hasMoreOrders;

  // Computed getters
  List<Order> get activeOrders => _orders.where((order) => order.isActive).toList();
  List<Order> get completedOrders => _orders.where((order) => !order.isActive).toList();
  List<Order> get pendingOrders => _orders.where((order) => 
    order.status == OrderStatus.pending || order.status == OrderStatus.confirmed
  ).toList();
  List<Order> get inProgressOrders => _orders.where((order) => 
    order.status == OrderStatus.preparing || order.status == OrderStatus.ready || 
    order.status == OrderStatus.outForDelivery
  ).toList();

  OrderProvider() {
    _initializeData();
  }

  // Initialize data
  Future<void> _initializeData() async {
    await loadOrders();
  }

  // Load orders
  Future<void> loadOrders({OrderStatus? status, bool resetPage = false}) async {
    if (resetPage) {
      _currentPage = 1;
      _hasMoreOrders = true;
    }

    if (!_hasMoreOrders) return;

    _isLoadingOrders = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final orders = await ApiService.getOrders(
        status: status ?? _statusFilter,
        page: _currentPage,
        limit: 20,
      );

      if (resetPage) {
        _orders = orders;
      } else {
        _orders.addAll(orders);
      }

      // Check if there are more orders
      _hasMoreOrders = orders.length == 20;
      _currentPage++;

      _isLoadingOrders = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoadingOrders = false;
      notifyListeners();
    }
  }

  // Load order details
  Future<void> loadOrderDetails(String orderId) async {
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

  // Create new order
  Future<bool> createOrder({
    required List<CartItem> items,
    required Address deliveryAddress,
    required PaymentMethod paymentMethod,
    String? specialInstructions,
    String? couponCode,
  }) async {
    _isCreatingOrder = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Convert cart items to order items
      final orderItems = items.map((cartItem) => CreateOrderItemRequest(
        productId: cartItem.product.id,
        quantity: cartItem.quantity,
        customizations: cartItem.customizations,
        specialInstructions: cartItem.specialInstructions,
      )).toList();

      final request = CreateOrderRequest(
        items: orderItems,
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
        specialInstructions: specialInstructions,
        couponCode: couponCode,
      );

      final order = await ApiService.createOrder(request);
      
      // Add to orders list
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

  // Cancel order
  Future<bool> cancelOrder(String orderId, {String? reason}) async {
    _isCancellingOrder = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedOrder = await ApiService.cancelOrder(orderId, reason: reason);
      
      // Update order in the list
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _orders[index] = updatedOrder;
      }
      
      // Update selected order if it's the same
      if (_selectedOrder?.id == orderId) {
        _selectedOrder = updatedOrder;
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

  // Load delivery information
  Future<void> loadDeliveryInfo(String orderId) async {
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

  // Update delivery location (for driver)
  Future<bool> updateDeliveryLocation(String orderId, double latitude, double longitude) async {
    try {
      final updatedDeliveryInfo = await ApiService.updateDeliveryLocation(orderId, latitude, longitude);
      _deliveryInfo = updatedDeliveryInfo;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  // Filter orders by status
  Future<void> filterByStatus(OrderStatus? status) async {
    _statusFilter = status;
    await loadOrders(resetPage: true);
  }

  // Clear status filter
  Future<void> clearStatusFilter() async {
    _statusFilter = null;
    await loadOrders(resetPage: true);
  }

  // Load more orders (pagination)
  Future<void> loadMoreOrders() async {
    if (!_isLoadingOrders && _hasMoreOrders) {
      await loadOrders();
    }
  }

  // Refresh orders
  Future<void> refreshOrders() async {
    await loadOrders(resetPage: true);
  }

  // Refresh specific order
  Future<void> refreshOrder(String orderId) async {
    try {
      final updatedOrder = await ApiService.getOrderDetails(orderId);
      
      // Update order in the list
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _orders[index] = updatedOrder;
      }
      
      // Update selected order if it's the same
      if (_selectedOrder?.id == orderId) {
        _selectedOrder = updatedOrder;
      }
      
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  // Get order status display
  String getOrderStatusDisplay(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready for Pickup';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  // Get order status color
  String getOrderStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return '#FF9800'; // Orange
      case OrderStatus.confirmed:
        return '#2196F3'; // Blue
      case OrderStatus.preparing:
        return '#9C27B0'; // Purple
      case OrderStatus.ready:
        return '#4CAF50'; // Green
      case OrderStatus.outForDelivery:
        return '#3F51B5'; // Indigo
      case OrderStatus.delivered:
        return '#4CAF50'; // Green
      case OrderStatus.cancelled:
        return '#F44336'; // Red
    }
  }

  // Get estimated delivery time
  DateTime? getEstimatedDeliveryTime(String orderId) {
    final order = _orders.firstWhere((o) => o.id == orderId, orElse: () => _selectedOrder!);
    return order.estimatedDeliveryTime;
  }

  // Calculate order statistics
  Map<String, dynamic> getOrderStatistics() {
    final totalOrders = _orders.length;
    final activeOrdersCount = activeOrders.length;
    final completedOrdersCount = completedOrders.length;
    final cancelledOrdersCount = _orders.where((o) => o.status == OrderStatus.cancelled).length;
    
    final totalSpent = _orders
        .where((o) => o.status == OrderStatus.delivered)
        .fold(0.0, (sum, order) => sum + order.total);
    
    final averageOrderValue = completedOrdersCount > 0 ? totalSpent / completedOrdersCount : 0.0;

    return {
      'totalOrders': totalOrders,
      'activeOrders': activeOrdersCount,
      'completedOrders': completedOrdersCount,
      'cancelledOrders': cancelledOrdersCount,
      'totalSpent': totalSpent,
      'averageOrderValue': averageOrderValue,
      'formattedTotalSpent': '\$${totalSpent.toStringAsFixed(2)}',
      'formattedAverageOrderValue': '\$${averageOrderValue.toStringAsFixed(2)}',
    };
  }

  // Get orders from current month
  List<Order> getCurrentMonthOrders() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    
    return _orders.where((order) {
      return order.createdAt.isAfter(currentMonth) && order.createdAt.isBefore(nextMonth);
    }).toList();
  }

  // Track order status updates
  void startOrderTracking(String orderId) {
    // This would typically set up a timer or websocket connection
    // to track real-time order status updates
    debugPrint('Started tracking order: $orderId');
  }

  void stopOrderTracking(String orderId) {
    // This would typically clean up the tracking mechanism
    debugPrint('Stopped tracking order: $orderId');
  }

  // Get order timeline
  List<Map<String, dynamic>> getOrderTimeline(Order order) {
    final timeline = <Map<String, dynamic>>[];
    
    // Add status history
    for (final update in order.statusHistory) {
      timeline.add({
        'status': update.status,
        'timestamp': update.timestamp,
        'title': getOrderStatusDisplay(update.status),
        'description': update.note ?? '',
        'isCompleted': true,
      });
    }
    
    // Add future estimated steps for active orders
    if (order.isActive) {
      final remainingSteps = <OrderStatus>[];
      
      if (order.status.index < OrderStatus.preparing.index) {
        remainingSteps.addAll([
          OrderStatus.preparing,
          OrderStatus.ready,
          OrderStatus.outForDelivery,
          OrderStatus.delivered,
        ]);
      } else if (order.status.index < OrderStatus.ready.index) {
        remainingSteps.addAll([
          OrderStatus.ready,
          OrderStatus.outForDelivery,
          OrderStatus.delivered,
        ]);
      } else if (order.status.index < OrderStatus.outForDelivery.index) {
        remainingSteps.addAll([
          OrderStatus.outForDelivery,
          OrderStatus.delivered,
        ]);
      } else if (order.status.index < OrderStatus.delivered.index) {
        remainingSteps.add(OrderStatus.delivered);
      }
      
      for (final status in remainingSteps) {
        timeline.add({
          'status': status,
          'timestamp': null,
          'title': getOrderStatusDisplay(status),
          'description': '',
          'isCompleted': false,
        });
      }
    }
    
    return timeline;
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Reset state
  void resetState() {
    _selectedOrder = null;
    _deliveryInfo = null;
    _statusFilter = null;
    _currentPage = 1;
    _totalPages = 1;
    _hasMoreOrders = true;
    notifyListeners();
  }
}
