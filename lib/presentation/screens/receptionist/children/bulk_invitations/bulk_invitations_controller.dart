import '../../../../../index/index_main.dart';
import 'invitation_message.dart';
import 'parent_invite_row.dart';

/// Standalone bulk WhatsApp-invitation screen. Decoupled from the add-child
/// flow on purpose: data entry (register child + link guardian) happens on one
/// day, sending invitations on another. Lists every guardian that has at least
/// one linked child, tracks who was already invited via [ParentModel.invitationSentAt].
class BulkInvitationsController extends GetxController {
  late final GuardianParentService _guardianService;
  late final ParentChildParentService _linkService;
  late final ChildParentService _childService;

  final isLoading = true.obs;
  final rows = <ParentInviteRow>[].obs;
  final filtered = <ParentInviteRow>[].obs;

  final searchQuery = ''.obs;
  // null = show all statuses.
  final statusFilter = Rxn<ParentOnboardingStatus>();
  final searchCtrl = TextEditingController();

  String _nurseryName = '';
  late Worker _searchWorker;

  @override
  void onInit() {
    super.onInit();
    _guardianService = Get.find<GuardianParentService>();
    _linkService = Get.find<ParentChildParentService>();
    _childService = Get.find<ChildParentService>();
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
      await Get.find<NurseryParentService>().getAll(
        callBack: (list) {
          final n = list.whereType<NurseryModel>().firstOrNull;
          if (n != null) _nurseryName = n.name;
        },
      );

      final links = <ParentChildModel>[];
      await _linkService.getAll(
        callBack: (list) => links.addAll(list.whereType<ParentChildModel>()),
      );

      final parents = <ParentModel>[];
      await _guardianService.getAll(
        callBack: (list) => parents.addAll(list.whereType<ParentModel>()),
      );

      final childNameById = <String, String>{};
      await _childService.getAll(
        callBack: (list) {
          for (final c in list.whereType<ChildModel>()) {
            if (c.key != null) childNameById[c.key!] = c.fullName;
          }
        },
      );

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

  /// Opens WhatsApp with the invitation pre-filled, then persists the
  /// "invitation sent" timestamp so the status survives a reload.
  void send(ParentInviteRow row) {
    final phone = row.parent.phone ?? '';
    if (phone.trim().isEmpty) return;
    launchWhatsApp(
      phone,
      message: buildParentInvitationMessage(
        parentName: row.parent.name,
        childName: row.childNames.join(' و '),
        nurseryName: _nurseryName,
        phone: phone,
        multipleChildren: row.childNames.length > 1,
      ),
    );
    _markSent(row.parent.uid);
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
