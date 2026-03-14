import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  bool get isEmpty => _items.isEmpty;

  int get totalItems =>
      _items.fold<int>(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      _items.fold<double>(0.0, (sum, item) => sum + item.totalPrice);

  void addToCart(Product product, {ProductVariant? variant}) {
    final productId = product.id;
    final existingIndex = _items.indexWhere(
      (item) =>
          item.product.id == productId &&
          (item.variant?.id ?? '') == (variant?.id ?? ''),
    );

    if (existingIndex != -1) {
      _items[existingIndex].quantity += 1;
    } else {
      _items.add(
        CartItem(
          product: product,
          variant: variant,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void increaseQuantity(String productId) {
    for (final item in _items) {
      if (item.product.id == productId) {
        item.quantity += 1;
        break;
      }
    }
    notifyListeners();
  }

  void decreaseQuantity(String productId) {
    for (var i = 0; i < _items.length; i++) {
      final item = _items[i];
      if (item.product.id == productId) {
        item.quantity -= 1;
        if (item.quantity <= 0) {
          _items.removeAt(i);
        }
        break;
      }
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

