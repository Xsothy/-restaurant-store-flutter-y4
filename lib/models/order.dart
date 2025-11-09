import 'package:json_annotation/json_annotation.dart';
import 'user.dart';
import 'cart.dart';

part 'order.g.dart';

@JsonSerializable()
class Order {
  final String id;
  final User user;
  final List<OrderItem> items;
  final OrderStatus status;
  final DeliveryInfo deliveryInfo;
  final PaymentInfo paymentInfo;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double total;
  final String? specialInstructions;
  final DateTime createdAt;
  final DateTime? estimatedDeliveryTime;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final List<OrderStatusUpdate> statusHistory;

  Order({
    required this.id,
    required this.user,
    required this.items,
    required this.status,
    required this.deliveryInfo,
    required this.paymentInfo,
    required this.subtotal,
    required this.tax,
    required this.deliveryFee,
    required this.total,
    this.specialInstructions,
    required this.createdAt,
    this.estimatedDeliveryTime,
    this.deliveredAt,
    this.cancelledAt,
    this.cancellationReason,
    required this.statusHistory,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);

  String get formattedTotal => '\$${total.toStringAsFixed(2)}';
  String get formattedSubtotal => '\$${subtotal.toStringAsFixed(2)}';
  String get formattedTax => '\$${tax.toStringAsFixed(2)}';
  String get formattedDeliveryFee => deliveryFee == 0.0 ? 'FREE' : '\$${deliveryFee.toStringAsFixed(2)}';
  
  String get statusDisplay {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready for Pickup';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
  
  bool get isActive => ![
    OrderStatus.delivered,
    OrderStatus.cancelled,
  ].contains(status);
  
  Duration? get estimatedPreparationTime {
    if (estimatedDeliveryTime == null) return null;
    return estimatedDeliveryTime!.difference(DateTime.now());
  }
}

@JsonSerializable()
class OrderItem {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final List<String> customizations;
  final String? specialInstructions;

  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.customizations,
    this.specialInstructions,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemToJson(this);

  double get subtotal => price * quantity;
  String get formattedSubtotal => '\$${subtotal.toStringAsFixed(2)}';
}

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  outForDelivery,
  delivered,
  cancelled,
}

@JsonSerializable()
class DeliveryInfo {
  final Address address;
  final String? driverName;
  final String? driverPhone;
  final String? driverPhoto;
  final String? vehicleInfo;
  final double? driverLatitude;
  final double? driverLongitude;
  final DateTime? estimatedDeliveryTime;
  final String? trackingUrl;

  DeliveryInfo({
    required this.address,
    this.driverName,
    this.driverPhone,
    this.driverPhoto,
    this.vehicleInfo,
    this.driverLatitude,
    this.driverLongitude,
    this.estimatedDeliveryTime,
    this.trackingUrl,
  });

  factory DeliveryInfo.fromJson(Map<String, dynamic> json) => _$DeliveryInfoFromJson(json);
  Map<String, dynamic> toJson() => _$DeliveryInfoToJson(this);
}

@JsonSerializable()
class PaymentInfo {
  final PaymentMethod method;
  final String? lastFourDigits;
  final String? transactionId;
  final DateTime? paidAt;
  final PaymentStatus status;

  PaymentInfo({
    required this.method,
    this.lastFourDigits,
    this.transactionId,
    this.paidAt,
    required this.status,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) => _$PaymentInfoFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentInfoToJson(this);

  String get methodDisplay {
    switch (method) {
      case PaymentMethod.card:
        return 'Credit Card';
      case PaymentMethod.cash:
        return 'Cash on Delivery';
      case PaymentMethod.digitalWallet:
        return 'Digital Wallet';
    }
  }
}

enum PaymentMethod {
  card,
  cash,
  digitalWallet,
}

enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded,
}

@JsonSerializable()
class OrderStatusUpdate {
  final OrderStatus status;
  final DateTime timestamp;
  final String? note;
  final String? updatedBy;

  OrderStatusUpdate({
    required this.status,
    required this.timestamp,
    this.note,
    this.updatedBy,
  });

  factory OrderStatusUpdate.fromJson(Map<String, dynamic> json) => _$OrderStatusUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$OrderStatusUpdateToJson(this);
}

@JsonSerializable()
class CreateOrderRequest {
  final List<CreateOrderItemRequest> items;
  final Address deliveryAddress;
  final PaymentMethod paymentMethod;
  final String? specialInstructions;
  final String? couponCode;

  CreateOrderRequest({
    required this.items,
    required this.deliveryAddress,
    required this.paymentMethod,
    this.specialInstructions,
    this.couponCode,
  });

  factory CreateOrderRequest.fromJson(Map<String, dynamic> json) => _$CreateOrderRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateOrderRequestToJson(this);
}

@JsonSerializable()
class CreateOrderItemRequest {
  final int productId;
  final int quantity;
  final List<String> customizations;
  final String? specialInstructions;

  CreateOrderItemRequest({
    required this.productId,
    required this.quantity,
    required this.customizations,
    this.specialInstructions,
  });

  factory CreateOrderItemRequest.fromJson(Map<String, dynamic> json) => _$CreateOrderItemRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateOrderItemRequestToJson(this);
}

@JsonSerializable()
class OrderResponse {
  final Order order;
  final String message;

  OrderResponse({
    required this.order,
    required this.message,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) => _$OrderResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OrderResponseToJson(this);
}
