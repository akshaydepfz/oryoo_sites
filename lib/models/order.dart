import '../utils/json_utils.dart';

class OrderResponse {
  OrderResponse({
    required this.id,
    required this.amount,
    this.currency,
    this.razorpayOrderId,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    final id = safeStr(json['id']).isEmpty ? safeStr(json['order_id']) : safeStr(json['id']);
    return OrderResponse(
      id: id,
      amount: safeDouble(json['amount']),
      currency: safeStrOrNull(json['currency']),
      razorpayOrderId: safeStrOrNull(json['razorpay_order_id']),
    );
  }

  final String id;
  final double amount;
  final String? currency;
  final String? razorpayOrderId;
}

