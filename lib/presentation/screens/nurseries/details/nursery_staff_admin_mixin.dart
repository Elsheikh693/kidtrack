import 'package:firebase_database/firebase_database.dart';
import '../../../../index/index_main.dart';

/// SuperAdmin add-on for the nursery details screen: reads a nursery's full
/// staff roster (every employee, with their durable activation/login code) and
/// the total number of children added to that nursery.
///
/// The SuperAdmin operates OUTSIDE session scope (they are not logged into any
/// single nursery), so staff/children are read directly by explicit nursery id
/// — mirroring how [NurseryDetailsController.loadOwners] reads `users/{uid}`.
mixin NurseryStaffAdminMixin on GetxController {
  Rx<NurseryModel> get nursery;

  final RxList<StaffModel> staff = <StaffModel>[].obs;
  final RxBool loadingStaff = true.obs;

  /// Total children added to this nursery (all-time, not scope-filtered).
  final RxInt childrenCount = 0.obs;
  final RxBool loadingChildren = true.obs;

  /// Durable activation code per staff account (targetId == staff.uid). A staff
  /// member has exactly one code; generated lazily the first time it's shown.
  final _codeByStaff = <String, ActivationCodeModel>{};

  ActivationParentService get _activation =>
      Get.find<ActivationParentService>();

  String get _nurseryId => nursery.value.key ?? '';

  /// Loads the staff roster + children count for this nursery, then maps each
  /// staff member to its existing activation code (if any).
  Future<void> loadStaffAndChildren() async {
    await Future.wait([_loadStaff(), _loadChildrenCount()]);
    await _loadCodes();
  }

  Future<void> _loadStaff() async {
    loadingStaff.value = true;
    final id = _nurseryId;
    if (id.isEmpty) {
      staff.clear();
      loadingStaff.value = false;
      return;
    }
    try {
      final snap =
          await FirebaseDatabase.instance.ref('platform/$id/staff').get();
      final result = <StaffModel>[];
      if (snap.exists && snap.value is Map) {
        final map = Map<String, dynamic>.from(snap.value as Map);
        map.forEach((key, value) {
          if (value is Map) {
            result.add(StaffModel.fromJson(
              Map<String, dynamic>.from(value),
              key: key,
            ));
          }
        });
      }
      result.sort((a, b) => a.name.compareTo(b.name));
      staff.value = result;
    } catch (_) {
      staff.clear();
    }
    loadingStaff.value = false;
  }

  Future<void> _loadChildrenCount() async {
    loadingChildren.value = true;
    final id = _nurseryId;
    if (id.isEmpty) {
      childrenCount.value = 0;
      loadingChildren.value = false;
      return;
    }
    try {
      final snap =
          await FirebaseDatabase.instance.ref(ApiConstants.childrenFor(id)).get();
      childrenCount.value =
          (snap.exists && snap.value is Map) ? (snap.value as Map).length : 0;
    } catch (_) {
      childrenCount.value = 0;
    }
    loadingChildren.value = false;
  }

  Future<void> _loadCodes() async {
    final id = _nurseryId;
    await _activation.getAll(
      callBack: (list) {
        _codeByStaff
          ..clear()
          ..addEntries(
            list
                .whereType<ActivationCodeModel>()
                .where((c) => c.nurseryId == id)
                .map((c) => MapEntry(c.targetId, c)),
          );
      },
    );
  }

  /// The activation (login) code shown next to a staff row — null until it has
  /// been minted at least once (created here or elsewhere).
  ActivationCodeModel? codeFor(StaffModel s) => _codeByStaff[s.uid];

  /// Resolve — or lazily mint — a staff member's durable login code.
  Future<ActivationCodeModel?> _ensureCode(StaffModel s) async {
    final existing = _codeByStaff[s.uid];
    if (existing != null) return existing;
    final fresh = await _activation.generate(
      role: _roleFor(s.template),
      targetId: s.uid,
      nurseryId: _nurseryId,
      createdBy: SessionService().userId ?? '',
      silent: true,
    );
    if (fresh != null) _codeByStaff[s.uid] = fresh;
    return fresh;
  }

  /// Open the activation sheet so the SuperAdmin can deliver / print / rotate a
  /// staff member's login code.
  Future<void> showStaffActivation(StaffModel s) async {
    final code = await _ensureCode(s);
    if (code == null) {
      Loader.showError('activation_regenerate_error'.tr);
      return;
    }
    await openActivationSheet(
      code: code,
      recipientName: s.name,
      phone: s.phone,
      nurseryName: nursery.value.name,
      nurseryLogoUrl: nursery.value.logo,
    );
    // The sheet may have rotated the code; refresh from source.
    await _loadCodes();
    staff.refresh();
  }

  /// One-tap: deliver the staff member's login code straight to their WhatsApp.
  Future<void> sendStaffActivationWhatsApp(StaffModel s) async {
    final phone = s.phone ?? '';
    if (phone.trim().isEmpty) {
      Loader.showError('activation_no_phone'.tr);
      return;
    }
    final code = await _ensureCode(s);
    if (code == null) {
      Loader.showError('activation_regenerate_error'.tr);
      return;
    }
    launchWhatsApp(
      phone,
      message: buildActivationMessage(
        role: _roleFor(s.template),
        name: s.name,
        code: code.code,
        nurseryName: nursery.value.name,
      ),
    );
  }

  /// Maps a staff template to the role string the activation message uses.
  String _roleFor(StaffTemplate t) => switch (t) {
        StaffTemplate.owner => 'owner',
        StaffTemplate.branchManager => 'manager',
        StaffTemplate.receptionist => 'reception',
        StaffTemplate.teacher => 'teacher',
        _ => 'staff',
      };
}
