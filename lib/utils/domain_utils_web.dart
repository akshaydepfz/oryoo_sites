// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

/// Web implementation using dart:html.
String getCurrentDomain() {
  return html.window.location.host;
}
