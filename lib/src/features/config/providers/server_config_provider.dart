import 'package:flutter/foundation.dart';

import 'package:restaurant_store_flutter/src/core/config/app_environment.dart';
import 'package:restaurant_store_flutter/src/data/services/api_service.dart';
import 'package:restaurant_store_flutter/src/data/services/storage_service.dart';

class ServerConfigProvider extends ChangeNotifier {
  String _baseUrl = AppEnvironment.apiBaseUrl;
  bool _isSaving = false;
  bool _isInitialized = false;
  bool _isConfigured = false;
  String? _errorMessage;

  ServerConfigProvider() {
    _loadConfiguration();
  }

  String get baseUrl => _baseUrl;
  bool get isSaving => _isSaving;
  bool get isInitialized => _isInitialized;
  bool get isConfigured => _isConfigured;
  String? get errorMessage => _errorMessage;
  bool get requiresConfiguration => _isInitialized && !_isConfigured;

  Future<void> _loadConfiguration() async {
    final storedUrl = StorageService.getApiBaseUrl();
    if (storedUrl != null && storedUrl.isNotEmpty) {
      _baseUrl = storedUrl;
      _isConfigured = true;
      ApiService.updateBaseUrl(storedUrl);
    } else {
      _baseUrl = AppEnvironment.apiBaseUrl;
      _isConfigured = false;
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<bool> saveBaseUrl(String url) async {
    final normalized = _normalizeUrl(url);
    if (normalized == null) {
      _errorMessage = 'Please enter a valid base URL (e.g. http://192.168.1.10:8080/api).';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    await StorageService.saveApiBaseUrl(normalized);
    ApiService.updateBaseUrl(normalized);

    _baseUrl = normalized;
    _isConfigured = true;
    _isSaving = false;
    notifyListeners();
    return true;
  }

  Future<void> resetConfiguration() async {
    await StorageService.removeApiBaseUrl();
    _baseUrl = AppEnvironment.apiBaseUrl;
    _isConfigured = false;
    ApiService.updateBaseUrl(_baseUrl);
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  String? _normalizeUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final candidate = (trimmed.startsWith('http://') || trimmed.startsWith('https://'))
        ? trimmed
        : 'http://$trimmed';

    final uri = Uri.tryParse(candidate);
    if (uri == null || uri.scheme.isEmpty || uri.host.isEmpty) {
      return null;
    }

    final sanitizedPath = uri.path.endsWith('/') && uri.path.length > 1
        ? uri.path.substring(0, uri.path.length - 1)
        : uri.path;
    final normalized = uri.replace(path: sanitizedPath);
    return normalized.toString();
  }
}
