import '../../services/mock_data.dart';
import '../../models/api_models.dart';

class StoreMockData {
  static const _shopId = 1;
  static int _nextPartnerId = 5;

  static final _shopData = {
    'id': _shopId,
    'name': 'Fashion Hub',
    'slug': 'fashion-hub',
    'description': 'Your one-stop fashion destination',
    'image': 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400',
    'status': 'active',
    'shop_number': 'SH-101',
    'address': 'MG Road, Indiranagar',
    'city': 'Bengaluru',
    'state': 'Karnataka',
    'zip': '560038',
    'country': 'India',
    'phone': '9876543210',
    'email': 'fashionhub@example.com',
    'instagram': '@fashionhub',
    'rating': '4.5',
    'user_id': 1,
    'created_at': '2025-01-01T00:00:00.000000Z',
    'updated_at': '2025-01-01T00:00:00.000000Z',
  };

  static Map<String, dynamic> get shopData => Map.from(_shopData);

  static List<ApiProduct> get shopProducts =>
      MockData.getProductsForShop(_shopId);

  static final List<Map<String, dynamic>> _orders = [
    {
      'id': 1,
      'user_id': 1,
      'shop_id': _shopId,
      'status': 'placed',
      'total_amount': '1598',
      'payment_method': 'COD',
      'payment_status': 'pending',
      'shipping_address': '123, MG Road, Bengaluru - 560001',
      'customer_name': 'Rahul Sharma',
      'customer_phone': '9876543210',
      'created_at': '2026-06-28T10:30:00.000000Z',
      'timeline': [
        {'status': 'placed', 'time': '2026-06-28T10:30:00.000000Z', 'note': 'Order placed by customer'},
      ],
      'products': [
        {'name': 'Classic Cotton T-Shirt', 'quantity': 2, 'price': '799'},
        {'name': 'Slim Fit Jeans', 'quantity': 1, 'price': '799'},
      ],
    },
    {
      'id': 2,
      'user_id': 2,
      'shop_id': _shopId,
      'status': 'accepted',
      'total_amount': '2499',
      'payment_method': 'Razorpay',
      'payment_status': 'paid',
      'shipping_address': '456, Koramangala, Bengaluru - 560095',
      'customer_name': 'Priya Patel',
      'customer_phone': '9876543211',
      'created_at': '2026-06-27T14:20:00.000000Z',
      'timeline': [
        {'status': 'placed', 'time': '2026-06-27T14:20:00.000000Z', 'note': 'Order placed by customer'},
        {'status': 'accepted', 'time': '2026-06-27T16:30:00.000000Z', 'note': 'Order accepted by store'},
      ],
      'products': [
        {'name': 'Leather Formal Shoes', 'quantity': 1, 'price': '2499'},
      ],
    },
    {
      'id': 3,
      'user_id': 3,
      'shop_id': _shopId,
      'status': 'shipped',
      'total_amount': '3499',
      'payment_method': 'Razorpay',
      'payment_status': 'paid',
      'shipping_address': '789, Indiranagar, Bengaluru - 560038',
      'customer_name': 'Amit Singh',
      'customer_phone': '9876543212',
      'created_at': '2026-06-26T09:15:00.000000Z',
      'delivery_assigned': true,
      'tracking_number': 'TRK123456789',
      'tracking_courier': 'Delhivery',
      'delivery_partner': {
        'id': 1,
        'name': 'Rohan Sharma',
        'phone': '9988776655',
        'vehicle': 'Hero Splendor',
      },
      'timeline': [
        {'status': 'placed', 'time': '2026-06-26T09:15:00.000000Z', 'note': 'Order placed by customer'},
        {'status': 'accepted', 'time': '2026-06-26T10:00:00.000000Z', 'note': 'Order accepted by store'},
        {'status': 'shipped', 'time': '2026-06-26T14:00:00.000000Z', 'note': 'Order shipped via Delhivery'},
      ],
      'products': [
        {'name': 'Running Shoes', 'quantity': 1, 'price': '2499'},
        {'name': 'Cotton T-Shirt Pack', 'quantity': 1, 'price': '1000'},
      ],
    },
    {
      'id': 4,
      'user_id': 4,
      'shop_id': _shopId,
      'status': 'delivered',
      'total_amount': '5999',
      'payment_method': 'Razorpay',
      'payment_status': 'paid',
      'shipping_address': '321, JP Nagar, Bengaluru - 560078',
      'customer_name': 'Neha Gupta',
      'customer_phone': '9876543213',
      'created_at': '2026-06-24T16:45:00.000000Z',
      'delivery_assigned': true,
      'tracking_number': 'TRK987654321',
      'tracking_courier': 'Blue Dart',
      'delivery_partner': {
        'id': 2,
        'name': 'Vikram Yadav',
        'phone': '9988776644',
        'vehicle': 'Activa',
      },
      'timeline': [
        {'status': 'placed', 'time': '2026-06-24T16:45:00.000000Z', 'note': 'Order placed by customer'},
        {'status': 'accepted', 'time': '2026-06-24T17:30:00.000000Z', 'note': 'Order accepted by store'},
        {'status': 'shipped', 'time': '2026-06-25T09:00:00.000000Z', 'note': 'Order shipped via Blue Dart'},
        {'status': 'delivered', 'time': '2026-06-26T14:00:00.000000Z', 'note': 'Order delivered successfully'},
      ],
      'products': [
        {'name': 'Designer Kurta Set', 'quantity': 1, 'price': '3999'},
        {'name': 'Earrings Set', 'quantity': 2, 'price': '1000'},
      ],
    },
  ];

