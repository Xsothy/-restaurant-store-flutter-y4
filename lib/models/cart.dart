import 'package:json_annotation/json_annotation.dart';
import 'product.dart';

part 'cart.g.dart';

@JsonSerializable()
class CartItem {
  final String id; // Unique identifier for cart item
  final Product product;
  final int quantity;
  final List<String> customizations;
  final String? specialInstructions;
  final DateTime addedAt;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.customizations,
    this.specialInstructions,
    required this.addedAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => _$CartItemFromJson(json);
  Map<String, dynamic> toJson() => _$CartItemToJson(this);

  double get subtotal => product.price * quantity;
  
  String get formattedSubtotal => '\$${subtotal.toStringAsFixed(2)}';
  
  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    List<String>? customizations,
    String? specialInstructions,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      customizations: customizations ?? this.customizations,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}

@JsonSerializable()
class Cart {
  final String id;
  final List<CartItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  Cart({
    required this.id,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cart.fromJson(Map<String, dynamic> json) => _$CartFromJson(json);
  Map<String, dynamic> toJson() => _$CartToJson(this);

  double get subtotal {
    return items.fold(0.0, (sum, item) => sum + item.subtotal);
  }
  
  double get tax => subtotal * 0.08; // 8% tax rate
  
  double get deliveryFee => subtotal >= 10.0 ? 0.0 : 2.99; // Free delivery for orders over $10
  
  double get total => subtotal + tax + deliveryFee;
  
  int get itemCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
  
  String get formattedSubtotal => '\$${subtotal.toStringAsFixed(2)}';
  String get formattedTax => '\$${tax.toStringAsFixed(2)}';
  String get formattedDeliveryFee => deliveryFee == 0.0 ? 'FREE' : '\$${deliveryFee.toStringAsFixed(2)}';
  String get formattedTotal => '\$${total.toStringAsFixed(2)}';
  
  Cart copyWith({
    String? id,
    List<CartItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Cart(
      id: id ?? this.id,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class AddToCartRequest {
  final int productId;
  final int quantity;
  final List<String> customizations;
  final String? specialInstructions;

  AddToCartRequest({
    required this.productId,
    required this.quantity,
    required this.customizations,
    this.specialInstructions,
  });

  factory AddToCartRequest.fromJson(Map<String, dynamic> json) => _$AddToCartRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AddToCartRequestToJson(this);
}

@JsonSerializable()
class UpdateCartRequest {
  final String cartItemId;
  final int quantity;

  UpdateCartRequest({
    required this.cartItemId,
    required this.quantity,
  });

  factory UpdateCartRequest.fromJson(Map<String, dynamic> json) => _$UpdateCartRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateCartRequestToJson(this);
}

@JsonSerializable()
class CartResponse {
  final Cart cart;
  final String message;

  CartResponse({
    required this.cart,
    required this.message,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) => _$CartResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CartResponseToJson(this);
}
