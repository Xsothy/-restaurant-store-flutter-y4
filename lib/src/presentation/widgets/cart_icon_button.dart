import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:restaurant_store_flutter/src/features/cart/providers/cart_provider.dart';

class CartIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? iconColor;

  const CartIconButton({
    super.key,
    this.onPressed,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final count = cartProvider.itemCount;
        final showBadge = count > 0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              color: iconColor,
              onPressed: onPressed,
              tooltip: 'Cart',
            ),
            if (showBadge)
              Positioned(
                right: 4,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    count > 9 ? '9+' : count.toString(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onError,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