  static List<Map<String, dynamic>> get orders =>
      _orders.map((o) => Map<String, dynamic>.from(o)).toList();

  static final List<Map<String, dynamic>> _deliveryPartners = [
    {'id': 1, 'name': 'Rohan Sharma', 'phone': '9988776655', 'vehicle': 'Hero Splendor', 'rating': 4.9, 'active': true},
    {'id': 2, 'name': 'Vikram Yadav', 'phone': '9988776644', 'vehicle': 'Activa', 'rating': 4.7, 'active': true},
    {'id': 3, 'name': 'Suresh Kumar', 'phone': '9988776633', 'vehicle': 'Bajaj Pulsar', 'rating': 4.5, 'active': false},
    {'id': 4, 'name': 'Amit Verma', 'phone': '9988776622', 'vehicle': 'TVS Jupiter', 'rating': 4.8, 'active': true},
  ];

  static List<Map<String, dynamic>> get deliveryPartners =>
      _deliveryPartners.map((p) => Map<String, dynamic>.from(p)).toList();

  static int get _nextPartnerIdValue {
    final result = _nextPartnerId;
    _nextPartnerId++;
    return result;
  }

  static List<int> get availableSubCategoryIds {
    final ids = shopProducts.map((p) => p.subCategoryId).toSet().toList();
    ids.sort();
    return ids;
  }

  static Map<String, dynamic> getShopStats(int shopId) {
    final totalOrders = orders.length;
    final totalRevenue = _orders.fold<double>(
      0, (sum, o) => sum + (double.tryParse(o['total_amount']?.toString() ?? '0') ?? 0),
    );
    final lowStock = shopProducts.where((p) {
      final qty = int.tryParse(p.quantity ?? '0') ?? 0;
      return qty > 0 && qty <= 10;
    }).length;
    final outOfStock = shopProducts.where((p) {
      final qty = int.tryParse(p.quantity ?? '0') ?? 0;
      return qty == 0;
    }).length;
    final pendingOrders = _orders.where((o) {
      final s = o['status']?.toString().toLowerCase() ?? '';
      return s == 'placed' || s == 'pending' || s == 'processing';
    }).length;
    final deliveredOrders = _orders.where((o) => o['status']?.toString().toLowerCase() == 'delivered').length;

    return {
      'total_products': shopProducts.length,
      'total_orders': totalOrders,
      'shop_name': 'Fashion Hub',
      'shop_image': _shopData['image'],
      'rating': '4.5',
      'total_revenue': totalRevenue >= 1000
          ? '₹${(totalRevenue / 1000).toStringAsFixed(1)}k'
          : '₹${totalRevenue.toStringAsFixed(0)}',
      'low_stock': lowStock,
      'out_of_stock': outOfStock,
      'pending_orders': pendingOrders,
      'delivered_orders': deliveredOrders,
    };
  }

