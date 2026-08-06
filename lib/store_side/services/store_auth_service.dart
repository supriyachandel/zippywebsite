import 'dart:convert';
import 'package:http/http.dart' as http;
import 'store_api_service.dart';
import '../../services/prefs_service.dart';

class StoreAuthService {
  static const String baseUrl = 'https://fascism-bullseye-perjury.ngrok-free.dev/api';

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Map<String, String> get _authHeaders => {
    ..._headers,
    'Authorization': 'Bearer ${StoreApiService.token ?? ''}',
  };

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    if (StoreApiService.useMock) {
      final token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
      await StoreApiService.setToken(token);
      await StoreApiService.setShopId(1);
      return {
        'token': token,
        'user': {'id': 1, 'name': 'Store Owner', 'email': email},
        'shop': {'id': 1, 'name': 'Fashion Hub'},
      };
    }
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final rawToken = data['token'] ?? data['data']?['token'] ?? data['access_token'] ?? '';
      final token = (rawToken is String && rawToken.isNotEmpty) ? rawToken : null;
      if (token != null) {
        await StoreApiService.setToken(token);
      }
      // Save shop ID if present in login response
      final shop = data['shop'] ?? data['data']?['shop'];
      if (shop != null) {
        final sid = shop['id'];
        if (sid != null) await StoreApiService.setShopId(int.tryParse(sid.toString()));
      }
      return data;
    } else {
      final body = response.body.length > 300 ? '${response.body.substring(0, 300)}...' : response.body;
      throw Exception('Failed to login (${response.statusCode}): $body');
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? gender,
  }) async {
    if (StoreApiService.useMock) {
      final token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
      await StoreApiService.setToken(token);
      return {
        'token': token,
        'user': {'id': 1, 'name': name, 'email': email, 'phone': phone},
      };
    }
    final url = Uri.parse('$baseUrl/register');
    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'phone': phone,
        'gender': gender ?? '',
        'image': '',
        'address': 'Not Provided',
        'adharcard': 'NA',
        'pancard': 'NA',
        'city': 'Not Provided',
        'zip': '000000',
        'state': 'Not Provided',
        'country': 'India',
        'latitude': '0.0',
        'longitude': '0.0',
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final rawToken = data['token'] ?? data['data']?['token'] ?? data['access_token'] ?? '';
      final token = (rawToken is String && rawToken.isNotEmpty) ? rawToken : null;
      if (token != null) {
        await StoreApiService.setToken(token);
      }
      return data;
    } else {
      final body = response.body.length > 300 ? '${response.body.substring(0, 300)}...' : response.body;
      throw Exception('Failed to register (${response.statusCode}): $body');
    }
  }

  Future<Map<String, dynamic>> createShop({
    required String name,
    required String phone,
    String? description,
    String? gstNumber,
    String? address,
    String? city,
    String? state,
    String? zip,
    String? country,
    String? email,
  }) async {
    return await StoreApiService.createShop({
      'name': name,
      'phone': phone,
      'description': description ?? '',
      'gst_number': gstNumber ?? '',
      'address': address ?? 'Not Provided',
      'city': city ?? 'Not Provided',
      'state': state ?? 'Not Provided',
      'zip': zip ?? '000000',
      'country': country ?? 'India',
      'email': email ?? '',
      'shop_number': 'SHOP-${DateTime.now().millisecondsSinceEpoch}',
      'status': 'active',
    });
  }

  Future<void> logout() async {
    await StoreApiService.setToken(null);
    await StoreApiService.setShopId(null);
    await PrefsService.remove('store_name');
    await PrefsService.remove('store_email');
    await PrefsService.remove('store_phone');
  }

  Future<void> saveUserData({
    required String name,
    required String email,
    String? phone,
  }) async {
    await PrefsService.setString('store_name', name);
    await PrefsService.setString('store_email', email);
    if (phone != null) await PrefsService.setString('store_phone', phone);
  }

  Future<Map<String, String?>> loadUserData() async {
    return {
      'name': await PrefsService.getString('store_name'),
      'email': await PrefsService.getString('store_email'),
      'phone': await PrefsService.getString('store_phone'),
    };
  }
}
