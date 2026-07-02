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

    // App is Arabic-only for now — force 'ar' regardless of any saved value.
    appLocale.value = 'ar';
    Get.updateLocale(const Locale('ar'));
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