  static Map<String, dynamic> getOrderDetails(int orderId) {
    final order = _orders.where((o) => o['id'] == orderId).firstOrNull;
    if (order == null) return {'error': 'Order not found'};
    return Map<String, dynamic>.from(order);
  }

  static bool updateOrderStatus(int orderId, String status) {
    final order = _orders.where((o) => o['id'] == orderId).firstOrNull;
    if (order == null) return false;
    order['status'] = status;
    final raw = order['timeline'];
    final timeline = raw is List ? List<Map<String, dynamic>>.from(raw) : <Map<String, dynamic>>[];
    timeline.add({
      'status': status,
      'time': DateTime.now().toUtc().toIso8601String(),
      'note': _timelineNote(status),
    });
    order['timeline'] = timeline;
    return true;
  }

  static bool assignDeliveryToOrder(int orderId, Map<String, dynamic> partner) {
    final order = _orders.where((o) => o['id'] == orderId).firstOrNull;
    if (order == null) return false;
    order['delivery_assigned'] = true;
    order['delivery_partner'] = Map<String, dynamic>.from(partner);
    final raw = order['timeline'];
    final timeline = raw is List ? List<Map<String, dynamic>>.from(raw) : <Map<String, dynamic>>[];
    timeline.add({
      'status': order['status'],
      'time': DateTime.now().toUtc().toIso8601String(),
      'note': 'Delivery assigned to ${partner['name']}',
    });
    order['timeline'] = timeline;
    return true;
  }

  static bool addTrackingToOrder(int orderId, String courier, String trackingNumber) {
    final order = _orders.where((o) => o['id'] == orderId).firstOrNull;
    if (order == null) return false;
    order['tracking_courier'] = courier;
    order['tracking_number'] = trackingNumber;
    final raw = order['timeline'];
    final timeline = raw is List ? List<Map<String, dynamic>>.from(raw) : <Map<String, dynamic>>[];
    timeline.add({
      'status': order['status'],
      'time': DateTime.now().toUtc().toIso8601String(),
      'note': 'Tracking added: $courier ($trackingNumber)',
    });
    order['timeline'] = timeline;
    return true;
  }

  static String _timelineNote(String status) {
    switch (status.toLowerCase()) {
      case 'accepted': return 'Order accepted by store';
      case 'rejected': return 'Order rejected by store';
      case 'shipped': return 'Order shipped';
      case 'delivered': return 'Order delivered successfully';
      case 'cancelled': return 'Order cancelled';
      default: return 'Status changed to $status';
    }
  }

  static Map<String, dynamic> createDeliveryPartner(Map<String, dynamic> data) {
    final partner = Map<String, dynamic>.from(data);
    partner['id'] = _nextPartnerIdValue;
    partner['rating'] = 5.0;
    if (partner['active'] == null) partner['active'] = true;
    _deliveryPartners.add(partner);
    return Map<String, dynamic>.from(partner);
  }

  static Map<String, dynamic>? updateDeliveryPartner(int id, Map<String, dynamic> data) {
    final index = _deliveryPartners.indexWhere((p) => p['id'] == id);
    if (index == -1) return null;
    _deliveryPartners[index].addAll(data);
    return Map<String, dynamic>.from(_deliveryPartners[index]);
  }

  static bool toggleDeliveryPartner(int id) {
    final index = _deliveryPartners.indexWhere((p) => p['id'] == id);
    if (index == -1) return false;
    _deliveryPartners[index]['active'] = !(_deliveryPartners[index]['active'] == true);
    return true;
  }

  static Map<String, dynamic> productToMap(ApiProduct p) => {
    'id': p.id,
    'name': p.name,
    'price': p.price,
    'discount_price': p.discountPrice,
    'quantity': p.quantity,
    'sku': p.sku,
    'size': p.size,
    'description': p.description,
    'image': p.image,
    'image_urls': p.imageUrls,
    'sub_category_id': p.subCategoryId,
    'shop_id': p.shopId,
    'user_id': p.userId,
    'gender': p.gender,
    'status': p.status,
    'created_at': p.createdAt,
    'updated_at': p.updatedAt,
  };

  static List<Map<String, dynamic>> get shopProductMaps =>
      shopProducts.map(productToMap).toList();
}
