/// Safe JSON conversion utilities to prevent runtime type errors
/// when backend returns numbers, null, or objects instead of expected types.
library;

/// Safely converts any value to String. Never throws.
String safeStr(dynamic v) => v?.toString() ?? '';

/// Safely converts any value to int. Returns 0 on failure.
int safeInt(dynamic v) => int.tryParse(v?.toString() ?? '') ?? 0;

/// Safely converts any value to double. Returns 0 on failure.
double safeDouble(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0;

/// Returns non-empty string or null for optional String? fields.
String? safeStrOrNull(dynamic v) {
  final s = safeStr(v);
  return s.isEmpty ? null : s;
}

/// Safely extracts Map from JSON. Handles wrapped responses like {"data": {...}}.
Map<String, dynamic>? safeExtractMap(dynamic json) {
  if (json == null) return null;
  if (json is Map<String, dynamic>) return json;
  if (json is Map) return Map<String, dynamic>.from(json);
  // Handle wrapped responses
  if (json is Map && (json['data'] != null || json['result'] != null)) {
    final inner = json['data'] ?? json['result'];
    if (inner is Map<String, dynamic>) return inner;
    if (inner is Map) return Map<String, dynamic>.from(inner);
  }
  return null;
}

/// Safely extracts List from JSON. Handles wrapped responses.
List<dynamic>? safeExtractList(dynamic json) {
  if (json == null) return null;
  if (json is List) return json;
  if (json is Map && (json['data'] != null || json['items'] != null)) {
    final inner = json['data'] ?? json['items'];
    if (inner is List) return inner;
  }
  return null;
}
