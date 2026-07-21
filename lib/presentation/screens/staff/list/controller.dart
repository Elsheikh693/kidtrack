import '../../../../index/index_main.dart';

class StaffListController extends GetxController {
  late final StaffParentService _staffService;
  late final BranchParentService _branchService;
  late final ActivationParentService _activationService;
  late final ShiftParentService _shiftService;

  final _session = SessionService();

  final RxList<StaffModel> staffList = <StaffModel>[].obs;
  final RxMap<String, String> branchNames = <String, String>{}.obs;
  final RxMap<String, String> shiftNames = <String, String>{}.obs;
  final RxBool isLoading = true.obs;

  /// Durable activation code per staff account (targetId == staff.uid). A staff
  /// member has exactly one code; generated lazily the first time it's shown.
  final _codeByStaff = <String, ActivationCodeModel>{};

  String _nurseryName = '';
  String? _nurseryLogo;

  @override
  void onInit() {
    super.onInit();
    _staffService = Get.find<StaffParentService>();
    _branchService = Get.find<BranchParentService>();
    _activationService = Get.find<ActivationParentService>();
    _shiftService = Get.find<ShiftParentService>();
    _loadBranches();
    _loadShifts();
    _loadNurseryName();
    loadStaff();
  }

  Future<void> _loadShifts() async {
    final shifts = await _shiftService.getActive();
    shiftNames.value = {
      for (final s in shifts)
        if (s.key != null) s.key!: s.name,
    };
  }

  /// Resolves a staff member's shift keys to display names, dropping any that no
  /// longer exist.
  List<String> shiftLabelsFor(StaffModel s) => s.shiftIds
      .map((id) => shiftNames[id])
      .whereType<String>()
      .toList();

  Future<void> _loadNurseryName() async {
    final sessionNurseryId = _session.nurseryId;
    await Get.find<NurseryParentService>().getAll(
      callBack: (list) {
        final nurseries = list.whereType<NurseryModel>();
        final n = nurseries
                .where((item) => item.key == sessionNurseryId)
                .firstOrNull ??
            nurseries.firstOrNull;
        if (n != null) {
          _nurseryName = n.name;
          _nurseryLogo = n.logo;
        }
      },
    );
  }

  Future<void> _loadBranches() async {
    await _branchService.getAll(
      callBack: (list) {
        final map = <String, String>{};
        for (final b in list.whereType<BranchModel>()) {
          if (b.key != null) map[b.key!] = b.name;
        }
        branchNames.value = map;
      },
    );
  }

  Future<void> loadStaff() async {
    isLoading.value = true;
    await _staffService.getAll(
      callBack: (list) {
        staffList.value = list.whereType<StaffModel>().where(_inScope).toList()
          ..sort((a, b) => a.name.compareTo(b.name));
      },
    );
    await _loadCodes();
    isLoading.value = false;
  }

  Future<void> _loadCodes() async {
    await _activationService.getAll(
      callBack: (list) {
        _codeByStaff
          ..clear()
          ..addEntries(
            list
                .whereType<ActivationCodeModel>()
                .map((c) => MapEntry(c.targetId, c)),
          );
      },
    );
  }

  /// Owner/super-admin see every branch; a branch manager (or receptionist)
  /// only sees their own branch and shift.
  bool _inScope(StaffModel s) {
    if (_session.isOwner || _session.isSuperAdmin) return true;
    final bId = _session.branchId;
    if (bId != null && bId.isNotEmpty && s.branchId != bId) return false;
    return _session.seesAnyShift(s.shiftIds);
  }

  String branchName(String? id) => id == null
      ? 'staff_no_branch'.tr
      : (branchNames[id] ?? 'staff_no_branch'.tr);

