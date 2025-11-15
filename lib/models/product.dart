/// Product model that mirrors the Restaurant Store API contract while keeping
/// compatibility with the existing UI widgets. The backend returns a
/// [ProductResponse] object that contains a few essential fields. The UI,
/// however, expects additional properties for filters (vegetarian/vegan tags,
/// popularity flags, etc.). Those values are therefore optional and fallback to
/// sensible defaults so that the current experience keeps working even if the
/// backend does not provide them.
class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final Category category;
  final bool isAvailable;

  // Optional fields used by the presentation layer.
  final bool isPopular;
  final bool isVegetarian;
  final bool isVegan;
  final bool isGlutenFree;
  final int preparationTime;
  final double rating;
  final int reviewCount;
  final List<String> tags;
  final List<String> ingredients;
  final List<String> allergens;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.isAvailable,
    this.imageUrl,
    this.isPopular = false,
    this.isVegetarian = false,
    this.isVegan = false,
    this.isGlutenFree = false,
    this.preparationTime = 15,
    this.rating = 0,
    this.reviewCount = 0,
    List<String>? tags,
    List<String>? ingredients,
    List<String>? allergens,
    this.createdAt,
    this.updatedAt,
  })  : tags = tags ?? const [],
        ingredients = ingredients ?? const [],
        allergens = allergens ?? const [];

  factory Product.fromJson(Map<String, dynamic> json) {
    final category = Category(
      id: json['categoryId'] is int
          ? json['categoryId'] as int
          : int.tryParse('${json['categoryId']}') ?? 0,
      name: json['categoryName']?.toString() ?? 'Menu',
      description: json['description']?.toString() ?? '',
      productCount: json['productCount'] is int
          ? json['productCount'] as int
          : (json['productCount'] == null
              ? null
              : int.tryParse('${json['productCount']}')),
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
      isPopular: json['isPopular'] as bool? ?? false,
      isVegetarian: json['isVegetarian'] as bool? ?? false,
      isVegan: json['isVegan'] as bool? ?? false,
      isGlutenFree: json['isGlutenFree'] as bool? ?? false,
      preparationTime: json['preparationTime'] is int
          ? json['preparationTime'] as int
          : int.tryParse('${json['preparationTime']}') ?? 15,
      rating: json['rating'] is num
          ? (json['rating'] as num).toDouble()
          : double.tryParse('${json['rating']}') ?? 0,
      reviewCount: json['reviewCount'] is int
          ? json['reviewCount'] as int
          : int.tryParse('${json['reviewCount']}') ?? 0,
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList(),
      ingredients: (json['ingredients'] as List?)?.map((e) => e.toString()).toList(),
      allergens: (json['allergens'] as List?)?.map((e) => e.toString()).toList(),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
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
      'category': category.toJson(),
      'isAvailable': isAvailable,
      'isPopular': isPopular,
      'isVegetarian': isVegetarian,
      'isVegan': isVegan,
      'isGlutenFree': isGlutenFree,
      'preparationTime': preparationTime,
      'rating': rating,
      'reviewCount': reviewCount,
      'tags': tags,
      'ingredients': ingredients,
      'allergens': allergens,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    }..removeWhere((key, value) => value == null);
  }

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  String get formattedPreparationTime {
    if (preparationTime < 60) {
      return '${preparationTime}min';
    }
    final hours = preparationTime ~/ 60;
    final minutes = preparationTime % 60;
    return minutes > 0 ? '${hours}h ${minutes}min' : '${hours}h';
  }

  String get dietaryInfo {
    final info = <String>[];
    if (isVegetarian) info.add('Vegetarian');
    if (isVegan) info.add('Vegan');
    if (isGlutenFree) info.add('Gluten-Free');
    return info.join(' • ');
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}

/// Category information returned by the backend. Only a handful of fields are
/// present in the API schema; everything else is optional so that filters and
/// UI elements can continue to function with placeholder data.
class Category {
  final int id;
  final String name;
  final String description;
  final int? productCount;
  final String? imageUrl;
  final String? iconUrl;
  final int? sortOrder;
  final bool? isActive;

  Category({
    required this.id,
    required this.name,
    this.description = '',
    this.productCount,
    this.imageUrl,
    this.iconUrl,
    this.sortOrder,
    this.isActive,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? 'Category',
      description: json['description']?.toString() ?? '',
      productCount: json['productCount'] is int
          ? json['productCount'] as int
          : int.tryParse('${json['productCount']}'),
      imageUrl: json['imageUrl']?.toString(),
      iconUrl: json['iconUrl']?.toString(),
      sortOrder: json['sortOrder'] is int
          ? json['sortOrder'] as int
          : int.tryParse('${json['sortOrder']}'),
      isActive: json['isActive'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'productCount': productCount,
      'imageUrl': imageUrl,
      'iconUrl': iconUrl,
      'sortOrder': sortOrder,
      'isActive': isActive,
    }..removeWhere((key, value) => value == null);
  }
}

/// Minimal placeholder for product reviews. The current API specification does
/// not expose review endpoints yet, but the UI expects the model to exist. The
/// implementation therefore keeps the class lightweight so that previously
/// mocked data still renders without runtime crashes.
class ProductReview {
  final int id;
  final int productId;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String>? images;

  const ProductReview({
    required this.id,
    required this.productId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.updatedAt,
    this.images,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      productId: json['productId'] is int
          ? json['productId'] as int
          : int.tryParse('${json['productId']}') ?? 0,
      rating: json['rating'] is int
          ? json['rating'] as int
          : int.tryParse('${json['rating']}') ?? 0,
      comment: json['comment']?.toString() ?? '',
      createdAt: Product._parseDate(json['createdAt']) ?? DateTime.now(),
      updatedAt: Product._parseDate(json['updatedAt']),
      images: (json['images'] as List?)?.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'images': images,
    }..removeWhere((key, value) => value == null);
  }
}
