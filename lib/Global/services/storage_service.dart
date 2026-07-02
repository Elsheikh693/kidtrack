
import '../../index/index_main.dart';

class StorageService {
  StorageService._internal();

  static final StorageService _instance = StorageService._internal();

  factory StorageService() => _instance;

  late SharedPreferences _preferences;

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }



  Future<bool> setData(String key, Map<String, dynamic> data) async {
    try {
      final jsonData = json.encode(data);
      return await _preferences.setString(key, jsonData);
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // GET
  // ============================================================

  Map<String, dynamic>? getData(String key) {
    try {
      final jsonData = _preferences.getString(key);
      if (jsonData != null) {
        return json.decode(jsonData) as Map<String, dynamic>;
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  // ============================================================
  // REMOVE
  // ============================================================

  Future<bool> remove(String key) async {
    return await _preferences.remove(key);
  }

  // ============================================================
  // CLEAR ALL (logout)
  // ============================================================

  /// Wipes every stored key except those in [preserve] (e.g. UI preferences
  /// like language/theme that should survive a logout) or those starting with
  /// any prefix in [preservePrefixes] (e.g. per-account first-login setup
  /// markers that must outlive logout).
  Future<void> clearAll({
    Set<String> preserve = const {},
    Set<String> preservePrefixes = const {},
  }) async {
    final keys = _preferences.getKeys().toList();
    for (final key in keys) {
      if (preserve.contains(key)) continue;
      if (preservePrefixes.any(key.startsWith)) continue;
      await _preferences.remove(key);
    }
  }
}
