import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import '../../../../index/index_main.dart';

/// Lightweight setup step: the owner just drops the nursery logo — nothing else.
/// The full discovery profile (cover, gallery, city, listing…) lives in
/// [ManagerNurseryProfileController]; here we load and persist ONLY the `logo`
/// field so the setup checklist doesn't drag a first-time owner through the
/// whole marketing form.
class NurseryLogoController extends GetxController {
  final _session = SessionService();
  late final FirebaseCredentialsService _credentials;

  final logo = RxnString();
  final isLoading = true.obs;
  final isSaving = false.obs;

  String get nurseryId => _session.nurseryId ?? '';

  DatabaseReference get _ref =>
      FirebaseDatabase.instance.ref('platform/info/$nurseryId');

  @override
  void onInit() {
    super.onInit();
    _credentials = Get.find<FirebaseCredentialsService>();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    if (nurseryId.isEmpty) {
      isLoading.value = false;
      return;
    }
    try {
      final snap = await _ref.child('logo').get();
      if (snap.exists && snap.value != null) {
        logo.value = snap.value.toString();
      }
    } catch (_) {
      Loader.showError('manager_profile_load_error'.tr);
    }
    isLoading.value = false;
  }

  Future<void> pickLogo() async {
    await PickedImage().pickImage(callBack: (file) async {
      if (file == null) return;
      final url = await _upload(file);
      if (url != null) logo.value = url;
    });
  }

  Future<String?> _upload(File file) async {
    final key =
        'nurseryProfiles/$nurseryId/logo_${DateTime.now().millisecondsSinceEpoch}';
    final result = await _credentials.uploadImage(key, file);
    return result.fold((_) {
      Loader.showError('manager_profile_upload_error'.tr);
      return null;
    }, (url) => url);
  }

  Future<void> save() async {
    if (nurseryId.isEmpty) return;
    if ((logo.value ?? '').isEmpty) {
      Loader.showError('nursery_logo_required'.tr);
      return;
    }
    isSaving.value = true;
    Loader.show();
    try {
      await _ref.update({
        'logo': logo.value,
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
