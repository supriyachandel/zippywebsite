import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../services/prefs_service.dart';
import '../../services/mock_data.dart';
import 'store_mock_data.dart';

class StoreApiService {
  static const String baseUrl = 'https://fascism-bullseye-perjury.ngrok-free.dev/api';
  static bool useMock = true;
  static String? _token;
  static int? _shopId;

  static Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  static Future<void> setToken(String? token) async {
    _token = token;
    if (token != null) {
      await PrefsService.setString('auth_token', token);
    } else {
      await PrefsService.remove('auth_token');
    }
  }

  static Future<String?> loadToken() async {
    _token = await PrefsService.getString('auth_token');
    return _token;
  }

  static int? get shopId => _shopId;

  static Future<void> setShopId(int? id) async {
    _shopId = id;
    if (id != null) {
      await PrefsService.setInt('shop_id', id);
    } else {
      await PrefsService.remove('shop_id');
    }
  }

  static Future<int?> loadShopId() async {
    _shopId = await PrefsService.getInt('shop_id');
    return _shopId;
  }

  static String? get token => _token;

  static Future<Map<String, dynamic>> createShop(Map<String, dynamic> shopData) async {
    if (useMock) {
      await setShopId(1);
      await PrefsService.setString('shop_data', jsonEncode(StoreMockData.shopData));
      return {'shop': StoreMockData.shopData};
    }
    final url = Uri.parse('$baseUrl/shop/create');
    final response = await http.post(url, headers: _headers, body: jsonEncode(shopData));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final shop = data['shop'] ?? data['data'] ?? data;
      final id = shop['id'];
      if (id != null) {
        await setShopId(int.tryParse(id.toString()));
      }
      // Save full shop data to prefs
      await PrefsService.setString('shop_data', jsonEncode(shop is Map ? shop : data));
      return data;
    } else {
      final body = response.body.length > 200 ? '${response.body.substring(0, 200)}...' : response.body;
      throw Exception('Failed to create shop: ${response.statusCode} ($body)');
    }
  }

  /// Save shop data to local prefs (called after shop creation)
  static Future<void> saveShopData(Map<String, dynamic> shop) async {
    await PrefsService.setString('shop_data', jsonEncode(shop));
  }

  /// Load shop data from local prefs
  static Future<Map<String, dynamic>?> getSavedShopData() async {
    final raw = await PrefsService.getString('shop_data');
    if (raw != null && raw.isNotEmpty) {
      return jsonDecode(raw) as Map<String, dynamic>;
    }
    return null;
  }

  /// Find the user's shop from /api/shops list
  static Future<Map<String, dynamic>?> getUserShop() async {
    if (useMock) {
      await setShopId(1);
      await saveShopData(StoreMockData.shopData);
      return StoreMockData.shopData;
    }
    try {
      final url = Uri.parse('$baseUrl/shops');
      final response = await http.get(url, headers: _headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final shops = data['shops'] as List<dynamic>? ?? [];
        if (shops.isNotEmpty && shops.first is Map<String, dynamic>) {
          final shop = shops.first as Map<String, dynamic>;
          await saveShopData(shop);
          final sid = shop['id'];
          if (sid != null) await setShopId(int.tryParse(sid.toString()));
          return shop;
        }
      }
    } catch (_) {}
    return null;
  }

  static Future<Map<String, dynamic>> getShopDetails(int id) async {
    if (useMock) return {'shop': StoreMockData.shopData};
    try {
      final url = Uri.parse('$baseUrl/shop/$id');
      final response = await http.get(url, headers: _headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final shop = data['shop'] ?? data['data'] ?? data;
        if (shop is Map<String, dynamic>) await saveShopData(shop);
        return data;
      }
    } catch (_) {}
    final saved = await getSavedShopData();
    if (saved != null) return {'shop': saved};
    final fallback = await getUserShop();
    if (fallback != null) return {'shop': fallback};
    throw Exception('Shop data not available. Create a shop first.');
  }

  static Future<List<dynamic>> getShopProducts(int id) async {
    if (useMock) return StoreMockData.shopProductMaps;
    final url = Uri.parse('$baseUrl/shop/$id/products');
    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['products'] as List<dynamic>? ?? [];
    } else {
      throw Exception('Failed to load shop products: ${response.statusCode}');
    }
  }

  static Future<List<dynamic>> getCategories() async {
    if (useMock) {
      final data = MockData.categories.map((c) => {
        'id': c.id, 'category_name': c.categoryName, 'slug': c.slug,
        'description': c.description, 'image': c.image, 'category_id': c.categoryId,
        'gender': c.gender, 'created_at': c.createdAt, 'updated_at': c.updatedAt,
      }).toList();
      return data;
    }
    final url = Uri.parse('$baseUrl/categories');
    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['categories'] as List<dynamic>? ?? [];
    } else {
      throw Exception('Failed to load categories: ${response.statusCode}');
    }
  }

  static Future<List<int>> getAvailableSubCategoryIds() async {
    if (useMock) return StoreMockData.availableSubCategoryIds;
    final url = Uri.parse('$baseUrl/products');
    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final products = data['products'] as List<dynamic>? ?? [];
      final ids = products
          .map((p) => (p as Map<String, dynamic>)['sub_category_id'])
          .whereType<int>()
          .toSet()
          .toList();
      ids.sort();
      return ids;
    }
    return [];
  }

  static Future<List<dynamic>> getShopOrders(int shopId) async {
    if (useMock) return StoreMockData.orders;
    final url = Uri.parse('$baseUrl/shop/$shopId/orders');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['orders'] as List<dynamic>? ?? [];
    }
    return [];
  }

  static Future<Map<String, dynamic>> getOrderDetails(int orderId) async {
    if (useMock) return StoreMockData.getOrderDetails(orderId);
    final url = Uri.parse('$baseUrl/orders/$orderId');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['order'] as Map<String, dynamic>? ?? data;
    }
    return {};
  }

  static Future<bool> acceptOrder(int orderId) async {
    if (useMock) return StoreMockData.updateOrderStatus(orderId, 'accepted');
    final url = Uri.parse('$baseUrl/orders/$orderId/accept');
    final response = await http.patch(url, headers: _headers);
    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<bool> rejectOrder(int orderId) async {
    if (useMock) return StoreMockData.updateOrderStatus(orderId, 'rejected');
    final url = Uri.parse('$baseUrl/orders/$orderId/reject');
    final response = await http.patch(url, headers: _headers);
    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<bool> updateOrderStatus(int orderId, String status) async {
    if (useMock) return StoreMockData.updateOrderStatus(orderId, status);
    final url = Uri.parse('$baseUrl/orders/$orderId/status');
    final response = await http.patch(url, headers: _headers, body: jsonEncode({'status': status}));
    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<List<dynamic>> getDeliveryPartners() async {
    if (useMock) return StoreMockData.deliveryPartners;
    final url = Uri.parse('$baseUrl/delivery-partners');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['partners'] as List<dynamic>? ?? [];
    }
    return [];
  }

  static Future<bool> assignDeliveryPartner(int orderId, int partnerId) async {
    if (useMock) {
      final partners = StoreMockData.deliveryPartners;
      final partner = partners.where((p) => p['id'] == partnerId).firstOrNull;
      if (partner == null) return false;
      return StoreMockData.assignDeliveryToOrder(orderId, partner);
    }
    final url = Uri.parse('$baseUrl/orders/$orderId/assign-delivery');
    final response = await http.post(url, headers: _headers, body: jsonEncode({'partner_id': partnerId}));
    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<bool> addTrackingInfo(int orderId, String courier, String trackingNumber) async {
    if (useMock) return StoreMockData.addTrackingToOrder(orderId, courier, trackingNumber);
    final url = Uri.parse('$baseUrl/orders/$orderId/tracking');
    final response = await http.post(url, headers: _headers, body: jsonEncode({
      'courier': courier,
      'tracking_number': trackingNumber,
    }));
    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<Map<String, dynamic>> createDeliveryPartner(Map<String, dynamic> data) async {
    if (useMock) return StoreMockData.createDeliveryPartner(data);
    final url = Uri.parse('$baseUrl/delivery-partners/create');
    final response = await http.post(url, headers: _headers, body: jsonEncode(data));
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body)['partner'] ?? jsonDecode(response.body);
    }
    throw Exception('Failed to create delivery partner');
  }

  static Future<Map<String, dynamic>?> updateDeliveryPartner(int id, Map<String, dynamic> data) async {
    if (useMock) return StoreMockData.updateDeliveryPartner(id, data);
    final url = Uri.parse('$baseUrl/delivery-partners/$id');
    final response = await http.put(url, headers: _headers, body: jsonEncode(data));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['partner'] ?? jsonDecode(response.body);
    }
    return null;
  }

  static Future<bool> toggleDeliveryPartner(int id) async {
    if (useMock) return StoreMockData.toggleDeliveryPartner(id);
    final url = Uri.parse('$baseUrl/delivery-partners/$id/toggle');
    final response = await http.patch(url, headers: _headers);
    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>> getShopStats(int shopId) async {
    try {
      final products = await getShopProducts(shopId);
      final orders = await getShopOrders(shopId);
      final shop = await getShopDetails(shopId);
      final shopData = shop['shop'] ?? shop['data'] ?? shop;
      return {
        'total_products': products.length,
        'total_orders': orders.length,
        'shop_name': shopData['name']?.toString() ?? 'My Shop',
        'shop_image': shopData['image']?.toString(),
        'rating': shopData['rating']?.toString() ?? '4.5',
        'total_revenue': _computeRevenue(orders),
        'low_stock': 0,
        'out_of_stock': 0,
        'pending_orders': orders.where((o) {
          final s = (o as Map<String, dynamic>)['status']?.toString().toLowerCase() ?? '';
          return s == 'placed' || s == 'pending' || s == 'processing';
        }).length,
        'delivered_orders': orders.where((o) {
          final s = (o as Map<String, dynamic>)['status']?.toString().toLowerCase() ?? '';
          return s == 'delivered';
        }).length,
      };
    } catch (_) {
      return {'total_products': 0, 'total_orders': 0, 'shop_name': 'My Shop', 'rating': '0', 'total_revenue': '0'};
    }
  }

  static String _computeRevenue(List<dynamic> orders) {
    double total = 0;
    for (final o in orders) {
      final amt = (o as Map<String, dynamic>)['total_amount'];
      if (amt != null) total += double.tryParse(amt.toString()) ?? 0;
    }
    if (total >= 1000) return '₹${(total / 1000).toStringAsFixed(1)}k';
    return '₹${total.toStringAsFixed(0)}';
  }

  static Future<Map<String, dynamic>> updateProduct(int productId, {
    required Map<String, dynamic> productData,
    List<File>? imageFiles,
  }) async {
    if (useMock) return {'product': productData, 'id': productId, 'status': 'updated'};
    final url = Uri.parse('$baseUrl/product/update/$productId');
    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $_token';
    request.headers['Accept'] = 'application/json';

    productData.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value.toString();
      }
    });

    if (imageFiles != null && imageFiles.isNotEmpty) {
      for (int i = 0; i < imageFiles.length; i++) {
        request.files.add(await http.MultipartFile.fromPath('image[$i]', imageFiles[i].path));
      }
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final body = response.body.length > 500 ? '${response.body.substring(0, 500)}...' : response.body;
      throw Exception('Failed to update product: ${response.statusCode} ($body)');
    }
  }

  static Future<bool> deleteProduct(int productId) async {
    if (useMock) return true;
    final url = Uri.parse('$baseUrl/product/delete/$productId');
    final response = await http.delete(url, headers: _headers);
    return response.statusCode == 200 || response.statusCode == 204;
  }

  static Future<Map<String, dynamic>> updateShop(int id, Map<String, dynamic> shopData, {File? imageFile}) async {
    if (useMock) return {'shop': {...StoreMockData.shopData, ...shopData}};
    final url = Uri.parse('$baseUrl/shop/update/$id');

    if (imageFile != null) {
      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $_token';
      request.headers['Accept'] = 'application/json';
      shopData.forEach((key, value) {
        if (value != null) request.fields[key] = value.toString();
      });
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final shop = data['shop'] ?? data['data'] ?? data;
        if (shop is Map<String, dynamic>) await saveShopData(shop);
        return data;
      } else {
        final body = response.body.length > 200 ? '${response.body.substring(0, 200)}...' : response.body;
        throw Exception('Failed to update shop: ${response.statusCode} ($body)');
      }
    }

    final response = await http.post(url, headers: _headers, body: jsonEncode(shopData));
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final shop = data['shop'] ?? data['data'] ?? data;
      if (shop is Map<String, dynamic>) {
        await saveShopData(shop);
      }
      return data;
    } else {
      final body = response.body.length > 200 ? '${response.body.substring(0, 200)}...' : response.body;
      throw Exception('Failed to update shop: ${response.statusCode} ($body)');
    }
  }

  static Future<bool> deleteShop(int id) async {
    final url = Uri.parse('$baseUrl/shop/delete/$id');
    final response = await http.delete(url, headers: _headers);
    if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
      return true;
    }
    final body = response.body.length > 200 ? '${response.body.substring(0, 200)}...' : response.body;
    throw Exception('Failed to delete shop (${response.statusCode}): $body');
  }

  static Future<Map<String, dynamic>> createProduct({
    required Map<String, dynamic> productData,
    List<File>? imageFiles,
  }) async {
    if (useMock) {
      productData['id'] = DateTime.now().millisecondsSinceEpoch;
      return productData;
    }
    final url = Uri.parse('$baseUrl/product/create');
    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $_token';
    request.headers['Accept'] = 'application/json';

    productData.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value.toString();
      }
    });

    if (imageFiles != null && imageFiles.isNotEmpty) {
      for (int i = 0; i < imageFiles.length; i++) {
        request.files.add(await http.MultipartFile.fromPath('image[$i]', imageFiles[i].path));
      }
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final body = response.body.length > 500 ? '${response.body.substring(0, 500)}...' : response.body;
      throw Exception('Failed to create product: ${response.statusCode} ($body)');
    }
  }
}
