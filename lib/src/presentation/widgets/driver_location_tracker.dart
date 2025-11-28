import 'package:flutter/material.dart';
import 'package:restaurant_store_flutter/src/data/models/order.dart';

class DriverLocationTracker extends StatelessWidget {
  final DeliveryInfo delivery;
  final String? deliveryAddress;

  const DriverLocationTracker({
    super.key,
    required this.delivery,
    this.deliveryAddress,
  });

  @override
  Widget build(BuildContext context) {
    final hasLocation = delivery.latitude != null && delivery.longitude != null;

    if (!hasLocation) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.my_location,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Live Location Tracking',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (delivery.currentLocation != null) ...[
            _buildLocationRow(
              context,
              icon: Icons.location_on,
              label: 'Current Area',
              value: delivery.currentLocation!,
            ),
            const SizedBox(height: 8),
          ],
          _buildLocationRow(
            context,
            icon: Icons.gps_fixed,
            label: 'GPS Coordinates',
            value:
                '${delivery.latitude!.toStringAsFixed(6)}, ${delivery.longitude!.toStringAsFixed(6)}',
            isSecondary: true,
          ),
          if (deliveryAddress != null) ...[
            const SizedBox(height: 12),
            Divider(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              height: 1,
            ),
            const SizedBox(height: 12),
            _buildLocationRow(
              context,
              icon: Icons.flag,
              label: 'Delivery Destination',
              value: deliveryAddress!,
            ),
          ],
          const SizedBox(height: 12),
          _buildMapButton(context),
        ],
      ),
    );
  }

  Widget _buildLocationRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool isSecondary = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: isSecondary
              ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
              : Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: isSecondary ? FontWeight.normal : FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapButton(BuildContext context) {
    final bool hasDestination = deliveryAddress != null && deliveryAddress!.isNotEmpty;
    
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          _openInMaps(context);
        },
        icon: Icon(hasDestination ? Icons.directions : Icons.map, size: 18),
        label: Text(hasDestination ? 'View Route on Map' : 'View on Map'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  void _openInMaps(BuildContext context) {
    final lat = delivery.latitude;
    final lng = delivery.longitude;
    if (lat == null || lng == null) return;

    // If we have a delivery address, show it as the destination with driver as origin
    // Otherwise just show driver's current location
    final String url;
    final String message;
    
    if (deliveryAddress != null && deliveryAddress!.isNotEmpty) {
      // OpenStreetMap directions: from driver location to delivery address
      final encodedAddress = Uri.encodeComponent(deliveryAddress!);
      url = 'https://www.openstreetmap.org/directions?engine=fossgis_osrm_car&route=$lat%2C$lng%3B$encodedAddress';
      message = 'View route from driver to delivery address';
    } else {
      // Just show driver location on OpenStreetMap
      url = 'https://www.openstreetmap.org/?mlat=$lat&mlon=$lng#map=15/$lat/$lng';
      message = 'View driver location on map';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$message\n$url'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
