import 'dart:convert';

import 'package:http/http.dart' as http;

import '../api/api_config.dart';
import '../models/site_config.dart';
import '../models/testimonial.dart';
import '../utils/json_utils.dart';

/// Fetches about page content for a shop.
/// GET /sites/about?shop_id=
Future<AboutPageData> fetchAboutPage(String shopId) async {
  final uri = Uri.parse('${ApiConfig.baseUrl}/sites/about')
      .replace(queryParameters: {'shop_id': shopId});

  final response = await http.get(uri);

  if (response.statusCode != 200) {
    throw ApiException('Failed to fetch about page: ${response.statusCode}');
  }

  final decoded = jsonDecode(response.body);
  final json = safeExtractMap(decoded) ?? const {};
  return AboutPageData.fromJson(json);
}

/// Fetches contact page content for a shop.
/// GET /sites/contact?shop_id=
Future<ContactPageData> fetchContactPage(String shopId) async {
  final uri = Uri.parse('${ApiConfig.baseUrl}/sites/contact')
      .replace(queryParameters: {'shop_id': shopId});

  final response = await http.get(uri);

  if (response.statusCode != 200) {
    throw ApiException('Failed to fetch contact page: ${response.statusCode}');
  }

  final decoded = jsonDecode(response.body);
  final json = safeExtractMap(decoded) ?? const {};
  return ContactPageData.fromJson(json);
}

/// Fetches testimonials for a shop.
/// GET /sites/testimonials?shop_id=
Future<List<Testimonial>> fetchTestimonials(String shopId) async {
  final uri = Uri.parse('${ApiConfig.baseUrl}/sites/testimonials')
      .replace(queryParameters: {'shop_id': shopId});

  final response = await http.get(uri);

  if (response.statusCode != 200) {
    throw ApiException('Failed to fetch testimonials: ${response.statusCode}');
  }

  final decoded = jsonDecode(response.body);
  final list = safeExtractList(decoded) ?? (decoded is List ? decoded : <dynamic>[]);
  return list
      .whereType<Map>()
      .map((e) => Testimonial.fromJson(Map<String, dynamic>.from(e)))
      .toList();
}

class ApiException implements Exception {
  ApiException(this.message);
  final String message;
  @override
  String toString() => 'ApiException: $message';
}
