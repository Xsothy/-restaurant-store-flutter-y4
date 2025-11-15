import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_constants.dart';
import '../models/cart.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../utils/routes.dart';
import '../widgets/cached_app_image.dart';
import '../widgets/cart_icon_button.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _orderType = 'DELIVERY';
  String _paymentMethod = 'cash_on_delivery';
  bool _prefilled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefilled) return;
    final auth = context.read<AuthProvider>();
    if (auth.user != null) {
      final user = auth.user!;
      _nameController.text = user.fullName;
      _phoneController.text = user.phone ?? '';
      _addressController.text = user.address?.fullAddress ?? user.address?.street ?? '';
    }
    _prefilled = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        actions: [
          CartIconButton(onPressed: () => NavigationHelper.navigateToCart(context)),
        ],
      ),
      body: Consumer3<AuthProvider, CartProvider, OrderProvider>(
        builder: (context, _, cartProvider, orderProvider, child) {
          final cart = cartProvider.cart;
          if (cartProvider.isLoading && cart == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (cart == null || cart.items.isEmpty) {
            return _buildEmptyCartState(context);
          }

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => cartProvider.loadCartFromServer(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Contact information'),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: _nameController,
                            hint: 'Full name',
                            prefixIcon: const Icon(Icons.person_outline),
                            validator: (value) {
                              if ((value ?? '').trim().isEmpty) {
                                return AppConstants.nameRequired;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: _phoneController,
                            hint: 'Phone number',
                            keyboardType: TextInputType.phone,
                            prefixIcon: const Icon(Icons.phone_outlined),
                            validator: (value) {
                              final text = (value ?? '').trim();
                              if (text.isEmpty) {
                                return AppConstants.phoneRequired;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          _buildSectionTitle('Delivery details'),
                          const SizedBox(height: 12),
                          _buildOrderTypeSelector(),
                          const SizedBox(height: 12),
                          if (_orderType == 'DELIVERY')
                            CustomTextField(
                              controller: _addressController,
                              hint: 'Delivery address',
                              maxLines: 3,
                              prefixIcon: const Icon(Icons.location_on_outlined),
                              validator: (value) {
                                if (_orderType == 'DELIVERY' && (value ?? '').trim().isEmpty) {
                                  return AppConstants.addressRequired;
                                }
                                return null;
                              },
                            ),
                          if (_orderType == 'DELIVERY') const SizedBox(height: 12),
                          CustomTextField(
                            controller: _notesController,
                            hint: 'Add delivery notes (optional)',
                            maxLines: 3,
                            prefixIcon: const Icon(Icons.notes_outlined),
                          ),
                          const SizedBox(height: 24),
                          _buildSectionTitle('Payment'),
                          const SizedBox(height: 12),
                          _buildPaymentOptions(),
                          const SizedBox(height: 24),
                          _buildSectionTitle('Order summary'),
                          const SizedBox(height: 12),
                          ...cart.items.map(_buildOrderItemCard),
                          const SizedBox(height: 12),
                          _buildPriceRow('Subtotal', cart.formattedSubtotal),
                          const SizedBox(height: 8),
                          _buildPriceRow('Tax', cart.formattedVat),
                          const SizedBox(height: 8),
                          _buildPriceRow('Delivery fee', cart.formattedDeliveryFee),
                          const Divider(height: 24),
                          _buildPriceRow(
                            'Total',
                            cart.formattedTotal,
                            highlight: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: CustomButton(
                    text: 'Place Order • ${cart.formattedTotal}',
                    onPressed: orderProvider.isCreatingOrder
                        ? null
                        : () => _handlePlaceOrder(cartProvider, orderProvider),
                    width: double.infinity,
                    isLoading: orderProvider.isCreatingOrder,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  Widget _buildOrderTypeSelector() {
    final isDelivery = _orderType == 'DELIVERY';
    return Row(
      children: [
        Expanded(
          child: ChoiceChip(
            label: const Text('Delivery'),
            selected: isDelivery,
            onSelected: (_) => setState(() => _orderType = 'DELIVERY'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ChoiceChip(
            label: const Text('Pickup'),
            selected: !isDelivery,
            onSelected: (_) => setState(() => _orderType = 'PICKUP'),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOptions() {
    final options = [
      {
        'id': 'cash_on_delivery',
        'label': 'Cash on delivery',
        'icon': Icons.payments_outlined,
      },
      {
        'id': 'aba',
        'label': 'ABA Pay',
        'icon': Icons.account_balance_wallet_outlined,
      },
      {
        'id': 'card',
        'label': 'Card',
        'icon': Icons.credit_card,
      },
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: options.map((option) {
        final optionId = option['id'] as String;
        final selected = _paymentMethod == optionId;
        return FilterChip(
          avatar: Icon(option['icon'] as IconData),
          label: Text(option['label'] as String),
          selected: selected,
          onSelected: (_) => setState(() => _paymentMethod = optionId),
        );
      }).toList(),
    );
  }

  Widget _buildOrderItemCard(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          CachedAppImage(
            imageUrl: item.productImageUrl,
            width: 60,
            height: 60,
            borderRadius: 10,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${item.quantity}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6)),
                ),
              ],
            ),
          ),
          Text(
            item.formattedSubtotal,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool highlight = false}) {
    final textStyle = highlight
        ? Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)
        : Theme.of(context).textTheme.bodyLarge;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        Text(value, style: textStyle),
      ],
    );
  }

  Widget _buildEmptyCartState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Your cart is empty',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Add some delicious meals before checking out.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Browse menu',
              onPressed: () => NavigationHelper.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePlaceOrder(CartProvider cartProvider, OrderProvider orderProvider) async {
    final cart = cartProvider.cart;
    if (cart == null || cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty.')),
      );
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final order = await orderProvider.createOrder(
      items: cart.items,
      orderType: _orderType,
      deliveryAddress: _orderType == 'DELIVERY' ? _addressController.text.trim() : null,
      phoneNumber: _phoneController.text.trim(),
      specialInstructions: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    if (!mounted) return;

    if (order != null) {
      await cartProvider.loadCartFromServer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppConstants.orderPlacedSuccess),
          backgroundColor: Colors.green,
        ),
      );
      NavigationHelper.navigateToOrderTracking(context, order.id.toString());
    } else {
      final message = orderProvider.errorMessage ?? AppConstants.generalError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}
