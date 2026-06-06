import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

class SettingsService {
  SettingsService({
    required this.preferences,
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _settingsKey = 'app_settings';
  static const _apiKeyKey = 'lm_studio_api_key';

  final SharedPreferences preferences;
  final FlutterSecureStorage _secureStorage;

  AppSettings loadSettings() {
    final raw = preferences.getString(_settingsKey);
    if (raw == null) return const AppSettings();
    try {
      return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> saveSettings(AppSettings settings) {
    return preferences.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  Future<String> loadApiKey() async {
    return await _secureStorage.read(key: _apiKeyKey) ?? '';
  }

  Future<void> saveApiKey(String apiKey) {
    if (apiKey.trim().isEmpty) {
      return _secureStorage.delete(key: _apiKeyKey);
    }
    return _secureStorage.write(key: _apiKeyKey, value: apiKey.trim());
  }
}
