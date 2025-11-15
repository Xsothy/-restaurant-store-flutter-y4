import 'package:flutter/foundation.dart';

import '../models/cart.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class CartProvider extends ChangeNotifier {
  Cart? _cart;
  bool _isLoading = false;
  String? _errorMessage;

  Cart? get cart => _cart;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasItems => (_cart?.items.isNotEmpty ?? false);
  int get itemCount => _cart?.itemCount ?? 0;
  double get subtotal => _cart?.subtotal ?? 0.0;
  double get vat => _cart?.vat ?? 0.0;
  double get deliveryFee => _cart?.deliveryFee ?? 0.0;
  double get total => _cart?.total ?? 0.0;
  String get formattedTotal => _cart?.formattedTotal ?? '\$0.00';
  String get formattedSubtotal => _cart?.formattedSubtotal ?? '\$0.00';
  String get formattedTax => _cart?.formattedVat ?? '\$0.00';
  String get formattedDeliveryFee => _cart?.formattedDeliveryFee ?? 'FREE';

  CartProvider() {
    _initializeCart();
  }

  Future<void> _initializeCart() async {
    try {
      final savedCart = StorageService.getCart();
      if (savedCart != null) {
        _cart = savedCart;
        notifyListeners();
      }
      await loadCartFromServer();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadCartFromServer() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final serverCart = await ApiService.getCart();
      _cart = serverCart;
      await StorageService.saveCart(serverCart);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _setLoading(false);
  }

  Future<bool> addToCart(
    Product product, {
    int quantity = 1,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final sanitizedQuantity = quantity <= 0 ? 1 : quantity;
      final request = AddToCartRequest(productId: product.id, quantity: sanitizedQuantity);
      final updatedCart = await ApiService.addToCart(request);
      _cart = updatedCart;
      await StorageService.saveCart(updatedCart);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateItemQuantity(int cartItemId, int quantity) async {
    if (quantity <= 0) {
      return removeFromCart(cartItemId);
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      final request = UpdateCartRequest(cartItemId: cartItemId, quantity: quantity);
      final updatedCart = await ApiService.updateCartItem(request);
      _cart = updatedCart;
      await StorageService.saveCart(updatedCart);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> removeFromCart(int cartItemId) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final updatedCart = await ApiService.removeFromCart(cartItemId);
      _cart = updatedCart;
      await StorageService.saveCart(updatedCart);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> clearCart() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await ApiService.clearCart();
      await StorageService.clearCart();

      try {
        final refreshedCart = await ApiService.getCart();
        _cart = refreshedCart;
        await StorageService.saveCart(refreshedCart);
      } catch (_) {
        _cart = Cart(
          id: _cart?.id ?? 0,
          items: const [],
          subtotal: 0,
          vat: 0,
          deliveryFee: 0,
          total: 0,
          itemCount: 0,
        );
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
