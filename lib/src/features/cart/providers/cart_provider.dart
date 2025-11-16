import 'package:flutter/foundation.dart';

import 'package:restaurant_store_flutter/src/core/constants/app_constants.dart';
import 'package:restaurant_store_flutter/src/core/exceptions/app_exception.dart';
import 'package:restaurant_store_flutter/src/data/models/cart.dart';
import 'package:restaurant_store_flutter/src/data/models/product.dart';
import 'package:restaurant_store_flutter/src/data/services/api_service.dart';
import 'package:restaurant_store_flutter/src/data/services/storage_service.dart';

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
  String get formattedTotal => _cart?.formattedTotal ?? '0 KHR';
  String get formattedSubtotal => _cart?.formattedSubtotal ?? '0 KHR';
  String get formattedTax => _cart?.formattedVat ?? '0 KHR';
  String get formattedDeliveryFee => _cart?.formattedDeliveryFee ?? 'Free';

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
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e, stackTrace) {
      debugPrint('Failed to initialize cart: $e');
      FlutterError.reportError(FlutterErrorDetails(exception: e, stack: stackTrace));
      _errorMessage = AppConstants.generalError;
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
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e, stackTrace) {
      debugPrint('Failed to load cart: $e');
      FlutterError.reportError(FlutterErrorDetails(exception: e, stack: stackTrace));
      _errorMessage = AppConstants.generalError;
    } finally {
      _setLoading(false);
    }
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
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e, stackTrace) {
      debugPrint('Failed to add to cart: $e');
      FlutterError.reportError(FlutterErrorDetails(exception: e, stack: stackTrace));
      _errorMessage = AppConstants.generalError;
      return false;
    } finally {
      _setLoading(false);
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
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e, stackTrace) {
      debugPrint('Failed to update cart item: $e');
      FlutterError.reportError(FlutterErrorDetails(exception: e, stack: stackTrace));
      _errorMessage = AppConstants.generalError;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> removeFromCart(int cartItemId) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final updatedCart = await ApiService.removeFromCart(cartItemId);
      _cart = updatedCart;
      await StorageService.saveCart(updatedCart);
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e, stackTrace) {
      debugPrint('Failed to remove cart item: $e');
      FlutterError.reportError(FlutterErrorDetails(exception: e, stack: stackTrace));
      _errorMessage = AppConstants.generalError;
      return false;
    } finally {
      _setLoading(false);
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
      } on AppException catch (e) {
        _errorMessage = e.message;
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

      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e, stackTrace) {
      debugPrint('Failed to clear cart: $e');
      FlutterError.reportError(FlutterErrorDetails(exception: e, stack: stackTrace));
      _errorMessage = AppConstants.generalError;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
