import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import '../../../../index/index_main.dart';

class ManagerNurseryProfileController extends GetxController {
  final _session = SessionService();
  late final FirebaseCredentialsService _credentials;

  final nameCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();

  /// Accepted age range, stored in MONTHS.
  final minAgeMonths = RxnInt();
  final maxAgeMonths = RxnInt();

  final coverPhoto = RxnString();
  final logo = RxnString();
  final photos = <String>[].obs;
  final lat = RxnDouble();
  final lng = RxnDouble();
  final programs = <String>[].obs;
  final activities = <String>[].obs;
  final branches = <NurseryBranch>[].obs;

  /// School days as Dart weekday ints (Mon=1 … Sun=7).
  final workingDays = <int>[].obs;

  /// Owner-controlled discovery visibility. Off until the required profile
  /// fields are filled (see [canList]); forced off on save when not ready.
  final isListed = false.obs;

  final isLoading = true.obs;
  final isSaving = false.obs;

  /// The profile is "ready to be listed" only when the essentials a parent
  /// sees on the Discovery card are present. Gating on this prevents empty
  /// cards from appearing publicly.
  bool get canList =>
      nameCtrl.text.trim().isNotEmpty &&
      (coverPhoto.value ?? '').isNotEmpty;

  /// Localization keys for whatever is still missing before the nursery can
  /// be listed. Empty when [canList] is true.
  List<String> get missingForListing {
    final missing = <String>[];
    if (nameCtrl.text.trim().isEmpty) missing.add('manager_profile_missing_name');
    if ((coverPhoto.value ?? '').isEmpty) {
      missing.add('manager_profile_missing_cover');
    }
    return missing;
  }

  void setListed(bool value) {
    if (value && !canList) {
      Loader.showError('manager_profile_list_incomplete'.tr);
      return;
    }
    isListed.value = value;
  }

  String get nurseryId => _session.nurseryId ?? '';

  bool get hasLocation => lat.value != null && lng.value != null;

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
      final snap = await _ref.get();
      if (snap.exists && snap.value is Map) {
        final model = NurseryModel.fromJson(
          Map<String, dynamic>.from(snap.value as Map),
          key: nurseryId,
        );
        nameCtrl.text = model.name;
        descriptionCtrl.text = model.description ?? '';
        minAgeMonths.value = model.minAgeMonths;
        maxAgeMonths.value = model.maxAgeMonths;
        coverPhoto.value = model.coverPhoto;
        logo.value = model.logo;
        photos.assignAll(model.photos);
        lat.value = model.lat;
        lng.value = model.lng;
        programs.assignAll(model.programs);
        activities.assignAll(model.activities);
        branches.assignAll(model.branches);
        workingDays.assignAll(model.effectiveWorkingDays);
        isListed.value = model.isListed;
      }
    } catch (_) {
      Loader.showError('manager_profile_load_error'.tr);
    }
    isLoading.value = false;
  }

  Future<void> pickCover() async {
    await _pickSingle((url) => coverPhoto.value = url, 'cover');
  }

  Future<void> pickLogo() async {
    await _pickSingle((url) => logo.value = url, 'logo');
  }

  Future<void> _pickSingle(void Function(String) onDone, String label) async {
    await PickedImage().pickImage(callBack: (file) async {
      if (file == null) return;
      final url = await _upload(file, label);
      if (url != null) onDone(url);
    });
  }

  Future<void> addPhotos() async {
    await PickedImage().pickMultiImages(callBack: (files) async {
      for (final file in files) {
        final url = await _upload(file, 'gallery');
        if (url != null) photos.add(url);
      }
    });
  }

  void removePhoto(String url) => photos.remove(url);

  Future<String?> _upload(File file, String label) async {
    final key =
        'nurseryProfiles/$nurseryId/${label}_${DateTime.now().millisecondsSinceEpoch}';
    final result = await _credentials.uploadImage(key, file);
    return result.fold((_) {
      Loader.showError('manager_profile_upload_error'.tr);
      return null;
    }, (url) => url);
  }

  void addProgram(String value) => _addTag(programs, value);
  void removeProgram(String value) => programs.remove(value);

  void addActivity(String value) => _addTag(activities, value);
  void removeActivity(String value) => activities.remove(value);

  void _addTag(RxList<String> list, String value) {
    final v = value.trim();
    if (v.isEmpty || list.contains(v)) return;
    list.add(v);
  }

  void toggleWorkingDay(int weekday) {
    if (workingDays.contains(weekday)) {
      workingDays.remove(weekday);
    } else {
      workingDays.add(weekday);
    }
    workingDays.sort();
  }

  void setLocation(double latitude, double longitude) {
    lat.value = latitude;
    lng.value = longitude;
  }

  void setMinAge(int years, int months) =>
      minAgeMonths.value = years * 12 + months;
  void setMaxAge(int years, int months) =>
      maxAgeMonths.value = years * 12 + months;

  // ─── Branches ──────────────────────────────────────────────────────────────
  void addBranch(NurseryBranch branch) => branches.add(branch);

  void updateBranch(int index, NurseryBranch branch) {
    if (index < 0 || index >= branches.length) return;
    branches[index] = branch;
  }

  void removeBranch(int index) {
    if (index < 0 || index >= branches.length) return;
    branches.removeAt(index);
  }

  Future<void> save() async {
    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      Loader.showError('manager_profile_name_required'.tr);
      return;
    }
    if (nurseryId.isEmpty) return;

    isSaving.value = true;
    Loader.show();
    try {
      // Never persist a listing that no longer meets the readiness bar (e.g.
      // the cover or location was cleared after the toggle was switched on).
      final listed = isListed.value && canList;
      isListed.value = listed;
      await _ref.update({
        'name': name,
        'isListed': listed,
        'description': _orNull(descriptionCtrl.text),
        'minAgeMonths': minAgeMonths.value,
        'maxAgeMonths': maxAgeMonths.value,
        'coverPhoto': coverPhoto.value,
        'logo': logo.value,
        'photos': photos.toList(),
        'lat': lat.value,
        'lng': lng.value,
        'programs': programs.toList(),
        'activities': activities.toList(),
        'branches': branches.map((b) => b.toJson()).toList(),
        'workingDays': workingDays.toList()..sort(),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      Loader.showSuccess('manager_profile_saved'.tr);
      Get.back();
    } catch (_) {
      Loader.showError('manager_profile_save_error'.tr);
    }
    isSaving.value = false;
  }

  String? _orNull(String value) {
    final v = value.trim();
    return v.isEmpty ? null : v;
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    descriptionCtrl.dispose();
    super.onClose();
  }
}
