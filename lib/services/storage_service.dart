import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  static String? getString(String key) => _prefs?.getString(key);

  static Future<void> saveList(String key, List<Map<String, dynamic>> list) async {
    final jsonString = jsonEncode(list);
    await saveString(key, jsonString);
  }

  static List<Map<String, dynamic>> getList(String key) {
    final jsonString = getString(key);
    if (jsonString == null) return [];
    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.map((e) => e as Map<String, dynamic>).toList();
  }

  static Future<void> saveMap(String key, Map<String, dynamic> map) async {
    final jsonString = jsonEncode(map);
    await saveString(key, jsonString);
  }

  static Map<String, dynamic>? getMap(String key) {
    final jsonString = getString(key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  static Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  static Future<void> clear() async {
    await _prefs?.clear();
  }
}
