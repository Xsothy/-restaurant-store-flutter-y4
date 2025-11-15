import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/menu_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_screen.dart';
import '../screens/order_tracking_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/order_history_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppConstants.splashScreen,
    debugLogDiagnostics: true,
    routes: [
      // Splash Screen
      GoRoute(
        name: AppConstants.splashScreen,
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Authentication Routes
      GoRoute(
        name: AppConstants.loginScreen,
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      
      GoRoute(
        name: AppConstants.registerScreen,
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // Main App Routes
      GoRoute(
        name: AppConstants.homeScreen,
        path: '/home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          // Menu
          GoRoute(
            name: AppConstants.menuScreen,
            path: 'menu',
            builder: (context, state) {
              final categoryId = state.uri.queryParameters['categoryId'];
              return MenuScreen(categoryId: categoryId);
            },
            routes: [
              // Product Detail
              GoRoute(
                name: AppConstants.productDetailScreen,
                path: 'product/:productId',
                builder: (context, state) {
                  final productId = int.parse(state.pathParameters['productId']!);
                  return ProductDetailScreen(productId: productId);
                },
              ),
            ],
          ),

          // Cart
          GoRoute(
            name: AppConstants.cartScreen,
            path: 'cart',
            builder: (context, state) => const CartScreen(),
            routes: [
              // Checkout
              GoRoute(
                name: AppConstants.checkoutScreen,
                path: 'checkout',
                builder: (context, state) => const CheckoutScreen(),
              ),
            ],
          ),

          // Order Tracking
          GoRoute(
            name: AppConstants.orderTrackingScreen,
            path: 'order/:orderId/tracking',
            builder: (context, state) {
              final orderId = state.pathParameters['orderId']!;
              return OrderTrackingScreen(orderId: orderId);
            },
          ),

          // Profile
          GoRoute(
            name: AppConstants.profileScreen,
            path: 'profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              // Order History
              GoRoute(
                name: AppConstants.orderHistoryScreen,
                path: 'orders',
                builder: (context, state) => const OrderHistoryScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    
    // Redirect logic
    redirect: (context, state) {
      AuthProvider? authProvider;
      try {
        authProvider = Provider.of<AuthProvider>(context, listen: false);
      } catch (_) {
        return null;
      }

      final isAuthenticated = authProvider.isAuthenticated;
      final location = state.uri.toString();
      
      // Check if user is authenticated
      if (!isAuthenticated) {
        // Allow access to splash, login, and register screens
        if (location.startsWith('/splash') ||
            location.startsWith('/login') ||
            location.startsWith('/register')) {
          return null;
        }
        
        // Redirect to login for all other routes
        return '/login';
      } else {
        // If authenticated and trying to access auth routes, redirect to home
        if (location.startsWith('/login') ||
            location.startsWith('/register') ||
            location.startsWith('/splash')) {
          return '/home';
        }
      }
      
      return null;
    },
    
    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you\'re looking for doesn\'t exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}

// Navigation helper methods
class NavigationHelper {
  static void navigateToSplash(BuildContext context) {
    context.go('/splash');
  }
  
  static void navigateToLogin(BuildContext context) {
    context.go('/login');
  }
  
  static void navigateToRegister(BuildContext context) {
    context.go('/register');
  }
  
  static void navigateToHome(BuildContext context) {
    context.go('/home');
  }
  
  static void navigateToMenu(BuildContext context, {String? categoryId}) {
    if (categoryId != null) {
      context.go('/home/menu?categoryId=$categoryId');
    } else {
      context.go('/home/menu');
    }
  }
  
  static void navigateToProductDetail(BuildContext context, int productId) {
    context.go('/home/menu/product/$productId');
  }
  
  static void navigateToCart(BuildContext context) {
    context.go('/home/cart');
  }
  
  static void navigateToCheckout(BuildContext context) {
    context.go('/home/cart/checkout');
  }
  
  static void navigateToOrderTracking(BuildContext context, String orderId) {
    context.go('/home/order/$orderId/tracking');
  }
  
  static void navigateToProfile(BuildContext context) {
    context.go('/home/profile');
  }
  
  static void navigateToOrderHistory(BuildContext context) {
    context.go('/home/profile/orders');
  }
  
  static void pop(BuildContext context) {
    context.pop();
  }
  
  static void popToHome(BuildContext context) {
    context.go('/home');
  }
}

// Route names for easy reference
class RouteNames {
  static const String splash = AppConstants.splashScreen;
  static const String login = AppConstants.loginScreen;
  static const String register = AppConstants.registerScreen;
  static const String home = AppConstants.homeScreen;
  static const String menu = AppConstants.menuScreen;
  static const String productDetail = AppConstants.productDetailScreen;
  static const String cart = AppConstants.cartScreen;
  static const String checkout = AppConstants.checkoutScreen;
  static const String orderTracking = AppConstants.orderTrackingScreen;
  static const String profile = AppConstants.profileScreen;
  static const String orderHistory = AppConstants.orderHistoryScreen;
}

// Route arguments keys
class RouteArgs {
  static const String productId = 'productId';
  static const String orderId = 'orderId';
  static const String categoryId = 'categoryId';
}

// Query parameters keys
class QueryParams {
  static const String categoryId = 'categoryId';
  static const String search = 'search';
  static const String filter = 'filter';
  static const String sort = 'sort';
}
