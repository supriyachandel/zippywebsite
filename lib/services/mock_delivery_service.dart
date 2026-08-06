import 'dart:convert';
import 'package:http/http.dart' as http;
import 'mock_api_config.dart';

class MockDeliveryResult {
  final bool success;
  final String? deliveryId;
  final String? status;
  final String? estimatedDelivery;
  final Map<String, dynamic>? assignedAgent;
  final String? message;

  MockDeliveryResult({
    required this.success,
    this.deliveryId,
    this.status,
    this.estimatedDelivery,
    this.assignedAgent,
    this.message,
  });
}

class MockDeliveryTracking {
  final String deliveryId;
  final String status;
  final String? currentLocation;
  final String? estimatedDelivery;
  final String? agentPhone;
  final List<Map<String, dynamic>> updates;

  MockDeliveryTracking({
    required this.deliveryId,
    required this.status,
    this.currentLocation,
    this.estimatedDelivery,
    this.agentPhone,
    this.updates = const [],
  });

  factory MockDeliveryTracking.fromJson(Map<String, dynamic> json) {
    return MockDeliveryTracking(
      deliveryId: json['deliveryId'] ?? '',
      status: json['status'] ?? '',
      currentLocation: json['currentLocation'],
      estimatedDelivery: json['estimatedDelivery'],
      agentPhone: json['agentPhone'],
      updates: (json['updates'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
    );
  }
}

class MockDeliveryService {
  static Future<MockDeliveryResult> createDelivery({
    required String orderId,
    required String customerName,
    required String address,
    required String city,
    required String phone,
    String? weight,
    String? dimensions,
  }) async {
    final url = Uri.parse('${MockApiConfig.deliveryBaseUrl}/api/deliveries/create');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'orderId': orderId,
          'customerName': customerName,
          'address': address,
          'city': city,
          'phone': phone,
          if (weight != null) 'weight': weight,
          if (dimensions != null) 'dimensions': dimensions,
        }),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return MockDeliveryResult(
          success: true,
          deliveryId: body['deliveryId'],
          status: body['status'],
          estimatedDelivery: body['estimatedDelivery'],
          assignedAgent: body['assignedAgent'] as Map<String, dynamic>?,
        );
      } else {
        return MockDeliveryResult(
          success: false,
          message: body['message'] ?? 'Failed to create delivery',
        );
      }
    } catch (e) {
      return MockDeliveryResult(
        success: false,
        message: 'Connection error: $e',
      );
    }
  }

  static Future<MockDeliveryTracking?> getDeliveryStatus(String deliveryId) async {
    final url = Uri.parse('${MockApiConfig.deliveryBaseUrl}/api/deliveries/$deliveryId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return MockDeliveryTracking.fromJson(body['delivery'] as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<MockDeliveryTracking?> trackDelivery(String deliveryId) async {
    final url = Uri.parse('${MockApiConfig.deliveryBaseUrl}/api/track/$deliveryId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return MockDeliveryTracking.fromJson(body['tracking'] as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getDeliveryByOrderId(String orderId) async {
    final url = Uri.parse('${MockApiConfig.deliveryBaseUrl}/api/deliveries?orderId=$orderId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final deliveries = body['deliveries'] as List<dynamic>? ?? [];
        if (deliveries.isNotEmpty) {
          return deliveries.first as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
