import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences extends ChangeNotifier {
  static final Future<Preferences> _instance = _create();

  late final SharedPreferences _prefs;

  static Future<Preferences> getInstance() => _instance;

  static Future<Preferences> _create() async {
    Preferences preferences = Preferences._();
    preferences._prefs = await SharedPreferences.getInstance();
    return preferences;
  }

  Preferences._();

  int? getInt(String key) => _prefs.getInt(key);

  Future<bool> setInt(String key, int value) async {
    bool result = await _prefs.setInt(key, value);
    notifyListeners();
    return result;
  }

  bool? getBool(String key) => _prefs.getBool(key);

  Future<bool> setBool(String key, bool value) async {
    bool result = await _prefs.setBool(key, value);
    notifyListeners();
    return result;
  }

  double? getDouble(String key) => _prefs.getDouble(key);

  Future<bool> setDouble(String key, double value) async {
    bool result = await _prefs.setDouble(key, value);
    notifyListeners();
    return result;
  }

  String? getString(String key) => _prefs.getString(key);

  Future<bool> setString(String key, String value) async {
    bool result = await _prefs.setString(key, value);
    notifyListeners();
    return result;
  }

  List<String>? getStringList(String key) => _prefs.getStringList(key);

  Future<bool> setStringList(String key, List<String> value) async {
    bool result = await _prefs.setStringList(key, value);
    notifyListeners();
    return result;
  }
}
