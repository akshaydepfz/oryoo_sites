import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../api/categories_api.dart';
import '../models/category.dart';

class CategoriesProvider with ChangeNotifier {
  CategoriesProvider();

  List<Category> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadCategories(String? shopId) async {
    if (shopId == null || shopId.isEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await fetchCategories(shopId);
    } catch (e) {
      _errorMessage = e.toString();
      _categories = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
