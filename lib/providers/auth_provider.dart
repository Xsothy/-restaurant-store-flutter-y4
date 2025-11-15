import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../constants/app_constants.dart';

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

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
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

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    _setLoading(true);

    try {
      // Call logout API
      await ApiService.logout();
    } catch (e) {
      // Continue with local logout even if API call fails
      debugPrint('Logout API call failed: $e');
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

  // Update user profile
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    Address? address,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // This would typically call an update profile API
      // For now, we'll just update the local user object
      if (_user != null) {
        String? updatedName;
        if (firstName != null || lastName != null) {
          final newFirst = firstName ?? _user!.firstName;
          final newLast = lastName ?? _user!.lastName;
          updatedName = [newFirst, newLast].where((part) => part.trim().isNotEmpty).join(' ').trim();
        }

        final updatedUser = _user!.copyWith(
          name: (updatedName != null && updatedName.isNotEmpty) ? updatedName : null,
          phone: phone ?? _user!.phone,
          address: address ?? _user!.address,
          updatedAt: DateTime.now(),
        );

        await StorageService.saveUser(updatedUser);
        _user = updatedUser;
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
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

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
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

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
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

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }
}
