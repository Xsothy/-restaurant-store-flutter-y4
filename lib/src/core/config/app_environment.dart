import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Provides strongly-typed access to runtime configuration sourced from the
/// `.env` file. Defaults mirror the example configuration so the app can boot
/// even when environment variables are missing.
class AppEnvironment {
  AppEnvironment._();

  static const Duration _defaultConnectionTimeout = Duration(seconds: 30);
  static const Duration _defaultReceiveTimeout = Duration(seconds: 30);
  static const String _defaultApiBaseUrl = 'http://10.0.2.2:8080/api';
  static const String _defaultStripePublishableKey =
      'pk_test_51SRWd5JZsrXY12RF2nT3Sh28W2tVqofwE71I5CpsJiYjtX0bX3bZcG71HTiXnxVbudAfMyQiqRrq9WgRidVFweXW00S7mbxjflR';

  /// Loads the `.env` file if it hasn't been read already. Falls back to
  /// `.env.example` for local development without custom overrides.
  static Future<void> load() async {
    if (dotenv.isInitialized) {
      return;
    }

    try {
      await dotenv.load(fileName: '.env');
    } catch (error, stackTrace) {
      debugPrint('Failed to load .env file: $error');
      FlutterError.presentError(
        FlutterErrorDetails(exception: error, stack: stackTrace),
      );
    }
  }

  static String get apiBaseUrl => _string('API_BASE_URL', _defaultApiBaseUrl);

  static Duration get apiConnectionTimeout =>
      _duration('API_TIMEOUT', _defaultConnectionTimeout);

  static Duration get apiReceiveTimeout =>
      _duration('API_RECEIVE_TIMEOUT', _defaultReceiveTimeout);

  static String get stripePublishableKey =>
      _string('STRIPE_PUBLISHABLE_KEY', _defaultStripePublishableKey);

  static bool get debugModeEnabled => _bool('DEBUG_MODE', false);

  static String get logLevel => _string('LOG_LEVEL', 'info');

  static String _string(String key, String fallback) {
    final value = dotenv.maybeGet(key);
    if (value == null || value.trim().isEmpty) {
      return fallback;
    }
    return value.trim();
  }

  static Duration _duration(String key, Duration fallback) {
    final value = dotenv.maybeGet(key);
    if (value == null) {
      return fallback;
    }

    final parsed = int.tryParse(value);
    if (parsed == null) {
      return fallback;
    }

    return Duration(milliseconds: parsed);
  }

  static bool _bool(String key, bool fallback) {
    final value = dotenv.maybeGet(key);
    if (value == null) {
      return fallback;
    }

    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') {
      return true;
    }
    if (normalized == 'false' || normalized == '0') {
      return false;
    }
    return fallback;
  }
}

