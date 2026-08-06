import '../../services/mock_data.dart';
import 'store_mock_data.dart';

class ShiprocketService {
  static bool useMock = true;

  static const _couriers = [
    {'id': 1, 'name': 'Delhivery', 'etd': '2-4 days', 'rate': 65, 'rating': 4.3},
    {'id': 2, 'name': 'Blue Dart', 'etd': '2-3 days', 'rate': 89, 'rating': 4.6},
    {'id': 3, 'name': 'DTDC', 'etd': '3-5 days', 'rate': 55, 'rating': 3.9},
    {'id': 4, 'name': 'Ekart', 'etd': '3-4 days', 'rate': 45, 'rating': 4.0},
    {'id': 5, 'name': 'XpressBees', 'etd': '2-4 days', 'rate': 59, 'rating': 4.2},
  ];

  static int _nextShipmentId = 1001;

  /// Fetch available couriers for a given delivery pincode
  static Future<List<Map<String, dynamic>>> getAvailableCouriers(String deliveryPincode) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _couriers.map((c) => Map<String, dynamic>.from(c)).toList();
    }
    // Real: GET /api/shiprocket/couriers?delivery_pincode=...
    throw UnimplementedError('Real ShipRocket API not configured');
  }

  /// Create a shipment via ShipRocket
  static Future<Map<String, dynamic>> createShipment({
    required int orderId,
    required String orderNumber,
    required String pickupName,
    required String pickupAddress,
    required String pickupCity,
    required String pickupState,
    required String pickupZip,
    required String pickupPhone,
    required String deliveryName,
    required String deliveryAddress,
    required String deliveryCity,
    required String deliveryState,
    required String deliveryZip,
    required String deliveryPhone,
    required double weight,
    required int courierId,
    required double orderAmount,
    required List<Map<String, dynamic>> orderItems,
  }) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      final shipmentId = _nextShipmentId++;
      final courier = _couriers.firstWhere((c) => c['id'] == courierId, orElse: () => _couriers[0]);
      final awb = 'SHPT${DateTime.now().millisecondsSinceEpoch}';

      // Update order with tracking info
      StoreMockData.addTrackingToOrder(orderId, courier['name'].toString(), awb);
      StoreMockData.assignDeliveryToOrder(orderId, {
        'id': courier['id'],
        'name': '${courier['name']} (ShipRocket)',
        'phone': '1800-123-4567',
        'vehicle': 'Logistics',
      });
      StoreMockData.updateOrderStatus(orderId, 'shipped');

      return {
        'shipment_id': shipmentId,
        'awb': awb,
        'courier_name': courier['name'],
        'courier_id': courierId,
        'status': 'shipped',
        'label_url': 'https://shiprocket.in/label/$awb',
        'manifest_url': 'https://shiprocket.in/manifest/$awb',
        'pickup_id': shipmentId + 1000,
        'tracking_url': 'https://shiprocket.in/tracking/$awb',
      };
    }
    // Real: POST /api/shiprocket/shipments/create
    throw UnimplementedError('Real ShipRocket API not configured');
  }

  /// Generate pickup request after shipment creation
  static Future<Map<String, dynamic>> generatePickupRequest(int shipmentId) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return {
        'pickup_id': shipmentId + 1000,
        'status': 'pickup_scheduled',
        'pickup_date': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
      };
    }
    // Real: POST /api/shiprocket/pickup-request
    throw UnimplementedError('Real ShipRocket API not configured');
  }

  /// Generate shipping label
  static Future<String> generateLabel(int shipmentId) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return 'https://shiprocket.in/label/SHPT$shipmentId';
    }
    // Real: POST /api/shiprocket/label
    throw UnimplementedError('Real ShipRocket API not configured');
  }

  /// Generate manifest
  static Future<String> generateManifest(int shipmentId) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return 'https://shiprocket.in/manifest/SHPT$shipmentId';
    }
    // Real: POST /api/shiprocket/manifest
    throw UnimplementedError('Real ShipRocket API not configured');
  }

  /// Track shipment by AWB
  static Future<Map<String, dynamic>> trackShipment(String awb) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {
        'awb': awb,
        'status': 'in_transit',
        'current_status': 'Shipment picked up',
        'tracking_data': [
          {'location': 'Bengaluru Hub', 'status': 'Picked Up', 'time': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String()},
          {'location': 'Bengaluru Hub', 'status': 'In Transit', 'time': DateTime.now().toIso8601String()},
        ],
        'estimated_delivery': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
      };
    }
    // Real: GET /api/shiprocket/tracking?awb=...
    throw UnimplementedError('Real ShipRocket API not configured');
  }

  /// Cancel shipment
  static Future<bool> cancelShipment(int shipmentId) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return true;
    }
    // Real: POST /api/shiprocket/shipments/cancel
    throw UnimplementedError('Real ShipRocket API not configured');
  }
}
