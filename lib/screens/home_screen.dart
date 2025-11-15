import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_constants.dart';
import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../utils/routes.dart';
import '../widgets/cached_app_image.dart';
import '../widgets/cart_icon_button.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = context.read<ProductProvider>();
      productProvider.refresh();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu_outlined), label: 'Menu'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final actions = <Widget>[
      CartIconButton(onPressed: () => NavigationHelper.navigateToCart(context)),
    ];

    switch (_selectedIndex) {
      case 0:
        return AppBar(
          titleSpacing: 16,
          title: _buildGreeting(),
          actions: actions,
          bottom: _buildSearchBar(),
        );
      case 1:
        return AppBar(
          title: const Text('Menu'),
          actions: actions,
          bottom: _buildSearchBar(),
        );
      case 2:
        return AppBar(
          title: const Text('Orders'),
          actions: actions,
        );
      case 3:
      default:
        return AppBar(
          title: const Text('Profile'),
          actions: actions,
        );
    }
  }

  PreferredSizeWidget _buildSearchBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(72),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SearchTextField(
          controller: _searchController,
          hint: 'Search for dishes or restaurants',
          onChanged: (query) => context.read<ProductProvider>().searchProducts(query),
          onClear: () => context.read<ProductProvider>().searchProducts(''),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good ${_getTimeOfDay()}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7)),
            ),
            const SizedBox(height: 4),
            Text(
              authProvider.userDisplayName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildMenuTab();
      case 2:
        return _buildOrdersTab();
      case 3:
      default:
        return _buildProfileTab();
    }
  }

  Widget _buildHomeTab() {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        return RefreshIndicator(
          onRefresh: () => provider.refresh(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            children: [
              _buildCategorySection(provider),
              const SizedBox(height: 24),
              Text(
                'Recommended for you',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (provider.isLoadingProducts && provider.products.isEmpty)
                const Center(child: CircularProgressIndicator()),
              if (!provider.isLoadingProducts && provider.filteredProducts.isEmpty)
                _buildEmptyProductsState(),
              ...provider.filteredProducts.map((product) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildProductListCard(product),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuTab() {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        final products = provider.filteredProducts;
        return RefreshIndicator(
          onRefresh: () => provider.refresh(),
          child: products.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  children: [
                    _buildCategorySection(provider),
                    const SizedBox(height: 24),
                    if (provider.isLoadingProducts)
                      const Center(child: CircularProgressIndicator())
                    else
                      _buildEmptyProductsState(),
                  ],
                )
              : GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return _buildProductGridCard(products[index]);
                  },
                ),
        );
      },
    );
  }

  Widget _buildCategorySection(ProductProvider provider) {
    if (provider.isLoadingCategories && provider.categories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.categories.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categories',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            'No categories available yet.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6)),
          ),
        ],
      );
    }

    final categories = provider.categories;
    final selectedId = provider.selectedCategory?.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length + 1,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == 0) {
                final isSelected = selectedId == null;
                return ChoiceChip(
                  label: const Text('All'),
                  selected: isSelected,
                  onSelected: (_) => provider.filterByCategory(null),
                );
              }

              final category = categories[index - 1];
              final isSelected = selectedId == category.id;
              return ChoiceChip(
                label: Text(category.name),
                selected: isSelected,
                onSelected: (_) => provider.filterByCategory(category),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyProductsState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 48,
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'No menu items found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Try a different search or category.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }

  Widget _buildProductListCard(Product product) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => NavigationHelper.navigateToProductDetail(context, product.id),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CachedAppImage(
                imageUrl: product.imageUrl,
                height: 80,
                width: 80,
                borderRadius: 12,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.category.name,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.formattedPrice,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_shopping_cart),
                onPressed: () => _handleAddToCart(product),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductGridCard(Product product) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => NavigationHelper.navigateToProductDetail(context, product.id),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CachedAppImage(
                imageUrl: product.imageUrl,
                height: 120,
                width: double.infinity,
                borderRadius: 12,
              ),
              const SizedBox(height: 12),
              Text(
                product.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                product.category.name,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6)),
              ),
              const Spacer(),
              Row(
                children: [
                  Text(
                    product.formattedPrice,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add_shopping_cart),
                    onPressed: () => _handleAddToCart(product),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersTab() {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(
                Icons.receipt_long,
                size: 64,
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No orders yet',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Browse the menu and place your first order.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6)),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Explore Menu',
                icon: const Icon(Icons.restaurant_menu_outlined),
                onPressed: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTab() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return ListView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          children: [
            _buildProfileHeader(authProvider),
            const SizedBox(height: 24),
            _buildProfileOptions(),
          ],
        );
      },
    );
  }

  Widget _buildProfileHeader(AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            alignment: Alignment.center,
            child: Text(
              authProvider.userInitials,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authProvider.userDisplayName,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  authProvider.user?.email ?? '',
                  style:
                      Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.9)),
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Edit Profile',
                  onPressed: () => _showNotImplementedDialog('Edit Profile'),
                  isOutlined: true,
                  textColor: Colors.white,
                  height: 36,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions() {
    final options = [
      {
        'icon': Icons.receipt_long_outlined,
        'title': 'Order History',
        'subtitle': 'View your previous purchases',
        'action': () => NavigationHelper.navigateToOrderHistory(context),
      },
      {
        'icon': Icons.support_agent_outlined,
        'title': 'Support',
        'subtitle': 'Need help with an order?',
        'action': () => _showNotImplementedDialog('Support'),
      },
      {
        'icon': Icons.settings_outlined,
        'title': 'Settings',
        'subtitle': 'App preferences',
        'action': () => _showNotImplementedDialog('Settings'),
      },
      {
        'icon': Icons.logout_outlined,
        'title': 'Logout',
        'subtitle': 'Sign out of your account',
        'action': _handleLogout,
      },
    ];

    return Column(
      children: options.map((option) {
        return ListTile(
          leading: Icon(option['icon'] as IconData, color: Theme.of(context).colorScheme.primary),
          title: Text(option['title'] as String),
          subtitle: Text(option['subtitle'] as String),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => (option['action'] as VoidCallback)(),
        );
      }).toList(),
    );
  }

  Future<void> _handleAddToCart(Product product) async {
    final cartProvider = context.read<CartProvider>();
    final success = await cartProvider.addToCart(product);
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
  }

  void _handleLogout() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showNotImplementedDialog(String feature) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: const Text('This feature will be available soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}
