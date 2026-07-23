import '../../../../index/index_main.dart';

/// Drives the parent notification-preferences sheet: two independent toggles
/// (attendance always defaults on, activities is opt-in) persisted to
/// users/{uid}/notifPrefs through [NotificationPrefsService].
class NotificationPrefsController extends GetxController {
  final attendance = true.obs;
  final activities = false.obs;
  final isLoading = false.obs;

  late final NotificationPrefsService _service;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<NotificationPrefsService>();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    final prefs = await _service.read();
    attendance.value = prefs.attendance;
    activities.value = prefs.activities;
    isLoading.value = false;
  }

  /// Persists both toggles and closes the sheet. Writing the node also clears
  /// the first-time onboarding prompt.
  Future<void> saveAndClose() async {
    Loader.show();
    try {
      await _service.save(
        attendance: attendance.value,
        activities: activities.value,
      );
      Get.back();
      Loader.showSuccess('notif_prefs_saved'.tr);
    } catch (_) {
      Loader.showError('common_error'.tr);
    }
  }
}
