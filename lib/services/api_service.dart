import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'prefs_service.dart';
import '../models/api_models.dart';
import 'mock_data.dart';

class ApiService {
  static String get _host => Platform.isAndroid ? '10.0.2.2' : 'localhost';
  static String get baseUrl => 'http://${_host}:3000/api';
  static String get baseDomain => 'http://$_host:3000';
  static String? _token;
  static bool useMock = true;

  static String resolveImage(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final clean = path.startsWith('/') ? path.substring(1) : path;
    final withStorage = clean.startsWith('storage/') ? clean : 'storage/$clean';
    final resolved = '$baseDomain/$withStorage';
    debugPrint('resolveImage: "$path" -> "$resolved"');
    return resolved;
  }

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

  static Future<List<ApiProduct>> getProducts() async {
    if (useMock) return MockData.products;
    final url = Uri.parse('$baseUrl/products');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final productsList = data['products'] as List<dynamic>? ?? [];
      return productsList.map((json) => ApiProduct.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      final body = response.body.length > 200 ? '${response.body.substring(0, 200)}...' : response.body;
      throw Exception('Failed to load products: ${response.statusCode} ($body)');
    }
  }

  static Future<List<ApiCategory>> getCategories() async {
    if (useMock) return MockData.categories;
    final url = Uri.parse('$baseUrl/categories');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final categoriesList = data['categories'] as List<dynamic>? ?? [];
      return categoriesList.map((json) => ApiCategory.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      final body = response.body.length > 200 ? '${response.body.substring(0, 200)}...' : response.body;
      throw Exception('Failed to load categories: ${response.statusCode} ($body)');
    }
  }

  static Future<List<ApiCategory>> getSubCategories() async {
    if (useMock) return MockData.subCategories;
    final url = Uri.parse('$baseUrl/sub/categories');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data['sub_categories'] as List<dynamic>? ?? data['categories'] as List<dynamic>? ?? [];
      return list.map((json) => ApiCategory.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      final body = response.body.length > 200 ? '${response.body.substring(0, 200)}...' : response.body;
      throw Exception('Failed to load subcategories (${response.statusCode}): $body');
    }
  }

  static Future<List<ApiShop>> getShops() async {
    if (useMock) return MockData.shops;
    final url = Uri.parse('$baseUrl/shops');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final shopsList = data['shops'] as List<dynamic>? ?? [];
      return shopsList.map((json) => ApiShop.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      final body = response.body.length > 200 ? '${response.body.substring(0, 200)}...' : response.body;
      throw Exception('Failed to load shops: ${response.statusCode} ($body)');
    }
  }

  static Future<List<ApiProduct>> getShopProducts(int shopId) async {
    if (useMock) return MockData.getProductsForShop(shopId);
    final url = Uri.parse('$baseUrl/shop/$shopId/products');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final productsList = data['products'] as List<dynamic>? ?? [];
      return productsList.map((json) => ApiProduct.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      final body = response.body.length > 200 ? '${response.body.substring(0, 200)}...' : response.body;
      throw Exception('Failed to load shop products: ${response.statusCode} ($body)');
    }
  }

  static Future<List<ApiProduct>> getProductsByFilter(int id) async {
    if (useMock) return MockData.getProductsBySubCategory(id);
    final url = Uri.parse('$baseUrl/$id/products');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final productsList = data['products'] as List<dynamic>? ?? [];
      return productsList.map((json) => ApiProduct.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      final body = response.body.length > 200 ? '${response.body.substring(0, 200)}...' : response.body;
      throw Exception('Failed to load products by filter: ${response.statusCode} ($body)');
    }
  }

  static String? get token => _token;

  static Future<List<ApiPaymentMethod>> getPaymentMethods() async {
    if (useMock) return MockData.paymentMethods;
    final url = Uri.parse('$baseUrl/payment-methods');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data['payment_methods'] as List<dynamic>? ?? [];
      return list.map((j) => ApiPaymentMethod.fromJson(j as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load payment methods');
    }
  }

  static Future<List<ApiAddress>> getAddresses() async {
    if (useMock) return MockData.addresses;
    final url = Uri.parse('$baseUrl/addresses');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data['addresses'] as List<dynamic>? ?? [];
      return list.map((j) => ApiAddress.fromJson(j as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load addresses');
    }
  }

  static Future<Map<String, dynamic>> createAddress(Map<String, dynamic> data) async {
    if (useMock) return {'success': true, 'message': 'Address created (mock)'};
    final url = Uri.parse('$baseUrl/address/create');
    final response = await http.post(url, headers: _headers, body: jsonEncode(data));
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final body = response.body.length > 200 ? '${response.body.substring(0, 200)}...' : response.body;
      throw Exception('Failed to create address: $body');
    }
  }

  static Future<Map<String, dynamic>> updateAddress(int id, Map<String, dynamic> data) async {
    if (useMock) return {'success': true, 'message': 'Address updated (mock)'};
    final url = Uri.parse('$baseUrl/address/update/$id');
    final response = await http.post(url, headers: _headers, body: jsonEncode(data));
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final body = response.body.length > 200 ? '${response.body.substring(0, 200)}...' : response.body;
      throw Exception('Failed to update address: $body');
    }
  }

  static Future<void> deleteAddress(int id) async {
    if (useMock) return;
    final url = Uri.parse('$baseUrl/address/delete/$id');
    final response = await http.delete(url, headers: _headers);
    if (response.statusCode != 200 && response.statusCode != 201 && response.statusCode != 204) {
      final body = response.body.length > 200 ? '${response.body.substring(0, 200)}...' : response.body;
      throw Exception('Failed to delete address (${response.statusCode}): $body');
    }
  }

  static Future<Map<String, dynamic>> createPurchase(Map<String, dynamic> data) async {
    if (useMock) {
      MockData.addPurchase(data);
      final last = MockData.purchases.last;
      return {'success': true, 'message': 'Purchase created', 'purchase': last, 'purchase_id': last['id']};
    }
    final url = Uri.parse('$baseUrl/purchase/create');
    final response = await http.post(url, headers: _headers, body: jsonEncode(data));
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final body = response.body.length > 200 ? '${response.body.substring(0, 200)}...' : response.body;
      throw Exception('Failed to create purchase: $body');
    }
  }

  static Future<List<dynamic>> getPurchases() async {
    if (useMock) {
      MockData.seedSamplePurchases();
      return List.from(MockData.purchases);
    }
    final url = Uri.parse('$baseUrl/purchases');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['purchases'] as List<dynamic>? ?? [];
    } else {
      throw Exception('Failed to load purchases');
    }
  }

  static Future<Map<String, dynamic>> getUser() async {
    if (useMock) return MockData.userData;
    final url = Uri.parse('$baseUrl/user');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user');
    }
  }

  static Future<Map<String, dynamic>> updateProfile(String id, Map<String, dynamic> data) async {
    if (useMock) return {'success': true, 'message': 'Profile updated (mock)', 'user': MockData.userData};
    final url = Uri.parse('$baseUrl/user/update/$id');
    final response = await http.post(url, headers: _headers, body: jsonEncode(data));
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final body = response.body.length > 200 ? '${response.body.substring(0, 200)}...' : response.body;
      throw Exception('Failed to update profile (${response.statusCode}): $body');
    }
  }
}
