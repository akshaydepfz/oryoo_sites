import 'dart:convert';

import 'package:http/http.dart' as http;

import '../api/api_config.dart';
import '../models/shop.dart';
import '../utils/json_utils.dart';

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

  final decoded = jsonDecode(response.body);
  final json = safeExtractMap(decoded) ?? const {};
  return ShopResolutionResponse.fromJson(json);
}

class ShopResolutionResponse {
  ShopResolutionResponse({
    required this.shopId,
    required this.shop,
    required this.found,
  });

  factory ShopResolutionResponse.fromJson(Map<String, dynamic> json) {
    final shopId = safeStr(json['shop_id']);
    Shop? shop;
    final shopData = json['shop'];
    if (shopData != null && shopData is Map) {
      shop = Shop.fromJson(Map<String, dynamic>.from(shopData));
    }
    final found = json['found'] == true ||
        json['found'] == 1 ||
        (safeStr(json['found']).toLowerCase() == 'true');
    return ShopResolutionResponse(
      shopId: shopId,
      shop: shop,
      found: found,
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
