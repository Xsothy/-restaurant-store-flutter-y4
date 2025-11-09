// This is a basic Flutter widget test file.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:restaurant_store_flutter/main.dart';
import 'package:restaurant_store_flutter/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Hive.initFlutter();
    await StorageService.init();
  });

  testWidgets('Restaurant Store App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RestaurantStoreApp());

    // Verify that the splash screen is displayed
    expect(find.text('FoodRush'), findsOneWidget);
    expect(find.text('Delicious Food, Delivered Fast'), findsOneWidget);
  });
}
