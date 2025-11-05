class AppConstants {
  // App Information
  static const String appName = 'FoodRush';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String baseUrl = 'http://localhost:8080/api';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String cartKey = 'cart_items';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Screen Names
  static const String splashScreen = 'splash';
  static const String loginScreen = 'login';
  static const String registerScreen = 'register';
  static const String homeScreen = 'home';
  static const String menuScreen = 'menu';
  static const String productDetailScreen = 'product_detail';
  static const String cartScreen = 'cart';
  static const String checkoutScreen = 'checkout';
  static const String orderTrackingScreen = 'order_tracking';
  static const String profileScreen = 'profile';
  static const String orderHistoryScreen = 'order_history';
  
  // Error Messages
  static const String networkError = 'Please check your internet connection';
  static const String serverError = 'Something went wrong. Please try again';
  static const String authError = 'Authentication failed. Please login again';
  static const String generalError = 'An unexpected error occurred';
  
  // Success Messages
  static const String loginSuccess = 'Login successful!';
  static const String registrationSuccess = 'Registration successful!';
  static const String orderPlacedSuccess = 'Order placed successfully!';
  static const String addedToCart = 'Item added to cart!';
  static const String updatedCart = 'Cart updated successfully!';
  
  // Validation Messages
  static const String emailRequired = 'Email is required';
  static const String emailInvalid = 'Please enter a valid email';
  static const String passwordRequired = 'Password is required';
  static const String passwordTooShort = 'Password must be at least 6 characters';
  static const String nameRequired = 'Name is required';
  static const String phoneRequired = 'Phone number is required';
  static const String phoneInvalid = 'Please enter a valid phone number';
  static const String addressRequired = 'Address is required';
  
  // Cart Constants
  static const double deliveryFee = 2.99;
  static const double taxRate = 0.08; // 8% tax
  static const int minOrderAmount = 10; // Minimum order amount in dollars
  
  // Order Status
  static const String orderPending = 'pending';
  static const String orderConfirmed = 'confirmed';
  static const String orderPreparing = 'preparing';
  static const String orderReady = 'ready';
  static const String orderOutForDelivery = 'out_for_delivery';
  static const String orderDelivered = 'delivered';
  static const String orderCancelled = 'cancelled';
  
  // Payment Methods
  static const String paymentCard = 'card';
  static const String paymentCash = 'cash';
  static const String paymentDigital = 'digital_wallet';
  
  // Social Links
  static const String facebookUrl = 'https://facebook.com/foodrush';
  static const String twitterUrl = 'https://twitter.com/foodrush';
  static const String instagramUrl = 'https://instagram.com/foodrush';
  
  // Support
  static const String supportEmail = 'support@foodrush.com';
  static const String supportPhone = '+1-800-FOODRUSH';
  static const String supportWhatsApp = '+1-800-FOODRUSH';
}
