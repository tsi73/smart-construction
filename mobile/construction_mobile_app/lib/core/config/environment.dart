import 'package:flutter/foundation.dart';

enum Environment {
  dev,
  prod,
}

class AppConfig {
  static Environment environment = Environment.prod;

  static const String _prodBaseUrl = 'https://13-63-178-41.nip.io/api/v1/';

  static String get baseUrl {
    if (environment == Environment.prod) {
      return _prodBaseUrl;
    }

    // Dev URLs
    if (kIsWeb) {
      final host = Uri.base.host;
      final isLocalHost = host.isEmpty ||
          host == 'localhost' ||
          host == '127.0.0.1' ||
          host == '::1';
      final apiHost = isLocalHost ? '127.0.0.1' : host;
      return 'http://$apiHost:8000/api/v1/';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://192.168.2.185:8000/api/v1/';
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
        return 'http://127.0.0.1:8000/api/v1/';
      default:
        return 'http://127.0.0.1:8000/api/v1/';
    }
  }

  static String get apiOrigin => baseUrl.replaceFirst('/api/v1/', '');

  static const String appName = 'Foresite';
  static const String appVersion = '1.0.0';
}