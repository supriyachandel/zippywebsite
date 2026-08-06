import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static final Map<String, dynamic> _memory = {};

  static Future<SharedPreferences?> _getPrefs() async {
    try {
      return await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('PrefsService error: $e');
      return null;
    }
  }

  static Future<String?> getString(String key) async {
    final prefs = await _getPrefs();
    if (prefs != null) {
      final val = prefs.getString(key);
      if (val != null) return val;
    }
    return _memory[key] as String?;
  }

  static Future<void> setString(String key, String value) async {
    _memory[key] = value;
    final prefs = await _getPrefs();
    await prefs?.setString(key, value);
  }

  static Future<int?> getInt(String key) async {
    final prefs = await _getPrefs();
    if (prefs != null) {
      final val = prefs.getInt(key);
      if (val != null) return val;
    }
    return _memory[key] as int?;
  }

  static Future<void> setInt(String key, int value) async {
    _memory[key] = value;
    final prefs = await _getPrefs();
    await prefs?.setInt(key, value);
  }

  static Future<double?> getDouble(String key) async {
    final prefs = await _getPrefs();
    if (prefs != null) {
      final val = prefs.getDouble(key);
      if (val != null) return val;
    }
    return _memory[key] as double?;
  }

  static Future<void> setDouble(String key, double value) async {
    _memory[key] = value;
    final prefs = await _getPrefs();
    await prefs?.setDouble(key, value);
  }

  static Future<bool?> getBool(String key) async {
    final prefs = await _getPrefs();
    if (prefs != null) {
      final val = prefs.getBool(key);
      if (val != null) return val;
    }
    return _memory[key] as bool?;
  }

  static Future<void> setBool(String key, bool value) async {
    _memory[key] = value;
    final prefs = await _getPrefs();
    await prefs?.setBool(key, value);
  }

  static Future<void> remove(String key) async {
    _memory.remove(key);
    final prefs = await _getPrefs();
    await prefs?.remove(key);
  }
}
