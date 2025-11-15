import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider extends ChangeNotifier {
  List<Category> _categories = [];
  List<Product> _products = [];
  Product? _selectedProduct;

  bool _isLoading = false;
  bool _isLoadingProducts = false;
  bool _isLoadingCategories = false;
  String? _errorMessage;

  String _searchQuery = '';
  Category? _selectedCategory;

  List<Category> get categories => _categories;
  List<Product> get products => _products;
  Product? get selectedProduct => _selectedProduct;

  bool get isLoading => _isLoading;
  bool get isLoadingProducts => _isLoadingProducts;
  bool get isLoadingCategories => _isLoadingCategories;
  String? get errorMessage => _errorMessage;

  String get searchQuery => _searchQuery;
  Category? get selectedCategory => _selectedCategory;

  List<Product> get filteredProducts {
    final query = _searchQuery.trim().toLowerCase();

    return _products.where((product) {
      final matchesCategory =
          _selectedCategory == null || product.category.id == _selectedCategory!.id;
      final matchesQuery = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  ProductProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.wait([
      loadCategories(),
      loadProducts(reset: true),
    ]);
  }

  Future<void> loadCategories() async {
    _isLoadingCategories = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final categories = await ApiService.getCategories();
      _categories = categories;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  Future<void> loadProducts({bool reset = false}) async {
    if (_isLoadingProducts) return;

    if (reset) {
      _products = [];
      notifyListeners();
    }

    _isLoadingProducts = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final products = await ApiService.getProducts(
        categoryId: _selectedCategory?.id,
        availableOnly: true,
      );
      _products = products;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  Future<void> loadProductDetails(int productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final product = await ApiService.getProductDetails(productId);
      _selectedProduct = product;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchProducts(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> filterByCategory(Category? category) async {
    if (_selectedCategory?.id == category?.id) {
      _selectedCategory = category;
      notifyListeners();
      return;
    }

    _selectedCategory = category;
    await loadProducts(reset: true);
  }

  Future<void> refresh() async {
    await Future.wait([
      loadCategories(),
      loadProducts(reset: true),
    ]);
  }

  void clearSelection() {
    _selectedProduct = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
