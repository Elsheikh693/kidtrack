import '../../../../../index/index_main.dart';
import 'parent_invite_row.dart';

/// Standalone bulk WhatsApp-invitation screen. Decoupled from the add-child
/// flow on purpose: data entry (register child + link guardian) happens on one
/// day, sending invitations on another. Lists every guardian that has at least
/// one linked child, tracks who was already invited via [ParentModel.invitationSentAt].
class BulkInvitationsController extends GetxController {
  late final GuardianParentService _guardianService;
  late final ParentChildParentService _linkService;
  late final ChildParentService _childService;
  late final ActivationParentService _activationService;

  /// Activation code per parent account (targetId == parent.uid). A parent has
  /// exactly one durable code; generated lazily on first send / view.
  final _codeByParent = <String, ActivationCodeModel>{};

  final isLoading = true.obs;
  final rows = <ParentInviteRow>[].obs;
  final filtered = <ParentInviteRow>[].obs;

  final searchQuery = ''.obs;
  // null = show all statuses.
  final statusFilter = Rxn<ParentOnboardingStatus>();
  final searchCtrl = TextEditingController();

  String _nurseryName = '';
  String? _nurseryLogo;
  late Worker _searchWorker;

  @override
  void onInit() {
    super.onInit();
    _guardianService = Get.find<GuardianParentService>();
    _linkService = Get.find<ParentChildParentService>();
    _childService = Get.find<ChildParentService>();
    _activationService = Get.find<ActivationParentService>();
    loadData();
    _searchWorker = debounce(
      searchQuery,
      (_) => _applyFilter(),
      time: const Duration(milliseconds: 300),
    );
  }

  int get totalCount => rows.length;
  int get notSentCount =>
      rows.where((r) => r.status == ParentOnboardingStatus.notSent).length;
  int get sentCount =>
      rows.where((r) => r.status == ParentOnboardingStatus.sent).length;
  int get activatedCount =>
      rows.where((r) => r.status == ParentOnboardingStatus.activated).length;

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final sessionNurseryId = SessionService().nurseryId ?? '';

      final links = <ParentChildModel>[];
      final parents = <ParentModel>[];
      final childNameById = <String, String>{};
      // Existing parent activation codes (durable login keys), indexed by the
      // account they activate so we can reuse instead of minting duplicates.
      _codeByParent.clear();

      // These five reads are independent — fire them concurrently instead of
      // awaiting one after another, so the screen loads in one round-trip
      // instead of five stacked back-to-back.
      await Future.wait([
        Get.find<NurseryParentService>().getOne(sessionNurseryId).then((n) {
          if (n != null) {
            _nurseryName = n.name;
            _nurseryLogo = n.logo;
          }
        }),
        _linkService.getAll(
          callBack: (list) => links.addAll(list.whereType<ParentChildModel>()),
        ),
        _guardianService.getAll(
          callBack: (list) => parents.addAll(list.whereType<ParentModel>()),
        ),
        _childService.getAll(
          callBack: (list) {
            for (final c in list.whereType<ChildModel>()) {
              if (c.key != null) childNameById[c.key!] = c.fullName;
            }
          },
        ),
        _activationService.getAll(
          callBack: (list) {
            for (final c in list.whereType<ActivationCodeModel>()) {
              if (c.role == 'parent' && c.targetId.isNotEmpty) {
                _codeByParent[c.targetId] = c;
              }
            }
          },
        ),
      ]);

      // Group child names per guardian.
      final namesByParent = <String, List<String>>{};
      for (final l in links) {
        final name = childNameById[l.childId];
        if (name == null || name.trim().isEmpty) continue;
        namesByParent.putIfAbsent(l.parentId, () => []).add(name);
      }

