import 'dart:convert';

import 'package:http/http.dart' as http;

import '../api/api_config.dart';
import '../models/site_config.dart';
import '../utils/json_utils.dart';

/// Fetches site config for a shop.
/// GET /sites/site-config?shop_id=
Future<SiteConfig> fetchSiteConfig(String shopId) async {
  final uri = Uri.parse('${ApiConfig.baseUrl}/sites/site-config')
      .replace(queryParameters: {'shop_id': shopId});

  final response = await http.get(uri);

  if (response.statusCode != 200) {
    throw ApiException('Failed to fetch site config: ${response.statusCode}');
  }

  final decoded = jsonDecode(response.body);
  final json = safeExtractMap(decoded) ?? const {};
  return SiteConfig.fromJson(json);
}

class ApiException implements Exception {
  ApiException(this.message);
  final String message;
  @override
  String toString() => 'ApiException: $message';
}
