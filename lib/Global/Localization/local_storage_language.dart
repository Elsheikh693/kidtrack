import '../../index/index_main.dart';

class LocalStorageLanguage {
  static const _key = "lang";

  final StorageService _storage = StorageService();

  // ============================================================
  // 💾 SAVE
  // ============================================================

  Future<bool> save(String lang) {
    return _storage.setData(_key, {"value": lang});
  }

  // ============================================================
  // 📖 READ
  // ============================================================

  String read() {
    final data = _storage.getData(_key);

    if (data == null) return "ar";

    return data["value"] ?? "ar";
  }

  // ============================================================
  // ❌ CLEAR
  // ============================================================

  Future<void> clear() async {
    await _storage.remove(_key);
  }
}
