import 'package:intl/intl.dart';

class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final Category category;
  final bool isAvailable;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.isAvailable,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final category = Category(
      id: json['categoryId'] is int
          ? json['categoryId'] as int
          : int.tryParse('${json['categoryId']}') ?? 0,
      name: json['categoryName']?.toString() ?? 'Menu',
      description: json['categoryDescription']?.toString(),
    );

    return Product(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? 'Unknown Item',
      description: json['description']?.toString() ?? '',
      price: json['price'] is num
          ? (json['price'] as num).toDouble()
          : double.tryParse('${json['price']}') ?? 0,
      imageUrl: json['imageUrl']?.toString(),
      category: category,
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'categoryId': category.id,
      'categoryName': category.name,
      'categoryDescription': category.description,
      'isAvailable': isAvailable,
    }..removeWhere((key, value) => value == null);
  }

  static final NumberFormat _currencyFormat = NumberFormat('#,###', 'en_US');

  String get formattedPrice => '${_currencyFormat.format(price.round())} KHR';
}

class Category {
  final int id;
  final String name;
  final String? description;

  Category({
    required this.id,
    required this.name,
    this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? 'Category',
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    }..removeWhere((key, value) => value == null);
  }
}