  Future<void> toggleActive(StaffModel staff) async {
    await _staffService.update(
      item: staff.copyWith(isActive: !staff.isActive),
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) loadStaff();
      },
    );
  }

  /// Whether [staff] may be permanently removed. The signed-in user can't delete
  /// their own account, and the nursery owner account is protected outright.
  bool canDelete(StaffModel staff) =>
      staff.uid != _session.userId && staff.template != StaffTemplate.owner;

  /// Permanently removes a staff member: staff doc, permission set, user node,
  /// and their activation (login) code so the credential can't reach a dead
  /// account. Unlike deactivate this is irreversible.
  Future<void> deleteStaff(StaffModel staff) async {
    if (!canDelete(staff)) {
      Loader.showError('staff_delete_forbidden'.tr);
      return;
    }
    Loader.show();
    final ok = await _staffService.deleteCompletely(staff: staff);
    if (!ok) {
      Loader.showError('staff_delete_error'.tr);
      return;
    }
    final code = _codeByStaff.remove(staff.uid);
    if (code != null) {
      await _activationService.delete(code: code.code, callBack: (_) {});
    }
    staffList.removeWhere((s) => s.uid == staff.uid);
    Loader.showSuccess('staff_delete_success'.tr);
  }

  void openAdd() => _openSheet(null);

  void openEdit(StaffModel s) => _openSheet(s);

  void openPermissions(StaffModel s) =>
      Get.toNamed(staffPermissionsView, arguments: s);

  void _openSheet(StaffModel? staff) {
    Get.toNamed(staffFormView, arguments: staff)?.then((_) => loadStaff());
  }

  /// Show (or lazily mint) the staff member's durable activation code — the
  /// passwordless login credential. Opens the shared activation sheet to send it
  /// on WhatsApp / print the QR / regenerate.
  Future<void> generateActivationCode(StaffModel staff) async {
    final code = await _ensureCode(staff);
    if (code == null) {
      Loader.showError('activation_regenerate_error'.tr);
      return;
    }
    await openActivationSheet(
      code: code,
      recipientName: staff.name,
      phone: staff.phone,
      nurseryName: _nurseryName,
      nurseryLogoUrl: _nurseryLogo,
    );
    // The sheet may have regenerated the code; refresh the cache.
    await _loadCodes();
  }

  /// Builds one printable login card per in-scope staff member (QR + durable
  /// code) and opens the share/print sheet — the staff equivalent of the
  /// guardian print-all flow. Codes are minted on the fly for anyone without
  /// one yet, so every card is usable straight away.
  Future<void> printAllCards() async {
    if (staffList.isEmpty) return;
    Loader.show();
    final cards = <ActivationCard>[];
    for (final staff in staffList) {
      final code = await _ensureCode(staff);
      if (code == null) continue;
      cards.add(ActivationCard(
        code: code.code,
        holderName: staff.name,
        nurseryName: _nurseryName,
      ));
    }
    Loader.dismiss();
    if (cards.isEmpty) {
      Loader.showError('activation_regenerate_error'.tr);
      return;
    }
    try {
      await shareActivationCardsPdf(cards: cards, nurseryLogoUrl: _nurseryLogo);
    } catch (_) {
      Loader.showError('activation_pdf_error'.tr);
    }
  }

  /// One-tap: deliver the staff member's login code straight to their WhatsApp.
  Future<void> sendActivationWhatsApp(StaffModel staff) async {
    final phone = staff.phone ?? '';
    if (phone.trim().isEmpty) {
      Loader.showError('activation_no_phone'.tr);
      return;
    }
    final code = await _ensureCode(staff);
    if (code == null) {
      Loader.showError('activation_regenerate_error'.tr);
      return;
    }
    launchWhatsApp(
      phone,
      message: buildActivationMessage(
        role: _roleFor(staff.template),
        name: staff.name,
        code: code.code,
        nurseryName: _nurseryName,
      ),
    );
  }

  Future<ActivationCodeModel?> _ensureCode(StaffModel staff) async {
    final existing = _codeByStaff[staff.uid];
    if (existing != null) return existing;

    final fresh = await _activationService.generate(
      role: _roleFor(staff.template),
      targetId: staff.uid,
      nurseryId: _session.nurseryId ?? '',
      createdBy: _session.userId ?? '',
      silent: true,
    );
    if (fresh != null) _codeByStaff[staff.uid] = fresh;
    return fresh;
  }

  /// Maps a staff template to the role string the activation message uses for
  /// its Arabic wording.
  String _roleFor(StaffTemplate t) => switch (t) {
        StaffTemplate.owner => 'owner',
        StaffTemplate.branchManager => 'manager',
        StaffTemplate.receptionist => 'reception',
        StaffTemplate.teacher => 'teacher',
        _ => 'staff',
      };
}
