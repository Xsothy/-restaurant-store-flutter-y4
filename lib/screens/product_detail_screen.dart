import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../utils/routes.dart';
import '../widgets/custom_button.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProductDetails(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => NavigationHelper.navigateToCart(context),
          ),
        ],
      ),
      body: Consumer2<ProductProvider, CartProvider>(
        builder: (context, productProvider, cartProvider, child) {
          if (productProvider.isLoading && productProvider.selectedProduct == null) {
            return const Center(child: CircularProgressIndicator());
          }

          Product? product = productProvider.selectedProduct;
          product ??= _findProductFallback(productProvider.products);

          if (product == null) {
            if (productProvider.errorMessage != null) {
              return _buildErrorState(productProvider.errorMessage!);
            }
            return _buildErrorState('Product not found.');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                  ),
                  child: Icon(
                    Icons.fastfood,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  product.category.name,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6)),
                ),
                const SizedBox(height: 16),
                Text(
                  product.formattedPrice,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  product.description.isNotEmpty
                      ? product.description
                      : 'No description available for this item.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                _buildQuantitySelector(),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Add to cart',
                  icon: const Icon(Icons.add_shopping_cart),
                  onPressed: () async {
                    if (product == null) {
                      throw Error();
                    }
                    final success = await cartProvider.addToCart(product, quantity: _quantity);
                    if (!mounted) return;
                    final message = success
                        ? '${product.name} added to cart'
                        : cartProvider.errorMessage ?? 'Unable to add item to cart';
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor: success
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.error,
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        Text(
          'Quantity',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        IconButton(
          onPressed: _quantity > 1
              ? () {
                  setState(() {
                    _quantity--;
                  });
                }
              : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text(
          '$_quantity',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _quantity++;
            });
          },
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fastfood_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Back to menu',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Product? _findProductFallback(List<Product> products) {
    try {
      return products.firstWhere((item) => item.id == widget.productId);
    } catch (_) {
      return null;
    }
  }
}
