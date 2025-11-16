import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import 'package:restaurant_store_flutter/src/core/constants/app_constants.dart';
import 'package:restaurant_store_flutter/src/core/routing/app_router.dart';
import 'package:restaurant_store_flutter/src/core/theme/app_theme.dart';
import 'package:restaurant_store_flutter/src/app/providers/app_providers.dart';

class RestaurantStoreApp extends StatelessWidget {
  const RestaurantStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.build(),
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          return MediaQuery(
            data: mediaQuery.copyWith(
              textScaleFactor: mediaQuery.textScaleFactor.clamp(0.8, 1.2),
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}
