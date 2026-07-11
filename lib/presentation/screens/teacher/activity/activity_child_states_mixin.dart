import '../../../../index/index_main.dart';
import '../../../../Data/models/child_current_status/child_current_status_model.dart';
import '../../../../Global/services/child_status_service.dart';

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

  /// Children ordered so present (checked-in) ones come first, keeping the
  /// existing (name) order within each group.
  List<ChildModel> get sortedStateChildren {
    final present = <ChildModel>[];
    final absent = <ChildModel>[];
    for (final c in stateChildren) {
      (isCheckedIn(c.key ?? '') ? present : absent).add(c);
    }
    return [...present, ...absent];
  }

  /// How many children are currently checked in (present now). Matches the
  /// "present" group [sortedStateChildren] floats to the top, and mirrors the
  /// manager's "present now" semantics (on-site, excludes checked-out/absent).
  int get presentStateCount =>
      stateChildren.where((c) => isCheckedIn(c.key ?? '')).length;

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
  String stateIdFor(String childId) {
    final id = childStates[childId]?.currentStateId ?? '';
    return id.isEmpty ? kDefaultStateId : id;
  }

  /// Display label for a child's current state.
  String stateLabelFor(String childId) {
    final id = stateIdFor(childId);
    if (id == kDefaultStateId) return 'child_state_default'.tr;
    return childStates[childId]?.currentStateTitle ?? 'child_state_default'.tr;
  }

  /// True when the child is checked in and state changes are relevant.
  bool isCheckedIn(String childId) {
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
    );
    Loader.dismiss();
    if (ok) {
      Loader.showSuccess('checkin_success_added'.tr);
    } else {
      Loader.showError('checkin_error_failed'.tr);
    }
  }

  Future<void> updateChildState(
    String childId,
    String stateId,
    String stateTitle,
  ) async {
    await _stateService.updateChildState(
      nurseryId: nurseryId,
      branchId: branchId,
      childId: childId,
      teacherId: teacherId,
      stateId: stateId,
      stateTitle: stateTitle,
    );
  }

  void disposeChildStates() {
    _statesSub?.cancel();
    _statesSub = null;
  }
}
