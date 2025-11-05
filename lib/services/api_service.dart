import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/app_constants.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../models/cart.dart';
import '../models/order.dart';

class ApiService {
  static late Dio _dio;
  static const String _baseUrl = AppConstants.baseUrl;

  static void init() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: AppConstants.connectionTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token if available
          final token = _getAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          // Handle common errors
          if (error.response?.statusCode == 401) {
            // Handle unauthorized - token expired
            _handleUnauthorized();
          }
          handler.next(error);
        },
      ),
    );

    // Add logging interceptor for debug mode
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
    // This would typically come from secure storage
    // For now, return null - will be implemented with AuthProvider
    return null;
  }

  static void _handleUnauthorized() {
    // Clear stored token and redirect to login
    // This will be implemented with AuthProvider
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
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _dio.post('/auth/register', data: request.toJson());
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<User> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');
      return User.fromJson(response.data);
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
      final List<dynamic> data = response.data;
      return data.map((json) => Category.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<List<Product>> getProducts({
    int? categoryId,
    String? search,
    bool? isVegetarian,
    bool? isVegan,
    bool? isGlutenFree,
    bool? isPopular,
    String? sortBy,
    String? sortOrder,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (isVegetarian != null) queryParams['isVegetarian'] = isVegetarian;
      if (isVegan != null) queryParams['isVegan'] = isVegan;
      if (isGlutenFree != null) queryParams['isGlutenFree'] = isGlutenFree;
      if (isPopular != null) queryParams['isPopular'] = isPopular;
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (sortOrder != null) queryParams['sortOrder'] = sortOrder;

      final response = await _dio.get('/products', queryParameters: queryParams);
      final List<dynamic> data = response.data['content'] ?? response.data;
      return data.map((json) => Product.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Product> getProductDetails(int productId) async {
    try {
      final response = await _dio.get('/products/$productId');
      return Product.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<List<ProductReview>> getProductReviews(
    int productId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/products/$productId/reviews',
        queryParameters: {'page': page, 'limit': limit},
      );
      final List<dynamic> data = response.data['content'] ?? response.data;
      return data.map((json) => ProductReview.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Cart APIs
  static Future<Cart> getCart() async {
    try {
      final response = await _dio.get('/cart');
      return Cart.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Cart> addToCart(AddToCartRequest request) async {
    try {
      final response = await _dio.post('/cart/items', data: request.toJson());
      return Cart.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Cart> updateCartItem(UpdateCartRequest request) async {
    try {
      final response = await _dio.put('/cart/items/${request.cartItemId}', data: request.toJson());
      return Cart.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Cart> removeFromCart(String cartItemId) async {
    try {
      final response = await _dio.delete('/cart/items/$cartItemId');
      return Cart.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Cart> clearCart() async {
    try {
      final response = await _dio.delete('/cart');
      return Cart.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Order APIs
  static Future<Order> createOrder(CreateOrderRequest request) async {
    try {
      final response = await _dio.post('/orders', data: request.toJson());
      return Order.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<List<Order>> getOrders({
    OrderStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (status != null) {
        queryParams['status'] = status.toString().split('.').last;
      }

      final response = await _dio.get('/orders', queryParameters: queryParams);
      final List<dynamic> data = response.data['content'] ?? response.data;
      return data.map((json) => Order.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Order> getOrderDetails(String orderId) async {
    try {
      final response = await _dio.get('/orders/$orderId');
      return Order.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Order> cancelOrder(String orderId, {String? reason}) async {
    try {
      final response = await _dio.post(
        '/orders/$orderId/cancel',
        data: reason != null ? {'reason': reason} : null,
      );
      return Order.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Delivery Tracking APIs
  static Future<DeliveryInfo> getDeliveryInfo(String orderId) async {
    try {
      final response = await _dio.get('/deliveries/$orderId');
      return DeliveryInfo.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<DeliveryInfo> updateDeliveryLocation(
    String orderId,
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await _dio.put(
        '/deliveries/$orderId/location',
        data: {'latitude': latitude, 'longitude': longitude},
      );
      return DeliveryInfo.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error handling
  static String _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppConstants.networkError;
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? 'Unknown error';
        
        switch (statusCode) {
          case 400:
            return 'Bad request: $message';
          case 401:
            return AppConstants.authError;
          case 403:
            return 'Access denied: $message';
          case 404:
            return 'Resource not found: $message';
          case 422:
            return 'Validation error: $message';
          case 500:
            return AppConstants.serverError;
          default:
            return message;
        }
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      case DioExceptionType.connectionError:
        return AppConstants.networkError;
      case DioExceptionType.badCertificate:
        return 'SSL certificate error';
      case DioExceptionType.unknown:
      default:
        return AppConstants.generalError;
    }
  }
}

// Extension for OrderStatus serialization
extension OrderStatusExtension on OrderStatus {
  String toJson() {
    return toString().split('.').last;
  }
}
