import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/cart.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../constants/app_constants.dart';

class CartProvider extends ChangeNotifier {
  Cart? _cart;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Cart? get cart => _cart;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasItems => _cart?.items.isNotEmpty ?? false;
  int get itemCount => _cart?.itemCount ?? 0;
  double get subtotal => _cart?.subtotal ?? 0.0;
  double get tax => _cart?.tax ?? 0.0;
  double get deliveryFee => _cart?.deliveryFee ?? 0.0;
  double get total => _cart?.total ?? 0.0;
  String get formattedTotal => _cart?.formattedTotal ?? '\$0.00';
  String get formattedSubtotal => _cart?.formattedSubtotal ?? '\$0.00';
  String get formattedTax => _cart?.formattedTax ?? '\$0.00';
  String get formattedDeliveryFee => _cart?.formattedDeliveryFee ?? 'FREE';

  CartProvider() {
    _initializeCart();
  }

  // Initialize cart from local storage
  Future<void> _initializeCart() async {
    try {
      final savedCart = StorageService.getCart();
      if (savedCart != null) {
        _cart = savedCart;
      } else {
        // Create empty cart
        _cart = Cart(
          id: const Uuid().v4(),
          items: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await StorageService.saveCart(_cart!);
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load cart';
      notifyListeners();
    }
  }

  // Load cart from server (when user is authenticated)
  Future<void> loadCartFromServer() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final serverCart = await ApiService.getCart();
      _cart = serverCart;
      await StorageService.saveCart(_cart!);
      _setLoading(false);
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
    }
  }

