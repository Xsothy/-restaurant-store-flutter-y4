import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants/app_constants.dart';
import '../models/order.dart';
import '../providers/order_provider.dart';
import '../utils/routes.dart';
import '../widgets/cached_app_image.dart';
import '../widgets/cart_icon_button.dart';
import '../widgets/custom_button.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final id = int.tryParse(widget.orderId);
    if (id == null) return;
    final provider = context.read<OrderProvider>();
    await Future.wait([
      provider.loadOrderDetails(id),
      provider.loadDeliveryInfo(id),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Tracking'),
        actions: [
          CartIconButton(onPressed: () => NavigationHelper.navigateToCart(context)),
        ],
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          final order = orderProvider.selectedOrder;
          if ((orderProvider.isLoading || orderProvider.isLoadingOrders) && order == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (order == null) {
            return _buildEmptyState(orderProvider.errorMessage);
          }

          final delivery = orderProvider.deliveryInfo;

          return RefreshIndicator(
            onRefresh: _loadData,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              children: [
                _buildOrderHeader(order),
                const SizedBox(height: 16),
                _buildTimeline(order),
                const SizedBox(height: 24),
                if (delivery != null || order.deliveryDriverName != null)
                  _buildDriverCard(order, delivery),
                if (delivery != null || order.deliveryAddress != null) ...[
                  const SizedBox(height: 16),
                  _buildDeliveryCard(order, delivery),
                ],
                const SizedBox(height: 16),
                _buildItemsCard(order.items),
                const SizedBox(height: 16),
                _buildPaymentCard(order),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Refresh Status',
                  onPressed: orderProvider.isLoading ? null : () => _loadData(),
                  isLoading: orderProvider.isLoading,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderHeader(Order order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Placed on ${_formatDateTime(order.createdAt)}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6)),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(order.status),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.attach_money, size: 20),
              const SizedBox(width: 8),
              Text(
                order.formattedTotal,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              const Icon(Icons.payments_outlined, size: 20),
              const SizedBox(width: 8),
              Text(order.paymentStatus.name.toUpperCase()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(Order order) {
    final steps = [
      _OrderStep(OrderStatus.pending, 'Order placed', 'We received your order'),
      _OrderStep(OrderStatus.confirmed, 'Confirmed', 'Restaurant confirmed the order'),
      _OrderStep(OrderStatus.preparing, 'Preparing', 'Chef is preparing your food'),
      _OrderStep(OrderStatus.ready, 'Ready', 'Order ready for pickup/delivery'),
      _OrderStep(OrderStatus.outForDelivery, 'On the way', 'Rider is on the move'),
      _OrderStep(OrderStatus.delivered, 'Delivered', 'Enjoy your meal'),
    ];

    final rawIndex = steps.indexWhere((step) => step.status == order.status);
    final currentIndex = rawIndex == -1 ? 0 : rawIndex;
    final isCancelled = order.status == OrderStatus.cancelled;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isCancelled ? 'Order cancelled' : 'Order progress',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isDelivered = order.status == OrderStatus.delivered;
            final isCompleted = isDelivered ? index <= currentIndex : index < currentIndex;
            final isActive = index == currentIndex && !isDelivered;
            return _TimelineTile(
              title: step.title,
              subtitle: step.description,
              isCompleted: isCompleted,
              isActive: isActive,
              isCancelled: isCancelled && index == currentIndex,
            );
          }),
          if (isCancelled)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'This order was cancelled.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(Order order, DeliveryInfo? delivery) {
    final driverName = delivery?.driverName ?? order.deliveryDriverName;
    final driverPhone = delivery?.driverPhone ?? order.deliveryDriverPhone;
    final vehicle = delivery?.vehicleInfo;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery partner',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Icon(Icons.delivery_dining, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driverName ?? 'Driver assigned soon',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (driverPhone != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        driverPhone,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7)),
                      ),
                    ],
                    if (vehicle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        vehicle,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (delivery?.currentLocation != null) ...[
            const SizedBox(height: 12),
            Text(
              'Current location: ${delivery!.currentLocation}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          if (delivery?.estimatedArrivalTime != null) ...[
            const SizedBox(height: 4),
            Text(
              'ETA: ${_formatDateTime(delivery!.estimatedArrivalTime)}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(Order order, DeliveryInfo? delivery) {
    final address = order.deliveryAddress ?? delivery?.deliveryNotes ?? 'Pickup at restaurant';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery details',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(address, style: Theme.of(context).textTheme.bodyLarge),
                    if (order.phoneNumber != null) ...[
                      const SizedBox(height: 8),
                      Text('Contact: ${order.phoneNumber}'),
                    ],
                    if (order.specialInstructions != null && order.specialInstructions!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('Notes: ${order.specialInstructions}'),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard(List<OrderItem> items) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Items (${items.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  CachedAppImage(
                    imageUrl: item.productImageUrl,
                    width: 56,
                    height: 56,
                    borderRadius: 12,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text('Qty: ${item.quantity}'),
                      ],
                    ),
                  ),
                  Text(item.formattedSubtotal),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Order order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment summary',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _buildPaymentRow('Payment method', order.paymentMethod.name),
          _buildPaymentRow('Payment status', order.paymentStatus.name),
          _buildPaymentRow('Order type', order.orderType),
          _buildPaymentRow('Total paid', order.formattedTotal, isHighlighted: true),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value, {bool isHighlighted = false}) {
    final style = isHighlighted
        ? Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)
        : Theme.of(context).textTheme.bodyLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: style),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 72,
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load order',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error ?? 'Please pull to refresh or try again later.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6)),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Back to orders',
              onPressed: () => NavigationHelper.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return '--';
    return DateFormat('MMM d, yyyy • hh:mm a').format(date.toLocal());
  }
}

class _OrderStep {
  final OrderStatus status;
  final String title;
  final String description;

  const _OrderStep(this.status, this.title, this.description);
}

class _TimelineTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isActive;
  final bool isCancelled;

  const _TimelineTile({
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.isActive,
    required this.isCancelled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isCancelled
        ? theme.colorScheme.error
        : isCompleted
            ? theme.colorScheme.primary
            : theme.colorScheme.outline;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isActive || isCompleted ? color : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color, width: 2),
              ),
            ),
            Container(
              width: 2,
              height: 50,
              color: isCompleted ? color : theme.colorScheme.outline.withOpacity(0.3),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isCancelled ? theme.colorScheme.error : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
