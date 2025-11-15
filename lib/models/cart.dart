class CartItem {
  final int id;
  final int productId;
  final String productName;
  final String? productImageUrl;
  final double price;
  final int quantity;
  final double subtotal;

  const CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.subtotal,
    this.productImageUrl,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      productId: json['productId'] is int
          ? json['productId'] as int
          : int.tryParse('${json['productId']}') ?? 0,
      productName: json['productName']?.toString() ?? 'Unknown Item',
      productImageUrl: json['productImageUrl']?.toString(),
      price: json['price'] is num
          ? (json['price'] as num).toDouble()
          : double.tryParse('${json['price']}') ?? 0,
      quantity: json['quantity'] is int
          ? json['quantity'] as int
          : int.tryParse('${json['quantity']}') ?? 0,
      subtotal: json['subtotal'] is num
          ? (json['subtotal'] as num).toDouble()
          : double.tryParse('${json['subtotal']}') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productImageUrl': productImageUrl,
      'price': price,
      'quantity': quantity,
      'subtotal': subtotal,
    }..removeWhere((key, value) => value == null);
  }

  double get total => price * quantity;

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
  String get formattedSubtotal => '\$${subtotal.toStringAsFixed(2)}';
}

class Cart {
  final int id;
  final List<CartItem> items;
  final double subtotal;
  final double vat;
  final double deliveryFee;
  final double total;
  final int itemCount;

  const Cart({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.vat,
    required this.deliveryFee,
    required this.total,
    required this.itemCount,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      items: (json['items'] as List?)
              ?.map((item) => CartItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          const [],
      subtotal: json['subtotal'] is num
          ? (json['subtotal'] as num).toDouble()
          : double.tryParse('${json['subtotal']}') ?? 0,
      vat: json['vat'] is num
          ? (json['vat'] as num).toDouble()
          : double.tryParse('${json['vat']}') ?? 0,
      deliveryFee: json['deliveryFee'] is num
          ? (json['deliveryFee'] as num).toDouble()
          : double.tryParse('${json['deliveryFee']}') ?? 0,
      total: json['total'] is num
          ? (json['total'] as num).toDouble()
          : double.tryParse('${json['total']}') ?? 0,
      itemCount: json['itemCount'] is int
          ? json['itemCount'] as int
          : int.tryParse('${json['itemCount']}') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'vat': vat,
      'deliveryFee': deliveryFee,
      'total': total,
      'itemCount': itemCount,
    };
  }

  String get formattedSubtotal => '\$${subtotal.toStringAsFixed(2)}';
  String get formattedVat => '\$${vat.toStringAsFixed(2)}';
  String get formattedDeliveryFee => deliveryFee == 0 ? 'FREE' : '\$${deliveryFee.toStringAsFixed(2)}';
  String get formattedTotal => '\$${total.toStringAsFixed(2)}';

  Cart copyWith({
    int? id,
    List<CartItem>? items,
    double? subtotal,
    double? vat,
    double? deliveryFee,
    double? total,
    int? itemCount,
  }) {
    return Cart(
      id: id ?? this.id,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      vat: vat ?? this.vat,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      itemCount: itemCount ?? this.itemCount,
    );
  }
}

class AddToCartRequest {
  final int productId;
  final int quantity;

  AddToCartRequest({
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'quantity': quantity,
      };
}

class UpdateCartRequest {
  final int cartItemId;
  final int quantity;

  UpdateCartRequest({
    required this.cartItemId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
        'quantity': quantity,
      };
}
