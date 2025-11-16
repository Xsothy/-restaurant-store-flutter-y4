import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'package:restaurant_store_flutter/src/core/constants/app_constants.dart';
import 'package:restaurant_store_flutter/src/core/routing/app_router.dart';
import 'package:restaurant_store_flutter/src/core/utils/snackbar_helper.dart';
import 'package:restaurant_store_flutter/src/data/services/api_service.dart';
import 'package:restaurant_store_flutter/src/presentation/widgets/custom_button.dart';

class StripePaymentScreen extends StatefulWidget {
  final int orderId;

  const StripePaymentScreen({super.key, required this.orderId});

  @override
  State<StripePaymentScreen> createState() => _StripePaymentScreenState();
}

class _StripePaymentScreenState extends State<StripePaymentScreen> {
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Card payment'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.payment, size: 48),
              const SizedBox(height: 16),
              Text(
                'Card payments via Stripe are only available on mobile builds.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Back to order',
                width: double.infinity,
                onPressed: () => NavigationHelper.pop(context),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Card payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your card details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            CardField(
              onCardChanged: (details) {},
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 8),
            ],
            const Spacer(),
            CustomButton(
              text: 'Pay now',
              width: double.infinity,
              isLoading: _isProcessing,
              onPressed: _isProcessing ? null : _handlePay,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePay() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final clientSecret =
          await ApiService.createPaymentIntent(widget.orderId);

      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: PaymentMethodParams.card(
          paymentMethodData: const PaymentMethodData(),
        ),
      );

      if (!mounted) return;

      SnackbarHelper.showTopToast(
        context,
        'Payment successful',
      );
      NavigationHelper.navigateToOrderTracking(
        context,
        widget.orderId.toString(),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