  // Add item to cart
  Future<bool> addToCart(
    Product product, {
    int quantity = 1,
    List<String> customizations = const [],
    String? specialInstructions,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // Create cart item
      final cartItem = CartItem(
        id: const Uuid().v4(),
        product: product,
        quantity: quantity,
        customizations: customizations,
        specialInstructions: specialInstructions,
        addedAt: DateTime.now(),
      );

      // Check if item already exists in cart
      final existingItemIndex = _cart!.items.indexWhere(
        (item) =>
            item.product.id == product.id &&
            _listEquals(item.customizations, customizations) &&
            item.specialInstructions == specialInstructions,
      );

      if (existingItemIndex != -1) {
        // Update quantity of existing item
        final existingItem = _cart!.items[existingItemIndex];
        final updatedItem = existingItem.copyWith(
          quantity: existingItem.quantity + quantity,
        );
        _cart!.items[existingItemIndex] = updatedItem;
      } else {
        // Add new item
        _cart!.items.add(cartItem);
      }

      // Update cart timestamp
      _cart = _cart!.copyWith(updatedAt: DateTime.now());

      // Save to local storage
      await StorageService.saveCart(_cart!);

      // Try to sync with server
      try {
        final request = AddToCartRequest(
          productId: product.id,
          quantity: quantity,
          customizations: customizations,
          specialInstructions: specialInstructions,
        );
        await ApiService.addToCart(request);
      } catch (e) {
        // Continue even if server sync fails
        debugPrint('Server sync failed: $e');
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Update cart item quantity
  Future<bool> updateItemQuantity(String cartItemId, int quantity) async {
    if (quantity <= 0) {
      return removeFromCart(cartItemId);
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      final itemIndex = _cart!.items.indexWhere((item) => item.id == cartItemId);
      if (itemIndex != -1) {
        final updatedItem = _cart!.items[itemIndex].copyWith(quantity: quantity);
        _cart!.items[itemIndex] = updatedItem;
        _cart = _cart!.copyWith(updatedAt: DateTime.now());

        await StorageService.saveCart(_cart!);

        // Try to sync with server
        try {
          final request = UpdateCartRequest(cartItemId: cartItemId, quantity: quantity);
          await ApiService.updateCartItem(request);
        } catch (e) {
          debugPrint('Server sync failed: $e');
        }
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Remove item from cart
  Future<bool> removeFromCart(String cartItemId) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _cart!.items.removeWhere((item) => item.id == cartItemId);
      _cart = _cart!.copyWith(updatedAt: DateTime.now());

      await StorageService.saveCart(_cart!);

      // Try to sync with server
      try {
        await ApiService.removeFromCart(cartItemId);
      } catch (e) {
        debugPrint('Server sync failed: $e');
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Clear entire cart
  Future<bool> clearCart() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _cart!.items.clear();
      _cart = _cart!.copyWith(updatedAt: DateTime.now());

      await StorageService.saveCart(_cart!);

      // Try to sync with server
      try {
        await ApiService.clearCart();
      } catch (e) {
        debugPrint('Server sync failed: $e');
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Get cart item by product ID
  CartItem? getItemByProductId(int productId) {
    try {
      return _cart!.items.firstWhere((item) => item.product.id == productId);
    } catch (e) {
      return null;
    }
  }

  // Get quantity of product in cart
  int getQuantity(int productId) {
    final item = getItemByProductId(productId);
    return item?.quantity ?? 0;
  }

  // Check if product is in cart
  bool isInCart(int productId) {
    return getItemByProductId(productId) != null;
  }

  // Get items grouped by category
  Map<String, List<CartItem>> getItemsByCategory() {
    final groupedItems = <String, List<CartItem>>{};
    
    for (final item in _cart!.items) {
      final categoryName = item.product.category.name;
      if (!groupedItems.containsKey(categoryName)) {
        groupedItems[categoryName] = [];
      }
      groupedItems[categoryName]!.add(item);
    }
    
    return groupedItems;
  }

  // Validate cart for checkout
  String? validateCartForCheckout() {
    if (_cart == null || _cart!.items.isEmpty) {
      return 'Your cart is empty';
    }

    // Check if all items are still available
    for (final item in _cart!.items) {
      if (!item.product.isAvailable) {
        return '${item.product.name} is no longer available';
      }
    }

    // Check minimum order amount
    if (subtotal < AppConstants.minOrderAmount) {
      return 'Minimum order amount is \$${AppConstants.minOrderAmount}';
    }

    return null;
  }

  // Get estimated delivery time
  Duration getEstimatedDeliveryTime() {
    if (_cart == null || _cart!.items.isEmpty) {
      return const Duration(minutes: 30);
    }

    // Calculate based on items with longest preparation time
    int maxPrepTime = 0;
    for (final item in _cart!.items) {
      maxPrepTime = maxPrepTime < item.product.preparationTime 
          ? item.product.preparationTime 
          : maxPrepTime;
    }

    // Add 15 minutes for packaging and delivery pickup
    return Duration(minutes: maxPrepTime + 15);
  }

  // Apply coupon code (placeholder for future implementation)
  Future<bool> applyCoupon(String couponCode) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // This would typically validate the coupon with the server
      await Future.delayed(const Duration(seconds: 1));

      // For now, just return false (no coupons implemented)
      _errorMessage = 'Invalid coupon code';
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Remove coupon code (placeholder for future implementation)
  Future<void> removeCoupon() async {
    // Placeholder for coupon removal logic
  }

  // Get cart summary for checkout
  Map<String, dynamic> getCartSummary() {
    return {
      'itemCount': itemCount,
      'subtotal': subtotal,
      'tax': tax,
      'deliveryFee': deliveryFee,
      'total': total,
      'formattedSubtotal': formattedSubtotal,
      'formattedTax': formattedTax,
      'formattedDeliveryFee': formattedDeliveryFee,
      'formattedTotal': formattedTotal,
      'estimatedDeliveryTime': getEstimatedDeliveryTime().inMinutes,
    };
  }

  // Sync cart with server
  Future<void> syncWithServer() async {
    if (_cart == null) return;

    try {
      // This would typically sync the entire cart with the server
      // For now, we'll just load the server cart
      await loadCartFromServer();
    } catch (e) {
      debugPrint('Server sync failed: $e');
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Helper method to compare lists
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
