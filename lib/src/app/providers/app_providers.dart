import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'package:restaurant_store_flutter/src/features/auth/providers/auth_provider.dart';
import 'package:restaurant_store_flutter/src/features/cart/providers/cart_provider.dart';
import 'package:restaurant_store_flutter/src/features/catalog/providers/product_provider.dart';
import 'package:restaurant_store_flutter/src/features/orders/providers/order_provider.dart';

class AppProviders {
  const AppProviders._();

  static List<SingleChildWidget> build() {
    return [
      ChangeNotifierProvider<AuthProvider>(create: _createAuthProvider),
      ChangeNotifierProvider<CartProvider>(create: _createCartProvider),
      ChangeNotifierProvider<ProductProvider>(create: _createProductProvider),
      ChangeNotifierProvider<OrderProvider>(create: _createOrderProvider),
    ];
  }

  static AuthProvider _createAuthProvider(BuildContext _) => AuthProvider();
  static CartProvider _createCartProvider(BuildContext _) => CartProvider();
  static ProductProvider _createProductProvider(BuildContext _) => ProductProvider();
  static OrderProvider _createOrderProvider(BuildContext _) => OrderProvider();
}
