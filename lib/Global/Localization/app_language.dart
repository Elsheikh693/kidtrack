import '../../index/index_main.dart';

class AppLanguage extends GetxController {
  final LocalStorageLanguage _storage = LocalStorageLanguage();

  // ============================================================
  // 🌍 STATE
  // ============================================================

  final appLocale = 'ar'.obs;

  // ============================================================
  // 🚀 INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    // Restore the language the user last picked (defaults to Arabic).
    final saved = _storage.read();
    appLocale.value = saved;
    Get.updateLocale(Locale(saved));
  }

  // ============================================================
  // 🔄 CHANGE LANGUAGE
  // ============================================================

  Future<void> changeLanguage(String lang) async {
    if (appLocale.value == lang) return;

    await _storage.save(lang);

    appLocale.value = lang;

    Get.updateLocale(Locale(lang));

    
  }
}
