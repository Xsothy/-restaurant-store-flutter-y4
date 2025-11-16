import 'package:flutter/foundation.dart';

import 'package:restaurant_store_flutter/src/core/constants/app_constants.dart';
import 'package:restaurant_store_flutter/src/core/exceptions/app_exception.dart';
import 'package:restaurant_store_flutter/src/data/models/user.dart';
import 'package:restaurant_store_flutter/src/data/services/api_service.dart';
import 'package:restaurant_store_flutter/src/data/services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;
  String? get authToken => StorageService.getAuthToken();

  AuthProvider() {
    _initializeAuth();
  }

  // Initialize authentication state
  Future<void> _initializeAuth() async {
    await _checkAuthStatus();
  }

  // Check if user is authenticated
  Future<void> _checkAuthStatus() async {
    try {
      final token = StorageService.getAuthToken();
      final user = StorageService.getUser();

      if (token != null && user != null) {
        _user = user;
        _isAuthenticated = true;
        ApiService.updateAuthToken(token);
      } else {
        _isAuthenticated = false;
        ApiService.clearAuthToken();
      }
    } catch (e) {
      _isAuthenticated = false;
      ApiService.clearAuthToken();
    }
    notifyListeners();
  }

  // Login user
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final loginRequest = LoginRequest(email: email, password: password);
      final response = await ApiService.login(loginRequest);

      // Save token and user data
      await StorageService.saveAuthToken(response.token);
      await StorageService.saveUser(response.customer);

      // Update state
      _user = response.customer;
      _isAuthenticated = true;
      ApiService.updateAuthToken(response.token);
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e, stackTrace) {
      debugPrint('Login failed: $e');
      FlutterError.reportError(FlutterErrorDetails(exception: e, stack: stackTrace));
      _errorMessage = AppConstants.generalError;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register new user
  Future<bool> register(
    String firstName,
    String lastName,
    String email,
    String phone,
    String password, {
    Address? address,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final fullName = '$firstName $lastName'.trim();
      final registerRequest = RegisterRequest(
        name: fullName,
        email: email,
        phone: phone.isNotEmpty ? phone : null,
        password: password,
        address: address,
      );
      final response = await ApiService.register(registerRequest);

      // Save token and user data
      await StorageService.saveAuthToken(response.token);
      await StorageService.saveUser(response.customer);

      // Update state
      _user = response.customer;
      _isAuthenticated = true;
      ApiService.updateAuthToken(response.token);
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e, stackTrace) {
      debugPrint('Registration failed: $e');
      FlutterError.reportError(FlutterErrorDetails(exception: e, stack: stackTrace));
      _errorMessage = AppConstants.generalError;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout user
  Future<void> logout() async {
    _setLoading(true);

    try {
      // Call logout API
      await ApiService.logout();
    } on AppException catch (e) {
      // Continue with local logout even if API call fails
      debugPrint('Logout API call failed: ${e.message}');
    } catch (e, stackTrace) {
      debugPrint('Logout API call failed: $e');
      FlutterError.reportError(FlutterErrorDetails(exception: e, stack: stackTrace));
    }

    // Clear local storage
    await StorageService.removeAuthToken();
    await StorageService.removeUser();

    // Clear API service token
    ApiService.clearAuthToken();

    // Update state
    _user = null;
    _isAuthenticated = false;

    _setLoading(false);
  }

  // Refresh authentication token
  Future<bool> refreshToken() async => false;

  // Validate email format
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate phone format
  bool isValidPhone(String phone) {
    if (phone.isEmpty) {
      return false;
    }
    const allowedChars = '0123456789-+() ';
    return phone.split('').every((char) => allowedChars.contains(char));
  }

  // Validate password strength
  String? validatePassword(String password) {
    if (password.isEmpty) return AppConstants.passwordRequired;
    if (password.length < 6) return AppConstants.passwordTooShort;
    return null;
  }

  // Validate required fields
  String? validateRequired(String value, String fieldName) {
    if (value.isEmpty) return '$fieldName is required';
    return null;
  }

  // Validate phone number
  String? validatePhone(String phone) {
    if (phone.isEmpty) return AppConstants.phoneRequired;
    if (!isValidPhone(phone)) {
      return AppConstants.phoneInvalid;
    }
    return null;
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

  // Check if user has specific role or permission
  bool hasPermission(String permission) {
    // This would be implemented based on user roles/permissions
    return _isAuthenticated;
  }

  // Get user display name
  String get userDisplayName => _user?.fullName ?? 'Guest';

  // Get user initials for avatar
  String get userInitials {
    if (_user == null) return 'G';
    final name = _user!.fullName;
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else {
      return name.substring(0, 1).toUpperCase();
    }
  }

  // Check if user profile is complete
  bool get isProfileComplete {
    if (_user == null) return false;
    return _user!.firstName.isNotEmpty &&
        _user!.lastName.isNotEmpty &&
        _user!.email.isNotEmpty &&
        (_user!.phone?.isNotEmpty ?? false);
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // This would typically call a forgot password API
      // For now, we'll just simulate the call
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e, stackTrace) {
      debugPrint('Reset password failed: $e');
      FlutterError.reportError(FlutterErrorDetails(exception: e, stack: stackTrace));
      _errorMessage = AppConstants.generalError;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Change password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // This would typically call a change password API
      // For now, we'll just simulate the call
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e, stackTrace) {
      debugPrint('Change password failed: $e');
      FlutterError.reportError(FlutterErrorDetails(exception: e, stack: stackTrace));
      _errorMessage = AppConstants.generalError;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete account
  Future<bool> deleteAccount() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // This would typically call a delete account API
      // For now, we'll just simulate the call
      await Future.delayed(const Duration(seconds: 1));

      // Logout after successful deletion
      await logout();
      return true;
    } catch (e, stackTrace) {
      debugPrint('Delete account failed: $e');
      FlutterError.reportError(FlutterErrorDetails(exception: e, stack: stackTrace));
      _errorMessage = AppConstants.generalError;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? address,
  }) async {
    if (_user == null) return false;

    _setLoading(true);
    _errorMessage = null;

    try {
      final updatedUser = await ApiService.updateCustomerProfile(
        customerId: _user!.id,
        name: name,
        email: email,
        phone: phone,
        address: address,
      );

      _user = updatedUser;
      await StorageService.saveUser(updatedUser);
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e, stackTrace) {
      debugPrint('Update profile failed: $e');
      FlutterError.reportError(FlutterErrorDetails(exception: e, stack: stackTrace));
      _errorMessage = AppConstants.generalError;
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
