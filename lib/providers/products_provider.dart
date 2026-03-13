import 'package:flutter/foundation.dart';

import '../api/products_api.dart';
import '../models/product.dart';

class ProductsProvider with ChangeNotifier {
  ProductsProvider();

  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Product> get featuredProducts =>
      _products.where((p) => p.featured).toList();

  Future<void> loadProducts(String? shopId) async {
    if (shopId == null || shopId.isEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await fetchProducts(shopId);
    } catch (e) {
      _errorMessage = e.toString();
      _products = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Product? getProductById(String id) {
    final byId = _products.where((p) => p.id == id);
    if (byId.isNotEmpty) return byId.first;
    final hashId = int.tryParse(id);
    if (hashId != null) {
      for (final p in _products) {
        if (p.name.hashCode == hashId) return p;
      }
    }
    return null;
  }
}
