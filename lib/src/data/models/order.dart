import 'package:intl/intl.dart';

String _formatOrderCurrency(num value) {
  final formatter = NumberFormat('#,###', 'en_US');
  final rounded = value is int ? value : value.round();
  return '${formatter.format(rounded)} KHR';
}

class Order {
  final int id;
  final int customerId;
  final String customerName;
  final OrderStatus status;
  final double totalPrice;
  final String orderType;
  final String? deliveryAddress;
  final String? phoneNumber;
  final String? specialInstructions;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? estimatedDeliveryTime;
  final List<OrderItem> items;
  final PaymentStatus paymentStatus;
  final PaymentMethod paymentMethod;
  final DateTime? paymentPaidAt;
  final String? paymentTransactionId;
  final String? deliveryStatus;
  final String? deliveryDriverName;
  final String? deliveryDriverPhone;
  final DateTime? deliveryEstimatedArrivalTime;
  final DateTime? deliveryActualDeliveryTime;

  Order({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.status,
    required this.totalPrice,
    required this.orderType,
    required this.items,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.createdAt,
    this.deliveryAddress,
    this.phoneNumber,
    this.specialInstructions,
    this.updatedAt,
    this.estimatedDeliveryTime,
    this.paymentPaidAt,
    this.paymentTransactionId,
    this.deliveryStatus,
    this.deliveryDriverName,
    this.deliveryDriverPhone,
    this.deliveryEstimatedArrivalTime,
    this.deliveryActualDeliveryTime,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      customerId: json['customerId'] is int
          ? json['customerId'] as int
          : int.tryParse('${json['customerId']}') ?? 0,
      customerName: json['customerName']?.toString() ?? 'Customer',
      status: _parseOrderStatus(json['status']),
      totalPrice: json['totalPrice'] is num
          ? (json['totalPrice'] as num).toDouble()
          : double.tryParse('${json['totalPrice']}') ?? 0,
      orderType: json['orderType']?.toString() ?? 'DELIVERY',
      deliveryAddress: json['deliveryAddress']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      specialInstructions: json['specialInstructions']?.toString(),
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updatedAt']),
      estimatedDeliveryTime: _parseDate(json['estimatedDeliveryTime']),
      items: (json['orderItems'] as List?)
              ?.map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          const [],
      paymentStatus: _parsePaymentStatus(json['paymentStatus']),
      paymentMethod: _parsePaymentMethod(json['paymentMethod']),
      paymentPaidAt: _parseDate(json['paymentPaidAt']),
      paymentTransactionId: json['paymentTransactionId']?.toString(),
      deliveryStatus: json['deliveryStatus']?.toString(),
      deliveryDriverName: json['deliveryDriverName']?.toString(),
      deliveryDriverPhone: json['deliveryDriverPhone']?.toString(),
      deliveryEstimatedArrivalTime: _parseDate(json['deliveryEstimatedArrivalTime']),
      deliveryActualDeliveryTime: _parseDate(json['deliveryActualDeliveryTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'status': status.name.toUpperCase(),
      'totalPrice': totalPrice,
      'orderType': orderType,
      'deliveryAddress': deliveryAddress,
      'phoneNumber': phoneNumber,
      'specialInstructions': specialInstructions,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'estimatedDeliveryTime': estimatedDeliveryTime?.toIso8601String(),
      'orderItems': items.map((item) => item.toJson()).toList(),
      'paymentStatus': paymentStatus.name.toUpperCase(),
      'paymentMethod': paymentMethod.name.toUpperCase(),
      'paymentPaidAt': paymentPaidAt?.toIso8601String(),
      'paymentTransactionId': paymentTransactionId,
      'deliveryStatus': deliveryStatus,
      'deliveryDriverName': deliveryDriverName,
      'deliveryDriverPhone': deliveryDriverPhone,
      'deliveryEstimatedArrivalTime': deliveryEstimatedArrivalTime?.toIso8601String(),
      'deliveryActualDeliveryTime': deliveryActualDeliveryTime?.toIso8601String(),
    }..removeWhere((key, value) => value == null);
  }

  String get formattedTotal => _formatOrderCurrency(totalPrice);

  bool get isActive {
    switch (status) {
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
        return false;
      default:
        return true;
    }
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}

class OrderItem {
  final int id;
  final int productId;
  final String productName;
  final String? productImageUrl;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? specialInstructions;

  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.productImageUrl,
    this.specialInstructions,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      productId: json['productId'] is int
          ? json['productId'] as int
          : int.tryParse('${json['productId']}') ?? 0,
      productName: json['productName']?.toString() ?? 'Menu Item',
      productImageUrl: json['productImageUrl']?.toString(),
      quantity: json['quantity'] is int
          ? json['quantity'] as int
          : int.tryParse('${json['quantity']}') ?? 0,
      unitPrice: json['unitPrice'] is num
          ? (json['unitPrice'] as num).toDouble()
          : double.tryParse('${json['unitPrice']}') ?? 0,
      totalPrice: json['totalPrice'] is num
          ? (json['totalPrice'] as num).toDouble()
          : double.tryParse('${json['totalPrice']}') ?? 0,
      specialInstructions: json['specialInstructions']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productImageUrl': productImageUrl,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'specialInstructions': specialInstructions,
    }..removeWhere((key, value) => value == null);
  }

  double get subtotal => totalPrice;
  String get formattedSubtotal => _formatOrderCurrency(totalPrice);
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

enum PaymentMethod {
  creditCard,
  debitCard,
  paypal,
  stripe,
  abaPayway,
  cashOnDelivery,
  bankTransfer,
}

enum PaymentStatus {
  pending,
  awaitingSession,
  awaitingWebhook,
  cashPending,
  processing,
  completed,
  failed,
  cancelled,
  refunded,
}

class DeliveryInfo {
  final int id;
  final int orderId;
  final String? driverName;
  final String? driverPhone;
  final String? vehicleInfo;
  final String status;
  final DateTime? pickupTime;
  final DateTime? estimatedArrivalTime;
  final DateTime? actualDeliveryTime;
  final String? deliveryNotes;
  final String? currentLocation;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DeliveryInfo({
    required this.id,
    required this.orderId,
    required this.status,
    this.driverName,
    this.driverPhone,
    this.vehicleInfo,
    this.pickupTime,
    this.estimatedArrivalTime,
    this.actualDeliveryTime,
    this.deliveryNotes,
    this.currentLocation,
    this.createdAt,
    this.updatedAt,
  });

  factory DeliveryInfo.fromJson(Map<String, dynamic> json) {
    return DeliveryInfo(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      orderId: json['orderId'] is int
          ? json['orderId'] as int
          : int.tryParse('${json['orderId']}') ?? 0,
      status: json['status']?.toString() ?? 'PENDING',
      driverName: json['driverName']?.toString(),
      driverPhone: json['driverPhone']?.toString(),
      vehicleInfo: json['vehicleInfo']?.toString(),
      pickupTime: Order._parseDate(json['pickupTime']),
      estimatedArrivalTime: Order._parseDate(json['estimatedArrivalTime']),
      actualDeliveryTime: Order._parseDate(json['actualDeliveryTime']),
      deliveryNotes: json['deliveryNotes']?.toString(),
      currentLocation: json['currentLocation']?.toString(),
      createdAt: Order._parseDate(json['createdAt']),
      updatedAt: Order._parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'status': status,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'vehicleInfo': vehicleInfo,
      'pickupTime': pickupTime?.toIso8601String(),
      'estimatedArrivalTime': estimatedArrivalTime?.toIso8601String(),
      'actualDeliveryTime': actualDeliveryTime?.toIso8601String(),
      'deliveryNotes': deliveryNotes,
      'currentLocation': currentLocation,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    }..removeWhere((key, value) => value == null);
  }
}

OrderStatus _parseOrderStatus(dynamic value) {
  if (value == null) return OrderStatus.pending;
  final normalized = value.toString().toUpperCase();
  return OrderStatus.values.firstWhere(
    (status) => status.name.toUpperCase() == normalized,
    orElse: () => OrderStatus.pending,
  );
}

PaymentMethod _parsePaymentMethod(dynamic value) {
  if (value == null) return PaymentMethod.stripe;
  final normalized = value.toString().toUpperCase();
  return PaymentMethod.values.firstWhere(
    (method) => method.name.toUpperCase() == normalized,
    orElse: () => PaymentMethod.stripe,
  );
}

PaymentStatus _parsePaymentStatus(dynamic value) {
  if (value == null) return PaymentStatus.pending;
  final normalized = value.toString().toUpperCase();
  return PaymentStatus.values.firstWhere(
    (status) => status.name.toUpperCase() == normalized,
    orElse: () => PaymentStatus.pending,
  );
}


class CreateOrderRequest {
  final List<CreateOrderItemRequest> orderItems;
  final String orderType;
  final String? deliveryAddress;
  final String? phoneNumber;
  final String? specialInstructions;

  CreateOrderRequest({
    required this.orderItems,
    required this.orderType,
    this.deliveryAddress,
    this.phoneNumber,
    this.specialInstructions,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderItems': orderItems.map((item) => item.toJson()).toList(),
      'orderType': orderType,
      'deliveryAddress': deliveryAddress,
      'phoneNumber': phoneNumber,
      'specialInstructions': specialInstructions,
    }..removeWhere((key, value) => value == null);
  }
}

class CreateOrderItemRequest {
  final int productId;
  final int quantity;
  final String? specialInstructions;

  CreateOrderItemRequest({
    required this.productId,
    required this.quantity,
    this.specialInstructions,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      'specialInstructions': specialInstructions,
    }..removeWhere((key, value) => value == null);
  }
}
