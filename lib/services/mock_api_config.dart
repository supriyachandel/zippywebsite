import 'dart:io' show Platform;

class MockApiConfig {
  static String get paymentBaseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3001';
    }
    return 'http://localhost:3001';
  }

  static String get deliveryBaseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3002';
    }
    return 'http://localhost:3002';
  }
}
