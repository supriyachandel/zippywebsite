import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'api_service.dart';
import 'prefs_service.dart';
import 'mock_data.dart';

class AuthService {
  String get baseUrl => ApiService.baseUrl;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Map<String, String> get _authHeaders => {
    ..._headers,
    'Authorization': 'Bearer ${ApiService.token ?? ''}',
  };

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? gender,
    String? address,
    String? adharcard,
    String? pancard,
    String? city,
    String? zip,
    String? state,
    String? country,
    String? imageUrl,
    String? latitude,
    String? longitude,
  }) async {
    if (ApiService.useMock) {
      final data = MockData.registerResponse;
      final token = data['token'] as String?;
      if (token != null && token.isNotEmpty) {
        await ApiService.setToken(token);
      }
      return data;
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
        'image': imageUrl ?? '',
        'phone': phone,
        'gender': gender ?? '',
        'address': address ?? 'Not Provided',
        'adharcard': adharcard ?? 'NA',
        'pancard': pancard ?? 'NA',
        'city': city ?? 'Not Provided',
        'zip': zip ?? '000000',
        'state': state ?? 'Not Provided',
        'country': country ?? 'India',
        'latitude': latitude ?? '0.0',
        'longitude': longitude ?? '0.0',
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final token = data['token'] ?? data['data']?['token'] ?? data['access_token'];
      if (token != null && token is String && token.isNotEmpty) {
        await ApiService.setToken(token);
      }
      return data;
    } else {
      final body = response.body.length > 300 ? '${response.body.substring(0, 300)}...' : response.body;
      throw Exception('Failed to register (${response.statusCode}): $body');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    if (ApiService.useMock) {
      final data = MockData.loginResponse;
      final token = data['token'] as String?;
      if (token != null && token.isNotEmpty) {
        await ApiService.setToken(token);
      }
      return {'success': true, 'message': 'Login successful (mock)', ...data};
    }
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'] ?? data['data']?['token'] ?? data['access_token'];
      if (token != null && token is String && token.isNotEmpty) {
        await ApiService.setToken(token);
      }
      return data;
    } else {
      final body = response.body.length > 300 ? '${response.body.substring(0, 300)}...' : response.body;
      throw Exception('Failed to login (${response.statusCode}): $body');
    }
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account == null) throw Exception('Google sign-in cancelled');

      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;

      if (idToken == null) throw Exception('Failed to get Google ID token');

      if (!ApiService.useMock) {
        final url = Uri.parse('$baseUrl/auth/google');
        final response = await http.post(
          url,
          headers: _headers,
          body: jsonEncode({'id_token': idToken}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final token = data['token'] ?? data['data']?['token'] ?? data['access_token'];
          if (token != null && token is String && token.isNotEmpty) {
            await ApiService.setToken(token);
          }
          return data;
        }
        throw Exception('Google sign-in failed (${response.statusCode})');
      }

      await googleSignIn.disconnect();
      final data = Map<String, dynamic>.from(MockData.loginResponse);
      data['google_login'] = true;
      final token = data['token'] as String?;
      if (token != null && token.isNotEmpty) {
        await ApiService.setToken(token);
      }
      return data;
    } catch (e) {
      if (e.toString().contains('cancelled')) rethrow;
      if (ApiService.useMock) {
        final data = Map<String, dynamic>.from(MockData.loginResponse);
        data['google_login'] = true;
        final token = data['token'] as String?;
        if (token != null && token.isNotEmpty) {
          await ApiService.setToken(token);
        }
        data['_mockFallback'] = true;
        return data;
      }
      throw Exception('Google sign-in error: $e');
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    if (ApiService.useMock) return MockData.userData;
    final url = Uri.parse('$baseUrl/user');
    final response = await http.get(url, headers: _authHeaders);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load profile: ${response.body}');
    }
  }

  Future<void> logout() async {
    await ApiService.setToken(null);
    await PrefsService.remove('user_name');
    await PrefsService.remove('user_email');
    await PrefsService.remove('user_phone');
    await PrefsService.remove('user_image');
  }

  Future<void> saveUserData({
    required String name,
    required String email,
    String? phone,
    String? image,
  }) async {
    await PrefsService.setString('user_name', name);
    await PrefsService.setString('user_email', email);
    if (phone != null) await PrefsService.setString('user_phone', phone);
    if (image != null) await PrefsService.setString('user_image', image);
  }

  Future<Map<String, String?>> loadUserData() async {
    return {
      'name': await PrefsService.getString('user_name'),
      'email': await PrefsService.getString('user_email'),
      'phone': await PrefsService.getString('user_phone'),
      'image': await PrefsService.getString('user_image'),
    };
  }
}
