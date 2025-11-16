import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/product_model.dart';
import '../service/api_service.dart';

class ProductProvider with ChangeNotifier {
  final APIProvider _apiProvider = APIProvider();

  List<Product> _products = [];
  Product? _selectedProduct;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  ProductSortOption _currentSortOption = ProductSortOption.id;

  List<Product> get products => _products;
  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  ProductSortOption get currentSortOption => _currentSortOption;

  // Get filtered and sorted products
  List<Product> get filteredProducts {
    var filtered = _products.where((product) {
      if (_searchQuery.isEmpty) return true;
      return product.productName?.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ??
          false;
    }).toList();

    // Apply current sort
    _applySortToList(filtered);

    return filtered;
  }

  // Apply sorting to a list
  void _applySortToList(List<Product> list) {
    switch (_currentSortOption) {
      case ProductSortOption.id:
        list.sort((a, b) => (a.productId ?? 0).compareTo(b.productId ?? 0));
        break;
      case ProductSortOption.name:
        list.sort(
          (a, b) => (a.productName ?? '').compareTo(b.productName ?? ''),
        );
        break;
      case ProductSortOption.price:
        list.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
        break;
      case ProductSortOption.stock:
        list.sort((a, b) => (a.stock ?? 0).compareTo(b.stock ?? 0));
        break;
    }
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Fetch all products from API
  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Response response = await _apiProvider.getProducts();

      if (response.statusCode == 200) {
        if (response.data is Map<String, dynamic> &&
            response.data['products'] != null) {
          ProductResponse productResponse = ProductResponse.fromJson(
            response.data,
          );
          _products = productResponse.products ?? [];
        } else if (response.data is List) {
          _products = (response.data as List)
              .map((json) => Product.fromJson(json))
              .toList();
        }
        // Apply current sort after fetching
        _applySortToList(_products);
      } else {
        _error = 'Failed to load products: ${response.statusCode}';
      }
    } on DioException catch (e) {
      _error = _handleDioError(e);
      debugPrint('DioException: $e');
    } catch (e) {
      _error = 'Unexpected error: $e';
      debugPrint('Error fetching products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create new product
  Future<bool> createProduct({
    required String productName,
    required double price,
    required int stock,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Response response = await _apiProvider.createProduct(
        productName: productName,
        price: price,
        stock: stock,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchProducts();
        return true;
      } else {
        _error = 'Failed to create product: ${response.statusCode}';
        return false;
      }
    } on DioException catch (e) {
      _error = _handleDioError(e);
      return false;
    } catch (e) {
      _error = 'Unexpected error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update product
  Future<bool> updateProduct(
    int id, {
    required String productName,
    required double price,
    required int stock,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Response response = await _apiProvider.updateProduct(
        id,
        productName: productName,
        price: price,
        stock: stock,
      );

      if (response.statusCode == 200) {
        await fetchProducts();
        return true;
      } else {
        _error = 'Failed to update product: ${response.statusCode}';
        return false;
      }
    } on DioException catch (e) {
      _error = _handleDioError(e);
      return false;
    } catch (e) {
      _error = 'Unexpected error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete product
  Future<bool> deleteProduct(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Response response = await _apiProvider.deleteProduct(id);

      if (response.statusCode == 200 || response.statusCode == 204) {
        _products.removeWhere((product) => product.productId == id);
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to delete product: ${response.statusCode}';
        return false;
      }
    } on DioException catch (e) {
      _error = _handleDioError(e);
      return false;
    } catch (e) {
      _error = 'Unexpected error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search products locally
  List<Product> searchProducts(String query) {
    setSearchQuery(query);
    return filteredProducts;
  }

  // Sort by name
  void sortByName() {
    _currentSortOption = ProductSortOption.name;
    _applySortToList(_products);
    notifyListeners();
  }

  // Sort by price
  void sortByPrice() {
    _currentSortOption = ProductSortOption.price;
    _applySortToList(_products);
    notifyListeners();
  }

  // Sort by stock
  void sortByStock() {
    _currentSortOption = ProductSortOption.stock;
    _applySortToList(_products);
    notifyListeners();
  }

  // Sort by ID
  void sortById() {
    _currentSortOption = ProductSortOption.id;
    _applySortToList(_products);
    notifyListeners();
  }

  // Handle Dio errors
  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet.';
      case DioExceptionType.sendTimeout:
        return 'Send timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout. Please try again.';
      case DioExceptionType.badResponse:
        return 'Server error: ${e.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear selected product
  void clearSelectedProduct() {
    _selectedProduct = null;
    notifyListeners();
  }
}

enum ProductSortOption { id, name, price, stock }
