import 'package:flutter/material.dart';
import '../services/prefs_service.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';

class UserState extends ChangeNotifier {
  Gender _gender = Gender.other;
  double _height = 170.0;
  double _weight = 70.0;
  Color _skinTone = const Color(0xFFFFDBAC);

  String? _token;
  String? _userName;
  String? _userEmail;
  String? _userPhone;
  String? _userImage;
  bool _isLoggedIn = false;
  bool _isLoading = false;

  Gender get gender => _gender;
  double get height => _height;
  double get weight => _weight;
  Color get skinTone => _skinTone;

  String? get token => _token;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get userPhone => _userPhone;
  String? get userImage => _userImage;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  void setGender(Gender newGender) {
    _gender = newGender;
    _saveToPrefs();
    notifyListeners();
  }

  void setHeight(double newHeight) {
    _height = newHeight;
    _saveToPrefs();
    notifyListeners();
  }

  void setWeight(double newWeight) {
    _weight = newWeight;
    _saveToPrefs();
    notifyListeners();
  }

  void setSkinTone(Color newTone) {
    _skinTone = newTone;
    _saveToPrefs();
    notifyListeners();
  }

  void login(String token, {String? name, String? email, String? phone, String? image}) {
    _token = token;
    _userName = name;
    _userEmail = email;
    _userPhone = phone;
    _userImage = image;
    _isLoggedIn = true;
    _saveToPrefs();
    notifyListeners();
  }

  void updateProfile({String? name, String? email, String? phone, String? image}) {
    if (name != null) _userName = name;
    if (email != null) _userEmail = email;
    if (phone != null) _userPhone = phone;
    if (image != null) _userImage = image;
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _userName = null;
    _userEmail = null;
    _userPhone = null;
    _userImage = null;
    _isLoggedIn = false;
    await ApiService.setToken(null);
    await _clearPrefs();
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> loadFromPrefs() async {
    _token = await PrefsService.getString('auth_token');
    _userName = await PrefsService.getString('user_name');
    _userEmail = await PrefsService.getString('user_email');
    _userPhone = await PrefsService.getString('user_phone');
    _userImage = await PrefsService.getString('user_image');
    _isLoggedIn = _token != null && _token!.isNotEmpty;

    final genderIndex = await PrefsService.getInt('gender');
    if (genderIndex != null && genderIndex < Gender.values.length) {
      _gender = Gender.values[genderIndex];
    }
    final savedHeight = await PrefsService.getDouble('height');
    if (savedHeight != null) _height = savedHeight;
    final savedWeight = await PrefsService.getDouble('weight');
    if (savedWeight != null) _weight = savedWeight;
    final skinToneValue = await PrefsService.getInt('skinTone');
    if (skinToneValue != null) {
      _skinTone = Color(skinToneValue);
    }
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    if (_token != null) await PrefsService.setString('auth_token', _token!);
    if (_userName != null) await PrefsService.setString('user_name', _userName!);
    if (_userEmail != null) await PrefsService.setString('user_email', _userEmail!);
    if (_userPhone != null) await PrefsService.setString('user_phone', _userPhone!);
    if (_userImage != null) await PrefsService.setString('user_image', _userImage!);
    await PrefsService.setInt('gender', _gender.index);
    await PrefsService.setDouble('height', _height);
    await PrefsService.setDouble('weight', _weight);
    await PrefsService.setInt('skinTone', _skinTone.value);
  }

  Future<void> _clearPrefs() async {
    await PrefsService.remove('auth_token');
    await PrefsService.remove('user_name');
    await PrefsService.remove('user_email');
    await PrefsService.remove('user_phone');
    await PrefsService.remove('user_image');
  }
}