      final result = <ParentInviteRow>[];
      for (final p in parents) {
        final names = namesByParent[p.uid];
        if (names == null || names.isEmpty) continue; // only linked guardians
        result.add(ParentInviteRow(parent: p, childNames: names));
      }
      result.sort(_compare);
      rows.value = result;
    } catch (_) {
    } finally {
      isLoading.value = false;
      _applyFilter();
    }
  }

  /// Not-sent first (they need action), then awaiting activation, then
  /// activated; alphabetical within each bucket.
  int _compare(ParentInviteRow a, ParentInviteRow b) {
    final byStatus = _statusOrder(a.status).compareTo(_statusOrder(b.status));
    if (byStatus != 0) return byStatus;
    return a.parent.name.compareTo(b.parent.name);
  }

  int _statusOrder(ParentOnboardingStatus s) => switch (s) {
    ParentOnboardingStatus.notSent => 0,
    ParentOnboardingStatus.sent => 1,
    ParentOnboardingStatus.activated => 2,
  };

  void setStatusFilter(ParentOnboardingStatus? status) {
    statusFilter.value = status;
    _applyFilter();
  }

  void _applyFilter() {
    final q = searchQuery.value.trim().toLowerCase();
    final status = statusFilter.value;
    filtered.value = rows.where((r) {
      if (status != null && r.status != status) return false;
      if (q.isEmpty) return true;
      return r.parent.name.toLowerCase().contains(q) ||
          (r.parent.phone ?? '').contains(q);
    }).toList();
  }

  /// Opens WhatsApp with the ACTIVATION invitation pre-filled (activation code,
  /// no more username/password), then persists the "invitation sent" timestamp
  /// so the status survives a reload.
  Future<void> send(ParentInviteRow row) async {
    final phone = row.parent.phone ?? '';
    if (phone.trim().isEmpty) return;

    final code = await _ensureCode(row.parent);
    if (code == null) {
      Loader.showError('activation_regenerate_error'.tr);
      return;
    }

    launchWhatsApp(
      phone,
      message: buildActivationMessage(
        role: 'parent',
        name: row.parent.name,
        code: code.code,
        nurseryName: _nurseryName,
      ),
    );
    _markSent(row.parent.uid);
  }

  /// Opens the reusable activation sheet (view code, print QR, resend, or
  /// regenerate) for a parent — minting a code on demand if none exists yet.
  Future<void> showActivation(ParentInviteRow row) async {
    final code = await _ensureCode(row.parent);
    if (code == null) {
      Loader.showError('activation_regenerate_error'.tr);
      return;
    }
    await openActivationSheet(
      code: code,
      recipientName: row.parent.name,
      phone: row.parent.phone,
      nurseryName: _nurseryName,
      nurseryLogoUrl: _nurseryLogo,
    );
  }

  /// Builds one printable card PER CHILD (each carries their guardian's login
  /// code) for every listed parent, then opens the print/save sheet. Codes are
  /// minted on the fly for anyone who doesn't have one yet.
  Future<void> printAllCards() async {
    if (rows.isEmpty) return;
    Loader.show();
    final cards = <ActivationCard>[];
    for (final row in rows) {
      final code = await _ensureCode(row.parent);
      if (code == null) continue;
      final children =
          row.childNames.isNotEmpty ? row.childNames : <String>[row.parent.name];
      for (final child in children) {
        cards.add(ActivationCard(
          code: code.code,
          holderName: child,
          nurseryName: _nurseryName,
        ));
      }
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

  /// Returns the parent's durable activation code, minting one the first time.
  Future<ActivationCodeModel?> _ensureCode(ParentModel parent) async {
    final existing = _codeByParent[parent.uid];
    if (existing != null) return existing;

    final created = await _activationService.generate(
      role: 'parent',
      targetId: parent.uid,
      nurseryId: SessionService().nurseryId ?? '',
      createdBy: SessionService().userId ?? '',
      silent: true,
    );
    if (created != null) _codeByParent[parent.uid] = created;
    return created;
  }

  /// Reflect the send locally (instant chip update) and persist it
  /// fire-and-forget — a failed write must never block the receptionist.
  void _markSent(String uid) {
    final i = rows.indexWhere((r) => r.parent.uid == uid);
    if (i != -1) {
      final r = rows[i];
      rows[i] = r.copyWith(
        parent: r.parent.copyWith(
          invitationSentAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
      rows.sort(_compare);
      rows.refresh();
    }
    _applyFilter();
    _guardianService.markInvitationSent(uid);
  }

  @override
  void onClose() {
    _searchWorker.dispose();
    searchCtrl.dispose();
    super.onClose();
  }
}
