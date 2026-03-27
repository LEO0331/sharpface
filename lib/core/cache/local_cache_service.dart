import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalCacheService {
  static const String _metaSuffix = '__meta';

  Future<void> saveJson(String key, Object value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(value));
  }

  Future<void> saveJsonWithTtl({
    required String key,
    required Object value,
    required Duration ttl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(value));
    await prefs.setString(
      '$key$_metaSuffix',
      jsonEncode({
        'savedAt': DateTime.now().toIso8601String(),
        'ttlMs': ttl.inMilliseconds,
      }),
    );
  }

  Future<Map<String, dynamic>?> readJsonMap(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) return decoded;
    return null;
  }

  Future<Map<String, dynamic>?> readFreshJsonMap(String key) async {
    final isFresh = await _isFresh(key);
    if (!isFresh) return null;
    return readJsonMap(key);
  }

  Future<List<dynamic>?> readJsonList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is List<dynamic>) return decoded;
    return null;
  }

  Future<List<dynamic>?> readFreshJsonList(String key) async {
    final isFresh = await _isFresh(key);
    if (!isFresh) return null;
    return readJsonList(key);
  }

  Future<bool> saveIfChanged(String key, Object value) async {
    final prefs = await SharedPreferences.getInstance();
    final nextRaw = jsonEncode(value);
    final currentRaw = prefs.getString(key);
    if (currentRaw == nextRaw) return false;
    await prefs.setString(key, nextRaw);
    return true;
  }

  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
    await prefs.remove('$key$_metaSuffix');
  }

  Future<bool> _isFresh(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$key$_metaSuffix');
    if (raw == null || raw.isEmpty) return false;
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return false;
    final savedAtRaw = decoded['savedAt'] as String?;
    final ttlMs = (decoded['ttlMs'] as num?)?.toInt();
    if (savedAtRaw == null || ttlMs == null || ttlMs <= 0) return false;
    final savedAt = DateTime.tryParse(savedAtRaw);
    if (savedAt == null) return false;
    final expiresAt = savedAt.add(Duration(milliseconds: ttlMs));
    return DateTime.now().isBefore(expiresAt);
  }
}
