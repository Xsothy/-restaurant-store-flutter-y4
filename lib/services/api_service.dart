import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../constants/app_constants.dart';
import '../models/cart.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/user.dart';

class ApiService {
  static late Dio _dio;
  static const String _baseUrl = AppConstants.baseUrl;

  static void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: AppConstants.connectionTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _getAuthToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            _handleUnauthorized();
          }
          handler.next(error);
        },
      ),
    );

    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
  }

  static String? _getAuthToken() {
    // AuthProvider wires the token through [updateAuthToken]. Keeping the
    // method for future secure storage integration.
    return _dio.options.headers['Authorization']?.toString().replaceFirst('Bearer ', '');
  }

  static void _handleUnauthorized() {
    clearAuthToken();
  }

  static void updateAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  static void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  // Authentication APIs
  static Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post('/auth/login', data: request.toJson());
      return AuthResponse.fromJson(_asMap(response.data));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _dio.post('/auth/register', data: request.toJson());
      return AuthResponse.fromJson(_asMap(response.data));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Product and Category APIs
  static Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get('/categories');
      final list = _asList(response.data);
      return list.map((item) => Category.fromJson(item as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<List<Product>> getProducts({
    int? categoryId,
    bool availableOnly = true,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (availableOnly) queryParams['availableOnly'] = true;

      final response = await _dio.get('/products', queryParameters: queryParams);
      final list = _asList(response.data);
      return list.map((item) => Product.fromJson(item as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Product> getProductDetails(int productId) async {
    try {
      final response = await _dio.get('/products/$productId');
      return Product.fromJson(_asMap(response.data));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Cart APIs
  static Future<Cart> getCart() async {
    try {
      final response = await _dio.get('/cart');
      return Cart.fromJson(_asMap(response.data));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Cart> addToCart(AddToCartRequest request) async {
    try {
      final response = await _dio.post('/cart/add', data: request.toJson());
      return Cart.fromJson(_asMap(response.data));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Cart> updateCartItem(UpdateCartRequest request) async {
    try {
      final response = await _dio.put(
        '/cart/items/${request.cartItemId}',
        data: request.toJson(),
      );
      return Cart.fromJson(_asMap(response.data));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Cart> removeFromCart(int cartItemId) async {
    try {
      final response = await _dio.delete('/cart/items/$cartItemId');
      return Cart.fromJson(_asMap(response.data));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<void> clearCart() async {
    try {
      await _dio.delete('/cart/clear');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Order APIs
  static Future<Order> createOrder(CreateOrderRequest request) async {
    try {
      final response = await _dio.post('/orders', data: request.toJson());
      return Order.fromJson(_asMap(response.data));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<List<Order>> getOrders({OrderStatus? status}) async {
    try {
      final response = await _dio.get('/orders/my-orders');
      final list = _asList(response.data);
      final orders = list.map((item) => Order.fromJson(item as Map<String, dynamic>)).toList();
      if (status == null) {
        return orders;
      }
      return orders.where((order) => order.status == status).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Order> getOrderDetails(int orderId) async {
    try {
      final response = await _dio.get('/orders/$orderId');
      return Order.fromJson(_asMap(response.data));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<String> cancelOrder(int orderId, {String? reason}) async {
    try {
      final response = await _dio.put(
        '/orders/$orderId/cancel',
        data: reason != null ? {'reason': reason} : null,
      );
      return _asString(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Delivery APIs
  static Future<DeliveryInfo> getDeliveryInfo(int orderId) async {
    try {
      final response = await _dio.get('/deliveries/$orderId');
      return DeliveryInfo.fromJson(_asMap(response.data));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<String> updateDeliveryLocation(int deliveryId, String location) async {
    try {
      final response = await _dio.put(
        '/deliveries/$deliveryId/update-location',
        queryParameters: {'location': location},
      );
      return _asString(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<String> updateDeliveryStatus(int deliveryId, String status) async {
    try {
      final response = await _dio.put(
        '/deliveries/$deliveryId/update-status',
        queryParameters: {'status': status},
      );
      return _asString(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Helpers
  static Map<String, dynamic> _asMap(dynamic data) {
    final unwrapped = _unwrapResponse(data);
    if (unwrapped is Map<String, dynamic>) {
      return unwrapped;
    }
    return <String, dynamic>{};
  }

  static List<dynamic> _asList(dynamic data) {
    final unwrapped = _unwrapResponse(data);
    if (unwrapped is List) {
      return unwrapped;
    }
    if (unwrapped is Map<String, dynamic>) {
      if (unwrapped['content'] is List) {
        return unwrapped['content'] as List<dynamic>;
      }
      if (unwrapped['items'] is List) {
        return unwrapped['items'] as List<dynamic>;
      }
      if (unwrapped['data'] is List) {
        return unwrapped['data'] as List<dynamic>;
      }
    }
    return const [];
  }

  static dynamic _unwrapResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data.containsKey('data') && data['data'] != null) {
        return data['data'];
      }
    }
    return data;
  }

  static String _asString(dynamic data) {
    final unwrapped = _unwrapResponse(data);
    if (unwrapped is String && unwrapped.isNotEmpty) {
      return unwrapped;
    }
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString();
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }
    return data?.toString() ?? '';
  }

  static String _handleError(DioException e) {
    final responseData = e.response?.data;
    final message = () {
      if (responseData == null) return 'Unknown error';
      final map = _asMap(responseData);
      if (map.containsKey('message')) return map['message'].toString();
      if (map.containsKey('error')) return map['error'].toString();
      return responseData.toString();
    }();

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return AppConstants.networkError;
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        switch (statusCode) {
          case 400:
            return 'Bad request: $message';
          case 401:
            return AppConstants.authError;
          case 403:
            return 'Access denied: $message';
          case 404:
            return 'Resource not found: $message';
          case 409:
            return 'Conflict: $message';
          case 500:
            return AppConstants.serverError;
          default:
            return message;
        }
      case DioExceptionType.badCertificate:
        return 'SSL certificate error';
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      case DioExceptionType.unknown:
      default:
        return AppConstants.generalError;
    }
  }
}
