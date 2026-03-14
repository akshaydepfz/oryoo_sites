import 'product.dart';

class CartItem {
  CartItem({
    required this.product,
    this.variant,
    this.quantity = 1,
  }) : assert(quantity > 0, 'Quantity must be greater than zero');

  final Product product;
  final ProductVariant? variant;
  int quantity;

  String get id => '${product.id ?? product.name}-${variant?.id ?? 'default'}';

  double get unitPrice => variant?.price ?? product.price;

  double get totalPrice => unitPrice * quantity;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem &&
        other.product.id == product.id &&
        other.variant?.id == variant?.id;
  }

  @override
  int get hashCode => Object.hash(product.id, variant?.id);

  @override
  String toString() {
    return 'CartItem(product: ${product.id}, variant: ${variant?.id}, quantity: $quantity)';
  }
}

