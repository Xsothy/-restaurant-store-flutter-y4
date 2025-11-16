import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:restaurant_store_flutter/src/app/app.dart';
import 'package:restaurant_store_flutter/src/core/config/app_environment.dart';
import 'package:restaurant_store_flutter/src/data/services/api_service.dart';
import 'package:restaurant_store_flutter/src/data/services/storage_service.dart';

class AppBootstrapper {
  const AppBootstrapper();

  Future<void> run() async {
    WidgetsFlutterBinding.ensureInitialized();

    await AppEnvironment.load();
    await Hive.initFlutter();
    await StorageService.init();
    final storedBaseUrl = StorageService.getApiBaseUrl();
    ApiService.init(baseUrl: storedBaseUrl ?? AppEnvironment.apiBaseUrl);

    await _initializeStripe();
    await _configurePreferredOrientations();
    _configureSystemUiOverlay();

    runApp(const RestaurantStoreApp());
  }

  Future<void> _initializeStripe() async {
    if (kIsWeb) {
      return;
    }

    try {
      Stripe.publishableKey = AppEnvironment.stripePublishableKey;
      await Stripe.instance.applySettings();
    } catch (error, stackTrace) {
      debugPrint('Stripe initialization failed: $error');
      FlutterError.presentError(FlutterErrorDetails(exception: error, stack: stackTrace));
    }
  }

  Future<void> _configurePreferredOrientations() {
    return SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _configureSystemUiOverlay() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }
}

Future<void> bootstrap() => const AppBootstrapper().run();
