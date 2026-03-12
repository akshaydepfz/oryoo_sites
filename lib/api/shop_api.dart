import 'dart:convert';

import 'package:http/http.dart' as http;

import '../api/api_config.dart';
import '../models/shop.dart';

/// Resolves a shop by domain.
/// GET /sites/shop/by-domain?domain={domain}
Future<ShopResolutionResponse> resolveShopByDomain(String domain) async {
  final uri = Uri.parse('${ApiConfig.baseUrl}/sites/shop/by-domain')
      .replace(queryParameters: {'domain': domain});

  final response = await http.get(uri);

  if (response.statusCode != 200) {
    throw ShopResolutionException(
      'Failed to resolve shop: ${response.statusCode}',
      statusCode: response.statusCode,
    );
  }

  final json = jsonDecode(response.body) as Map<String, dynamic>;
  return ShopResolutionResponse.fromJson(json);
}

class ShopResolutionResponse {
  ShopResolutionResponse({
    required this.shopId,
    required this.shop,
    required this.found,
  });

  factory ShopResolutionResponse.fromJson(Map<String, dynamic> json) {
    return ShopResolutionResponse(
      shopId: json['shop_id'] as String? ?? '',
      shop: json['shop'] != null
          ? Shop.fromJson(json['shop'] as Map<String, dynamic>)
          : null,
      found: json['found'] as bool? ?? false,
    );
  }

  final String shopId;
  final Shop? shop;
  final bool found;
}

class ShopResolutionException implements Exception {
  ShopResolutionException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ShopResolutionException: $message';
}
