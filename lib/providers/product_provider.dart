import 'package:flutter/foundation.dart' show ChangeNotifier, debugPrint;

import '../models/product.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class ProductProvider extends ChangeNotifier {
  List<Category> _categories = [];
  List<Product> _products = [];
  List<Product> _featuredProducts = [];
  List<Product> _popularProducts = [];
  Product? _selectedProduct;
  List<ProductReview> _productReviews = [];
  List<int> _favorites = [];
  
  bool _isLoading = false;
  bool _isLoadingProducts = false;
  bool _isLoadingCategories = false;
  bool _isLoadingReviews = false;
  String? _errorMessage;
  
  // Search and filter state
  String _searchQuery = '';
  Category? _selectedCategory;
  List<String> _selectedTags = [];
  bool _isVegetarianFilter = false;
  bool _isVeganFilter = false;
  bool _isGlutenFreeFilter = false;
  bool _isPopularFilter = false;
  String _sortBy = 'name'; // name, price, rating, preparationTime
  String _sortOrder = 'asc'; // asc, desc
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMoreProducts = true;

  // Getters
  List<Category> get categories => _categories;
  List<Product> get products => _products;
  List<Product> get featuredProducts => _featuredProducts;
  List<Product> get popularProducts => _popularProducts;
  Product? get selectedProduct => _selectedProduct;
  List<ProductReview> get productReviews => _productReviews;
  List<int> get favorites => _favorites;
  
  bool get isLoading => _isLoading;
  bool get isLoadingProducts => _isLoadingProducts;
  bool get isLoadingCategories => _isLoadingCategories;
  bool get isLoadingReviews => _isLoadingReviews;
  String? get errorMessage => _errorMessage;
  
  // Filter getters
  String get searchQuery => _searchQuery;
  Category? get selectedCategory => _selectedCategory;
  List<String> get selectedTags => _selectedTags;
  bool get isVegetarianFilter => _isVegetarianFilter;
  bool get isVeganFilter => _isVeganFilter;
  bool get isGlutenFreeFilter => _isGlutenFreeFilter;
  bool get isPopularFilter => _isPopularFilter;
  String get sortBy => _sortBy;
  String get sortOrder => _sortOrder;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasMoreProducts => _hasMoreProducts;

  // Computed getters
  List<Product> get filteredProducts {
    var filtered = List<Product>.from(_products);
    
    // Apply category filter
    if (_selectedCategory != null) {
      filtered = filtered.where((p) => p.category.id == _selectedCategory!.id).toList();
    }
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) => 
        p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    // Apply dietary filters
    if (_isVegetarianFilter) {
      filtered = filtered.where((p) => p.isVegetarian).toList();
    }
    if (_isVeganFilter) {
      filtered = filtered.where((p) => p.isVegan).toList();
    }
    if (_isGlutenFreeFilter) {
      filtered = filtered.where((p) => p.isGlutenFree).toList();
    }
    if (_isPopularFilter) {
      filtered = filtered.where((p) => p.isPopular).toList();
    }
    
    // Apply tag filter
    if (_selectedTags.isNotEmpty) {
      filtered = filtered.where((p) => 
        _selectedTags.any((tag) => p.tags.contains(tag))
      ).toList();
    }
    
    // Apply sorting
    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'price':
          comparison = a.price.compareTo(b.price);
          break;
        case 'rating':
          comparison = a.rating.compareTo(b.rating);
          break;
        case 'preparationTime':
          comparison = a.preparationTime.compareTo(b.preparationTime);
          break;
      }
      return _sortOrder == 'desc' ? -comparison : comparison;
    });
    
    return filtered;
  }

  bool isFavorite(int productId) {
    return _favorites.contains(productId);
  }

  ProductProvider() {
    _initializeData();
  }

  // Initialize data
  Future<void> _initializeData() async {
    await loadFavorites();
    await loadCategories();
    await loadFeaturedProducts();
    await loadPopularProducts();
  }

  // Load categories
  Future<void> loadCategories() async {
    _isLoadingCategories = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await ApiService.getCategories();
      _isLoadingCategories = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  // Load products with filters
  Future<void> loadProducts({bool resetPage = false}) async {
    if (_isLoadingProducts) return;

    if (resetPage) {
      _currentPage = 1;
      _hasMoreProducts = true;
    }

    if (!_hasMoreProducts && !resetPage) return;

    _isLoadingProducts = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final products = await ApiService.getProducts(
        categoryId: _selectedCategory?.id,
        availableOnly: true,
      );

      _products = products;
      _hasMoreProducts = false;
      _currentPage = 1;
      _totalPages = 1;

      _isLoadingProducts = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  // Load featured products
  Future<void> loadFeaturedProducts() async {
    try {
      final products = await ApiService.getProducts(availableOnly: true);
      _featuredProducts =
          products.where((product) => product.isPopular).take(10).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load featured products: $e');
    }
  }

  // Load popular products
  Future<void> loadPopularProducts() async {
    try {
      final products = await ApiService.getProducts(availableOnly: true);
      _popularProducts = products
          .where((product) => product.isPopular || product.rating >= 4)
          .take(10)
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load popular products: $e');
    }
  }

  // Load product details
  Future<void> loadProductDetails(int productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedProduct = await ApiService.getProductDetails(productId);
      
      // Add to recently viewed
      await StorageService.addToRecentlyViewed(productId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load product reviews
  Future<void> loadProductReviews(int productId, {int page = 1}) async {
    _isLoadingReviews = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final reviews = await ApiService.getProductReviews(productId);

      if (page == 1) {
        _productReviews = reviews;
      } else {
        _productReviews.addAll(reviews);
      }
      
      _isLoadingReviews = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoadingReviews = false;
      notifyListeners();
    }
  }

  // Search products
  Future<void> searchProducts(String query) async {
    _searchQuery = query;
    notifyListeners();
  }

  // Filter by category
  Future<void> filterByCategory(Category? category) async {
    _selectedCategory = category;
    await loadProducts(resetPage: true);
  }

  // Toggle dietary filters
  Future<void> toggleVegetarianFilter() async {
    _isVegetarianFilter = !_isVegetarianFilter;
    notifyListeners();
  }

  Future<void> toggleVeganFilter() async {
    _isVeganFilter = !_isVeganFilter;
    notifyListeners();
  }

  Future<void> toggleGlutenFreeFilter() async {
    _isGlutenFreeFilter = !_isGlutenFreeFilter;
    notifyListeners();
  }

  Future<void> togglePopularFilter() async {
    _isPopularFilter = !_isPopularFilter;
    notifyListeners();
  }

  // Toggle tags
  Future<void> toggleTag(String tag) async {
    if (_selectedTags.contains(tag)) {
      _selectedTags.remove(tag);
    } else {
      _selectedTags.add(tag);
    }
    notifyListeners();
  }

  // Clear all filters
  Future<void> clearFilters() async {
    _selectedCategory = null;
    _searchQuery = '';
    _selectedTags = [];
    _isVegetarianFilter = false;
    _isVeganFilter = false;
    _isGlutenFreeFilter = false;
    _isPopularFilter = false;
    _sortBy = 'name';
    _sortOrder = 'asc';
    await loadProducts(resetPage: true);
  }

  // Sort products
  Future<void> sortProducts(String sortBy, {String sortOrder = 'asc'}) async {
    _sortBy = sortBy;
    _sortOrder = sortOrder;
    notifyListeners();
  }

  // Load more products (pagination)
  Future<void> loadMoreProducts() async {
    if (!_isLoadingProducts && _hasMoreProducts) {
      await loadProducts();
    }
  }

  // Refresh data
  Future<void> refresh() async {
    await Future.wait([
      loadCategories(),
      loadProducts(resetPage: true),
      loadFeaturedProducts(),
      loadPopularProducts(),
    ]);
  }

  // Favorites management
  Future<void> loadFavorites() async {
    _favorites = StorageService.getFavorites();
    notifyListeners();
  }

  Future<void> toggleFavorite(int productId) async {
    if (_favorites.contains(productId)) {
      _favorites.remove(productId);
      await StorageService.removeFromFavorites(productId);
    } else {
      _favorites.add(productId);
      await StorageService.addToFavorites(productId);
    }
    notifyListeners();
  }

  Future<void> clearFavorites() async {
    _favorites.clear();
    await StorageService.clearFavorites();
    notifyListeners();
  }

  // Get recently viewed products
  Future<List<Product>> getRecentlyViewed() async {
    final recentlyViewedIds = StorageService.getRecentlyViewed();
    final products = <Product>[];
    
    for (final id in recentlyViewedIds) {
      try {
        final product = await ApiService.getProductDetails(id);
        products.add(product);
      } catch (e) {
        // Skip products that can't be loaded
        continue;
      }
    }
    
    return products;
  }

  // Get products by IDs
  Future<List<Product>> getProductsByIds(List<int> productIds) async {
    final products = <Product>[];
    
    for (final id in productIds) {
      try {
        final product = await ApiService.getProductDetails(id);
        products.add(product);
      } catch (e) {
        // Skip products that can't be loaded
        continue;
      }
    }
    
    return products;
  }

  // Get search suggestions
  List<String> getSearchSuggestions() {
    final suggestions = <String>[];
    final searchHistory = StorageService.getSearchHistory();
    
    // Add search history
    suggestions.addAll(searchHistory.where((s) => 
      s.toLowerCase().contains(_searchQuery.toLowerCase())
    ));
    
    // Add product names that match
    for (final product in _products) {
      if (product.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        suggestions.add(product.name);
      }
    }
    
    // Add category names that match
    for (final category in _categories) {
      if (category.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        suggestions.add(category.name);
      }
    }
    
    // Remove duplicates and limit to 10 suggestions
    return suggestions.toSet().take(10).toList();
  }

  // Add search term to history
  Future<void> addToSearchHistory(String term) async {
    if (term.isNotEmpty) {
      await StorageService.addToSearchHistory(term);
    }
  }

  // Clear search history
  Future<void> clearSearchHistory() async {
    await StorageService.clearSearchHistory();
  }

  // Get available tags from products
  List<String> getAvailableTags() {
    final tags = <String>{};
    for (final product in _products) {
      tags.addAll(product.tags);
    }
    return tags.toList()..sort();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Reset state
  void resetState() {
    _selectedProduct = null;
    _productReviews = [];
    _searchQuery = '';
    _selectedCategory = null;
    _selectedTags = [];
    _isVegetarianFilter = false;
    _isVeganFilter = false;
    _isGlutenFreeFilter = false;
    _isPopularFilter = false;
    _sortBy = 'name';
    _sortOrder = 'asc';
    _currentPage = 1;
    _totalPages = 1;
    _hasMoreProducts = true;
    notifyListeners();
  }
}
