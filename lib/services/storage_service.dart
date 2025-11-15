import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import '../constants/app_constants.dart';
import '../models/user.dart';
import '../models/cart.dart';

class StorageService {
  static late SharedPreferences _prefs;
  static late Box _cartBox;
  static late Box _userBox;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) {
      return;
    }

    _prefs = await SharedPreferences.getInstance();

    // Initialize Hive boxes
    _cartBox = Hive.isBoxOpen('cart') ? Hive.box('cart') : await Hive.openBox('cart');
    _userBox = Hive.isBoxOpen('user') ? Hive.box('user') : await Hive.openBox('user');

    _initialized = true;
  }

  // Authentication Token Management
  static Future<void> saveAuthToken(String token) async {
    await _prefs.setString(AppConstants.tokenKey, token);
  }

  static String? getAuthToken() {
    return _prefs.getString(AppConstants.tokenKey);
  }

  static Future<void> removeAuthToken() async {
    await _prefs.remove(AppConstants.tokenKey);
  }

  // User Data Management
  static Future<void> saveUser(User user) async {
    final userJson = jsonEncode(user.toJson());
    await _prefs.setString(AppConstants.userKey, userJson);
    await _userBox.put('currentUser', user.toJson());
  }

  static User? getUser() {
    final userJson = _prefs.getString(AppConstants.userKey);
    if (userJson != null) {
      try {
        final userMap = jsonDecode(userJson);
        return User.fromJson(userMap);
      } catch (e) {
        // Try to get from Hive if SharedPreferences fails
        final userData = _userBox.get('currentUser');
        if (userData != null) {
          return User.fromJson(userData);
        }
      }
    }
    return null;
  }

  static Future<void> removeUser() async {
    await _prefs.remove(AppConstants.userKey);
    await _userBox.delete('currentUser');
  }

  // Cart Management (using Hive for better performance with complex objects)
  static Future<void> saveCart(Cart cart) async {
    await _cartBox.put('currentCart', cart.toJson());
  }

  static Cart? getCart() {
    final cartData = _cartBox.get('currentCart');
    if (cartData != null) {
      try {
        return Cart.fromJson(cartData);
      } catch (e) {
        // Clear corrupted cart data
        _cartBox.delete('currentCart');
      }
    }
    return null;
  }

  static Future<void> clearCart() async {
    await _cartBox.delete('currentCart');
  }

  // Theme Management
  static Future<void> saveThemeMode(String themeMode) async {
    await _prefs.setString(AppConstants.themeKey, themeMode);
  }

  static String? getThemeMode() {
    return _prefs.getString(AppConstants.themeKey);
  }

  // Language Management
  static Future<void> saveLanguageCode(String languageCode) async {
    await _prefs.setString(AppConstants.languageKey, languageCode);
  }

  static String? getLanguageCode() {
    return _prefs.getString(AppConstants.languageKey);
  }

  // Onboarding Status
  static Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs.setBool('onboarding_completed', completed);
  }

  static bool isOnboardingCompleted() {
    return _prefs.getBool('onboarding_completed') ?? false;
  }

  // User Preferences
  static Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    await _prefs.setString('user_preferences', jsonEncode(preferences));
  }

  static Map<String, dynamic>? getUserPreferences() {
    final prefsJson = _prefs.getString('user_preferences');
    if (prefsJson != null) {
      try {
        return jsonDecode(prefsJson);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Delivery Addresses
  static Future<void> saveDeliveryAddresses(List<Map<String, dynamic>> addresses) async {
    await _prefs.setStringList('delivery_addresses', addresses.map((addr) => jsonEncode(addr)).toList());
  }

  static Future<void> addDeliveryAddress(Map<String, dynamic> address) async {
    final addresses = getDeliveryAddresses();
    addresses.add(address);
    await saveDeliveryAddresses(addresses);
  }

  static Future<void> removeDeliveryAddress(int index) async {
    final addresses = getDeliveryAddresses();
    if (index < addresses.length) {
      addresses.removeAt(index);
      await saveDeliveryAddresses(addresses);
    }
  }

  static List<Map<String, dynamic>> getDeliveryAddresses() {
    final addressesStrings = _prefs.getStringList('delivery_addresses') ?? [];
    return addressesStrings
        .map((addr) {
          try {
            final decoded = jsonDecode(addr);
            if (decoded is Map<String, dynamic>) {
              return Map<String, dynamic>.from(decoded);
            }
          } catch (e) {
            // Ignore malformed entries and fall back to an empty map.
          }
          return <String, dynamic>{};
        })
        .where((addr) => addr.isNotEmpty)
        .toList();
  }

  // App Settings
  static Future<void> saveNotificationSettings(Map<String, bool> settings) async {
    await _prefs.setString('notification_settings', jsonEncode(settings));
  }

  static Map<String, bool> getNotificationSettings() {
    final settingsJson = _prefs.getString('notification_settings');
    if (settingsJson != null) {
      try {
        final settings = jsonDecode(settingsJson);
        return Map<String, bool>.from(settings);
      } catch (e) {
        // Return default settings
        return {
          'order_updates': true,
          'promotions': true,
          'delivery_updates': true,
          'recommendations': false,
        };
      }
    }
    // Return default settings
    return {
      'order_updates': true,
      'promotions': true,
      'delivery_updates': true,
      'recommendations': false,
    };
  }

  // Clear all data (for logout)
  static Future<void> clearAllData() async {
    await removeAuthToken();
    await removeUser();
    await clearCart();
    // Keep some data like theme, language, and preferences
  }

  // Clear all app data (for reset)
  static Future<void> clearAllAppData() async {
    await _prefs.clear();
    await _cartBox.clear();
    await _userBox.clear();
  }
}
