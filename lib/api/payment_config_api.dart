import 'dart:convert';

import 'package:http/http.dart' as http;

import '../api/api_config.dart';
import '../utils/json_utils.dart';

class PaymentConfig {
  PaymentConfig({
    required this.paymentEnabled,
    this.razorpayKey,
  });

  factory PaymentConfig.fromJson(Map<String, dynamic> json) {
    final enabledValue = json['payment_enabled'];
    final enabledStr = safeStr(enabledValue).toLowerCase();
    final enabled = enabledValue == true ||
        enabledValue == 1 ||
        enabledStr == 'true' ||
        enabledStr == 'yes';

    final key = safeStr(json['razorpay_key']).isEmpty
        ? safeStr(json['razorpay_key_id'])
        : safeStr(json['razorpay_key']);

    return PaymentConfig(
      paymentEnabled: enabled,
      razorpayKey: key.isEmpty ? null : key,
    );
  }

  final bool paymentEnabled;
  final String? razorpayKey;
}

class PaymentConfigApiException implements Exception {
  PaymentConfigApiException(this.message);
  final String message;
  @override
  String toString() => 'PaymentConfigApiException: $message';
}

/// GET /sites/payment-config?shop_id=
Future<PaymentConfig> fetchPaymentConfig(String shopId) async {
  final uri = Uri.parse('${ApiConfig.baseUrl}/sites/payment-config')
      .replace(queryParameters: {'shop_id': shopId});

  final response = await http.get(uri);

  if (response.statusCode != 200) {
    throw PaymentConfigApiException(
      'Failed to fetch payment config: ${response.statusCode}',
    );
  }

  final decoded = jsonDecode(response.body);
  Map<String, dynamic> json;
  if (decoded is Map<String, dynamic>) {
    json = decoded;
  } else if (decoded is Map) {
    json = Map<String, dynamic>.from(decoded);
  } else {
    json = const {};
  }

  return PaymentConfig.fromJson(json);
}

