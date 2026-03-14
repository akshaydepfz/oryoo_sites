import 'dart:convert';

import 'package:http/http.dart' as http;

import '../api/api_config.dart';
import '../models/order.dart';

class OrdersApiException implements Exception {
  OrdersApiException(this.message);
  final String message;
  @override
  String toString() => 'OrdersApiException: $message';
}

Future<OrderResponse> createOrder({
  required String shopId,
  required String customerName,
  required String phone,
  required String address,
  required String city,
  required String pincode,
  required String productId,
  String? variantId,
  int quantity = 1,
  required String paymentMethod,
}) async {
  final uri = Uri.parse('${ApiConfig.baseUrl}/sites/orders');

  final fullAddress = [
    address.trim(),
    city.trim().isEmpty ? null : city.trim(),
    pincode.trim().isEmpty ? null : pincode.trim(),
  ].whereType<String>().join(', ');

  final item = <String, dynamic>{
    'product_id': productId,
    'quantity': quantity,
  };
  if (variantId != null && variantId.isNotEmpty) {
    item['variant_id'] = variantId;
  }

  final payload = <String, dynamic>{
    'shop_id': shopId,
    'customer_name': customerName,
    'phone': phone,
    'address': fullAddress,
    'items': [item],
    'payment_method': paymentMethod,
  };

  final response = await http.post(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(payload),
  );

  if (response.statusCode != 200 && response.statusCode != 201) {
    throw OrdersApiException(
      'Failed to create order: ${response.statusCode}',
    );
  }

  final decoded = jsonDecode(response.body);
  if (decoded is Map<String, dynamic>) {
    return OrderResponse.fromJson(decoded);
  }
  if (decoded is Map) {
    return OrderResponse.fromJson(Map<String, dynamic>.from(decoded));
  }
  throw OrdersApiException('Unexpected response from order API');
}

