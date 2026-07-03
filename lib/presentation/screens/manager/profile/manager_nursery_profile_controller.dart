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

  /// Programs shown in the tag editor. Backed by the canonical
  /// `platform/{nurseryId}/programs` store (the same one the standalone
  /// Programs screen manages), so additions/removals here and there stay in
  /// sync. [programs] holds the display names; [_programModels] keeps the full
  /// records so a removal can target the right key.
  final programs = <String>[].obs;
  final _programModels = <ProgramModel>[].obs;
  final _programSvc = Get.find<ProgramParentService>();

  final activities = <String>[].obs;

  /// City the nursery belongs to (picked from the global SuperAdmin list).
  final cityId = RxnString();
  final cityName = RxnString();
  final cities = <CityModel>[].obs;
  final _cityService = Get.find<CityParentService>();

  void setCity(CityModel? city) {
    cityId.value = city?.key;
    cityName.value = city?.name;
  }

  /// Canonical branches (platform/{nurseryId}/branches) — the same records the
  /// owner setup flow creates, each tied to a branch-manager account. Managed
  /// here directly (immediate writes), not batched into [save].
  final branches = <BranchModel>[].obs;
  final managers = <StaffModel>[].obs;
  final branchesLoading = false.obs;
  final _mgmt = BranchManagementService();

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
    loadBranches();
    loadPrograms();
    loadCities();
  }

  Future<void> loadCities() async {
    await _cityService.getAll(callBack: (list) {
      cities.assignAll(list.whereType<CityModel>().toList()
        ..sort((a, b) => a.name.compareTo(b.name)));
    });
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
        cityId.value = model.cityId;
        cityName.value = model.cityName;
        activities.assignAll(model.activities);
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

  /// Loads the canonical programs so this editor shows exactly what the
  /// standalone Programs screen holds (and vice-versa).
  Future<void> loadPrograms() async {
    if (nurseryId.isEmpty) return;
    await _programSvc.getAll(callBack: (list) {
      final models = list.whereType<ProgramModel>().toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      _programModels.assignAll(models);
      programs.assignAll(models.map((m) => m.name));
    });
  }

  /// Adds a program straight into the canonical store (immediate write), so it
  /// appears on the standalone Programs screen and the public profile too.
  Future<void> addProgram(String value) async {
    final v = value.trim();
    if (v.isEmpty || nurseryId.isEmpty) return;
    if (programs.any((p) => p.toLowerCase() == v.toLowerCase())) return;
    Loader.show();
    await _programSvc.add(
      item: ProgramModel(key: const Uuid().v4(), nurseryId: nurseryId, name: v),
      callBack: (status) {
        Loader.dismiss();
        if (status != ResponseStatus.success) {
          Loader.showError('program_error_failed'.tr);
        }
      },
    );
    await loadPrograms();
  }

  Future<void> removeProgram(String value) async {
    ProgramModel? model;
    for (final m in _programModels) {
      if (m.name == value) {
        model = m;
        break;
      }
    }
    if (model?.key == null) {
      programs.remove(value);
      return;
    }
    Loader.show();
    await _programSvc.delete(
      id: model!.key!,
      callBack: (status) {
        Loader.dismiss();
        if (status != ResponseStatus.success) {
          Loader.showError('program_error_failed'.tr);
        }
      },
    );
    await loadPrograms();
  }

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

  // ─── Branches (canonical, immediate writes) ─────────────────────────────────
  Future<void> loadBranches() async {
    if (nurseryId.isEmpty) return;
    branchesLoading.value = true;
    final results = await Future.wait([
      _mgmt.getBranches(),
      _mgmt.getManagers(),
    ]);
    branches.assignAll((results[0] as List<BranchModel>)
      ..sort((a, b) {
        if (a.isMain != b.isMain) return a.isMain ? -1 : 1;
        return a.name.compareTo(b.name);
      }));
    managers.assignAll(results[1] as List<StaffModel>);
    branchesLoading.value = false;
  }

  StaffModel? managerForBranch(String? branchId) =>
      _mgmt.managerForBranch(managers, branchId);

  /// Creates a new branch together with its branch-manager account.
  Future<void> addBranchWithManager({
    required String branchName,
    required String managerName,
    required String phone,
  }) async {
    Loader.show();
    final branchId = await _mgmt.addBranchWithManager(
      branchName: branchName,
      managerName: managerName,
      phone: phone,
      makeMain: branches.isEmpty,
    );
    if (branchId == null) {
      Loader.showError('setup_owner_branch_error'.tr);
      return;
    }
    await loadBranches();
    Loader.showSuccess('setup_owner_branch_added'.tr);
  }

  /// Persists edited contact/location details for an existing branch.
  Future<void> updateBranchDetails(BranchModel branch) async {
    Loader.show();
    final ok = await _mgmt.updateBranch(branch);
    Loader.dismiss();
    if (!ok) {
      Loader.showError('manager_profile_save_error'.tr);
      return;
    }
    await loadBranches();
    Loader.showSuccess('manager_profile_saved'.tr);
  }

  Future<void> deleteBranch(String branchId) async {
    Loader.show();
    final manager = managerForBranch(branchId);
    final ok = await _mgmt.deleteBranchWithManager(
      branchId: branchId,
      manager: manager,
    );
    Loader.dismiss();
    if (!ok) {
      Loader.showError('common_error'.tr);
      return;
    }
    branches.removeWhere((b) => b.key == branchId);
    if (manager != null) managers.removeWhere((m) => m.uid == manager.uid);
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
        'cityId': cityId.value,
        'cityName': cityName.value,
        'activities': activities.toList(),
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
