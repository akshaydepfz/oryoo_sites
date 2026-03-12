import 'domain_utils_stub.dart'
    if (dart.library.html) 'domain_utils_web.dart' as domain_impl;

/// Returns the current domain (e.g. goldpalace.oryoo.in).
/// Uses dart:html on web, returns empty string on other platforms.
String getCurrentDomain() {
  return domain_impl.getCurrentDomain();
}
