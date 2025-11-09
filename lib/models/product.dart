import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'product.g.dart';

@JsonSerializable()
class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final String? thumbnailUrl;
  final Category category;
  final List<String> tags;
  final bool isAvailable;
  final bool isPopular;
  final bool isVegetarian;
  final bool isVegan;
  final bool isGlutenFree;
  final int preparationTime; // in minutes
  final double rating;
  final int reviewCount;
  final List<String> ingredients;
  final List<String> allergens;
  final NutritionInfo? nutritionInfo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.thumbnailUrl,
    required this.category,
    required this.tags,
    required this.isAvailable,
    this.isPopular = false,
    this.isVegetarian = false,
    this.isVegan = false,
    this.isGlutenFree = false,
    required this.preparationTime,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.ingredients,
    required this.allergens,
    this.nutritionInfo,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
  
  String get formattedPreparationTime {
    if (preparationTime < 60) {
      return '${preparationTime}min';
    } else {
      final hours = preparationTime ~/ 60;
      final minutes = preparationTime % 60;
      return minutes > 0 ? '${hours}h ${minutes}min' : '${hours}h';
    }
  }
  
  String get dietaryInfo {
    final info = <String>[];
    if (isVegetarian) info.add('Vegetarian');
    if (isVegan) info.add('Vegan');
    if (isGlutenFree) info.add('Gluten-Free');
    return info.join(' • ');
  }
}

@JsonSerializable()
class Category {
  final int id;
  final String name;
  final String description;
  final String? imageUrl;
  final String? iconUrl;
  final int sortOrder;
  final bool isActive;
  final int productCount;

  Category({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    this.iconUrl,
    required this.sortOrder,
    required this.isActive,
    required this.productCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}

@JsonSerializable()
class NutritionInfo {
  final int calories;
  final double protein; // in grams
  final double carbohydrates; // in grams
  final double fat; // in grams
  final double fiber; // in grams
  final double sugar; // in grams
  final double sodium; // in milligrams
  final double cholesterol; // in milligrams

  NutritionInfo({
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    required this.fiber,
    required this.sugar,
    required this.sodium,
    required this.cholesterol,
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) => _$NutritionInfoFromJson(json);
  Map<String, dynamic> toJson() => _$NutritionInfoToJson(this);
}

@JsonSerializable()
class ProductReview {
  final int id;
  final User user;
  final int productId;
  final int rating; // 1-5
  final String comment;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String>? images;

  ProductReview({
    required this.id,
    required this.user,
    required this.productId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.updatedAt,
    this.images,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) => _$ProductReviewFromJson(json);
  Map<String, dynamic> toJson() => _$ProductReviewToJson(this);
}
