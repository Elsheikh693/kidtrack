import '../../../../index/index_main.dart';
import '../../../../Data/models/child_current_status/child_current_status_model.dart';
import '../../../../Data/models/child_daily_event/child_daily_event_model.dart';
import '../../../../Global/services/child_status_service.dart';
import '../../../../Global/widgets/undo_snackbar.dart';
import '../../../../Global/widgets/event_logged_burst.dart';

/// Adds live child-state tracking (sleeping / eating / back to classroom …) to
/// the activity controller so the teacher can manage states without leaving the
/// activity screen. Mirrors [ClassroomStatesController] but reuses the activity
/// screen's already-loaded children and classroom.
mixin ActivityChildStatesMixin on GetxController {
  ChildStateService get _stateService => Get.find<ChildStateService>();
  final ChildStatusService _statusService = ChildStatusService();

  final childStates = <String, ChildCurrentStatusModel?>{}.obs;
  final stateTemplates = <ChildStateTemplateModel>[].obs;

  StreamSubscription<Map<String, ChildCurrentStatusModel?>>? _statesSub;

  // Provided by the host controller.
  String get nurseryId;
  String get branchId;
  String get teacherId;
  List<ChildModel> get stateChildren;

  /// IDs of children counted present today from the dated attendance record
  /// (the canonical "present today" source). When null, attendance isn't
  /// tracked for this classroom and presence falls back to the live status.
  Set<String>? get presentTodayIds => null;

  /// A checked-in child sitting in a non-default STATUS (e.g. sleeping) — the
  /// "needs attention" exception. Events (toilet/ate) don't set a status, so
  /// they never count here.
  bool hasStatusException(String childId) =>
      isCheckedIn(childId) && stateIdFor(childId) != kDefaultStateId;

  /// Children ordered "record the exception first": attention (present + a
  /// status) → normal present → absent. Name order is kept within each group.
  List<ChildModel> get sortedStateChildren {
    final attention = <ChildModel>[];
    final present = <ChildModel>[];
    final absent = <ChildModel>[];
    for (final c in stateChildren) {
      final id = c.key ?? '';
      if (!isCheckedIn(id)) {
        absent.add(c);
      } else if (hasStatusException(id)) {
        attention.add(c);
      } else {
        present.add(c);
      }
    }
    return [...attention, ...present, ...absent];
  }

  /// How many children are currently checked in (present now).
  int get presentStateCount =>
      stateChildren.where((c) => isCheckedIn(c.key ?? '')).length;

  /// Present, in a normal state (in the activity) — the "assumed normal" group.
  int get inActivityCount => stateChildren
      .where((c) => isCheckedIn(c.key ?? '') && !hasStatusException(c.key ?? ''))
      .length;

  /// Present but in a status that needs attention (e.g. sleeping).
  int get attentionStateCount =>
      stateChildren.where((c) => hasStatusException(c.key ?? '')).length;

  /// Not checked in today.
  int get absentStateCount =>
      stateChildren.where((c) => !isCheckedIn(c.key ?? '')).length;

  Future<void> loadStateTemplates() async {
    stateTemplates.value = await _stateService.loadActiveTemplates(nurseryId);
  }

  void watchChildStates() {
    _statesSub?.cancel();
    final ids = stateChildren
        .map((c) => c.key ?? '')
        .where((id) => id.isNotEmpty)
        .toList();
    if (ids.isEmpty) {
      childStates.clear();
      return;
    }
    _statesSub = _stateService
        .watchChildrenStates(nurseryId, ids)
        .listen((states) => childStates.value = states);
  }

  /// Current stateId for a child (defaults to [kDefaultStateId] when unset).
  /// A stored id mapping to an EVENT template (or an unknown one) is legacy data
  /// — events aren't sticky states — so it reads as the default.
  String stateIdFor(String childId) {
    final id = childStates[childId]?.currentStateId ?? '';
    if (id.isEmpty) return kDefaultStateId;
    final tpl = stateTemplates.firstWhereOrNull((t) => t.key == id);
    if (tpl == null || tpl.isEvent) return kDefaultStateId;
    return id;
  }

  /// Display label for a child's current state.
  String stateLabelFor(String childId) {
    final id = stateIdFor(childId);
    if (id == kDefaultStateId) return 'child_state_default'.tr;
    return childStates[childId]?.currentStateTitle ?? 'child_state_default'.tr;
  }

  /// True when the child is present today and state changes are relevant.
  /// Prefers the dated attendance set (matches reception/home "present today");
  /// falls back to the live status when attendance isn't tracked.
  bool isCheckedIn(String childId) {
    final present = presentTodayIds;
    if (present != null) return present.contains(childId);
    final s = childStates[childId];
    if (s == null) return false;
    return s.status == ChildStatus.checkedIn ||
        s.status == ChildStatus.havingMeal ||
        s.status == ChildStatus.sleeping;
  }

  /// Lets the teacher check a child in from the activity screen — same effect as
  /// reception's check-in — for when a child arrived but reception missed it.
  Future<void> markChildPresent(String childId) async {
    final child = stateChildren.firstWhereOrNull((c) => c.key == childId);
    Loader.show();
    final ok = await _statusService.checkInChild(
      nurseryId: nurseryId,
      // Stamp the child's own branch, not the teacher's session branch — a
      // teacher's staff record may lack a branchId, and an empty branch on the
      // attendance record makes the manager's branch-scoped counts drop it.
      branchId: child?.branchId ?? branchId,
      childId: childId,
      receptionistId: teacherId,
      classroomId: child?.classroomId,
      byRole: ChildEventSource.teacher,
    );
    if (ok) {
      // Refresh the dated present set so the row flips from absent → present
      // immediately, instead of staying dimmed until the next reload.
      await refreshPresence();
      Loader.dismiss();
      Loader.showSuccess('checkin_success_added'.tr);
    } else {
      Loader.dismiss();
      Loader.showError('checkin_error_failed'.tr);
    }
  }

  /// Hook: refresh the host's "present today" set after an in-activity
  /// check-in. Default no-op; overridden by the controller.
  Future<void> refreshPresence() async {}

  Future<void> updateChildState(
    String childId,
    String stateId,
    String stateTitle,
  ) async {
    final tpl = stateTemplates.firstWhereOrNull((t) => t.key == stateId);
    // Instant EVENT: log to the timeline without changing the child's state
    // (no revert needed). Persistent STATUS: becomes the current state.
    if (tpl != null && tpl.isEvent) {
      final child = stateChildren.firstWhereOrNull((c) => c.key == childId);
      final key = await _stateService.logInstantEvent(
        nurseryId: nurseryId,
        branchId: child?.branchId ?? branchId,
        childId: childId,
        teacherId: teacherId,
        title: stateTitle,
        stateId: stateId,
      );
      if (key != null) {
        final who = child?.fullName ?? '';
        showEventLoggedBurst(who.isEmpty ? stateTitle : '$who · $stateTitle');
        showUndoSnackbar(
          message: who.isEmpty
              ? '$stateTitle · ${'child_state_event_logged'.tr}'
              : '$who · $stateTitle',
          onUndo: () => _stateService.deleteEvent(
            nurseryId: nurseryId,
            childId: childId,
            eventKey: key,
          ),
        );
      }
      return;
    }
    await _stateService.updateChildState(
      nurseryId: nurseryId,
      branchId: branchId,
      childId: childId,
      teacherId: teacherId,
      stateId: stateId,
      stateTitle: stateTitle,
    );
  }

  /// Class-level action: put every PRESENT child into [stateId] in one tap
  /// (e.g. "الكل نام"). Only persistent statuses; instant events stay per-child.
  Future<void> applyStatusToAllStates(String stateId, String stateTitle) async {
    final present = stateChildren.where((c) => isCheckedIn(c.key ?? '')).toList();
    if (present.isEmpty) return;
    Loader.show();
    for (final c in present) {
      await _stateService.updateChildState(
        nurseryId: nurseryId,
        branchId: c.branchId,
        childId: c.key ?? '',
        teacherId: teacherId,
        stateId: stateId,
        stateTitle: stateTitle,
      );
    }
    Loader.dismiss();
    Loader.showSuccess('child_state_bulk_done'.tr);
  }

  /// Class-level reset: return every present child to "with class".
  Future<void> returnAllStatesToClass() =>
      applyStatusToAllStates(kDefaultStateId, 'child_state_default'.tr);

  void disposeChildStates() {
    _statesSub?.cancel();
    _statesSub = null;
  }
}
