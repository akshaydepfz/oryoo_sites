import 'dart:convert';

import 'package:http/http.dart' as http;

import '../api/api_config.dart';
import '../models/product.dart';
import '../utils/json_utils.dart';

/// Fetches products for a shop.
/// GET /sites/products?shop_id=
Future<List<Product>> fetchProducts(String shopId) async {
  final uri = Uri.parse('${ApiConfig.baseUrl}/sites/products')
      .replace(queryParameters: {'shop_id': shopId});

  final response = await http.get(uri);

  if (response.statusCode != 200) {
    throw ApiException('Failed to fetch products: ${response.statusCode}');
  }

  final decoded = jsonDecode(response.body);
  final list = safeExtractList(decoded) ?? (decoded is List ? decoded : <dynamic>[]);
  return list
      .whereType<Map>()
      .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
      .toList();
}

class ApiException implements Exception {
  ApiException(this.message);
  final String message;
  @override
  String toString() => 'ApiException: $message';
}
