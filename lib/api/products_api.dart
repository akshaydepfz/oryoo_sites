import 'dart:convert';

import 'package:http/http.dart' as http;

import '../api/api_config.dart';
import '../models/product.dart';

/// Fetches products for a shop.
/// GET /sites/products?shop_id=
Future<List<Product>> fetchProducts(String shopId) async {
  final uri = Uri.parse('${ApiConfig.baseUrl}/sites/products')
      .replace(queryParameters: {'shop_id': shopId});

  final response = await http.get(uri);

  if (response.statusCode != 200) {
    throw ApiException('Failed to fetch products: ${response.statusCode}');
  }

  final json = jsonDecode(response.body);
  if (json is List) {
    return json
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  return [];
}

class ApiException implements Exception {
  ApiException(this.message);
  final String message;
  @override
  String toString() => 'ApiException: $message';
}
