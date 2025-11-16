import 'package:flutter/material.dart';

import 'package:restaurant_store_flutter/src/core/constants/app_constants.dart';

class MenuScreen extends StatelessWidget {
  final String? categoryId;

  const MenuScreen({super.key, this.categoryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.restaurant_menu,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Menu Screen',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (categoryId != null) ...[
              const SizedBox(height: 8),
              Text(
                'Category ID: $categoryId',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'Full menu implementation coming soon!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
