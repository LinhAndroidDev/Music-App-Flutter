import 'dart:io';

import 'package:flutter/foundation.dart';

class _DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (_, __, ___) => true;
  }
}

/// Dev-only: iOS Simulator / proxy environments may fail TLS verify for CDN images.
void configureDevHttpOverrides() {
  if (kDebugMode) {
    HttpOverrides.global = _DevHttpOverrides();
  }
}
