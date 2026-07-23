import 'package:firebase_database/firebase_database.dart';
import '../../../../index/index_main.dart';

/// Edits the nursery's privacy policy — the numbered clauses shown to a guardian
/// on their first app open (accepted once via checkbox). Reads/writes the
/// `privacyPolicy` list on the nursery's Discovery node, same partial-update
/// pattern as the application file.
class ManagerPrivacyPolicyController extends GetxController {
  final _session = SessionService();

  final privacyPolicy = <String>[].obs;

  final isLoading = true.obs;
  final isSaving = false.obs;

  String get nurseryId => _session.nurseryId ?? '';

  DatabaseReference get _ref =>
      FirebaseDatabase.instance.ref('platform/info/$nurseryId');

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    if (nurseryId.isEmpty) {
      isLoading.value = false;
      return;
    }
    try {
      final snap = await _ref.get();
      if (snap.exists && snap.value is Map) {
        final model = NurseryModel.fromJson(
          Map<String, dynamic>.from(snap.value as Map),
          key: nurseryId,
        );
        privacyPolicy.assignAll(model.privacyPolicy);
      }
    } catch (_) {
      Loader.showError('manager_profile_load_error'.tr);
    }
    isLoading.value = false;
  }

  void addClause(String value) {
    final v = value.trim();
    if (v.isEmpty) return;
    privacyPolicy.add(v);
  }

  void removeClause(String value) => privacyPolicy.remove(value);

  Future<void> save() async {
    if (nurseryId.isEmpty) return;
    isSaving.value = true;
    Loader.show();
    try {
      await _ref.update({
        'privacyPolicy': privacyPolicy.toList(),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      Loader.showSuccess('manager_profile_saved'.tr);
      Get.back();
    } catch (_) {
      Loader.showError('manager_profile_save_error'.tr);
    }
    isSaving.value = false;
  }
}
