import '../../../../index/index_main.dart';
import '../../../../Data/models/child_current_status/child_current_status_model.dart';
import '../../../../Data/models/child_daily_event/child_daily_event_model.dart';
import '../../../../Global/services/child_status_service.dart';
import '../../../../Global/widgets/undo_snackbar.dart';
import '../../../../Global/widgets/event_logged_burst.dart';

class ClassroomStatesController extends GetxController {
  late final ChildStateService _stateService;
  late final SessionService _session;
  final ChildStatusService _statusService = ChildStatusService();

  final RxBool isLoading = true.obs;
  final RxList<ChildModel> children = <ChildModel>[].obs;
  final RxList<ChildStateTemplateModel> templates =
      <ChildStateTemplateModel>[].obs;
  final RxMap<String, ChildCurrentStatusModel?> childStates =
      <String, ChildCurrentStatusModel?>{}.obs;
  // Present-today child IDs — the shared, date-scoped source of truth for
  // attendance (see ChildStatusService.watchPresentIdsForDay).
  final RxSet<String> presentIds = <String>{}.obs;
  final RxString classroomName = ''.obs;

  String _classroomId = '';
  String _nurseryId = '';
  String _branchId = '';

  StreamSubscription<Map<String, ChildCurrentStatusModel?>>? _statesSub;
  StreamSubscription<Set<String>>? _presentSub;

  @override
  void onInit() {
    super.onInit();
    _stateService = Get.find<ChildStateService>();
    _session = Get.find<SessionService>();
  }

  Future<void> initForClassroom(ClassroomModel classroom) async {
    _classroomId = classroom.key ?? '';
    classroomName.value = classroom.name;
    _nurseryId = _session.nurseryId ?? '';
    _branchId = _session.branchId ?? '';

    _statesSub?.cancel();
    _presentSub?.cancel();
    children.clear();
    childStates.clear();
    presentIds.clear();
    isLoading.value = true;

    await Future.wait([_loadChildren(), _loadTemplates()]);

    _watchStates();
    _watchPresentToday();
    isLoading.value = false;
  }

  Future<void> _loadChildren() async {
    children.value = await _stateService.loadClassroomChildren(
      _nurseryId,
      _classroomId,
    );
  }

  Future<void> _loadTemplates() async {
    templates.value = await _stateService.loadActiveTemplates(_nurseryId);
  }

  void _watchStates() {
    final ids = children.map((c) => c.key ?? '').toList();
    if (ids.isEmpty) return;
    _statesSub = _stateService
        .watchChildrenStates(_nurseryId, ids)
        .listen((states) => childStates.value = states);
  }

  /// Presence comes from the dated attendance record — the same source the
  /// reception dashboard and teacher home card use — so all three always agree.
  void _watchPresentToday() {
    if (_nurseryId.isEmpty) return;
    _presentSub = _statusService
        .watchPresentIdsForDay(_nurseryId)
        .listen(presentIds.assignAll);
  }

  /// A checked-in child sitting in a non-default STATUS (e.g. sleeping) — the
  /// "needs attention" exception. Instant events don't set a status, so they
  /// never count here.
  bool hasStatusException(String childId) =>
      isCheckedIn(childId) && stateIdFor(childId) != kDefaultStateId;

  /// Children ordered "record the exception first": attention (present + a
  /// status) → normal present → absent. Name order kept within each group.
  List<ChildModel> get sortedChildren {
    final attention = <ChildModel>[];
    final present = <ChildModel>[];
    final absent = <ChildModel>[];
    for (final c in children) {
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

  /// Number of children currently checked in.
  int get presentCount =>
      children.where((c) => isCheckedIn(c.key ?? '')).length;

  /// Present, in a normal state (with the class) — the "assumed normal" group.
  int get inClassCount => children
      .where((c) => isCheckedIn(c.key ?? '') && !hasStatusException(c.key ?? ''))
      .length;

  /// Present but in a status that needs attention (e.g. sleeping).
  int get attentionCount =>
      children.where((c) => hasStatusException(c.key ?? '')).length;

  /// Not checked in today.
  int get absentCount =>
      children.where((c) => !isCheckedIn(c.key ?? '')).length;

  // Returns the current stateId for a child ('with_classroom' if none set).
  // A stored id that maps to an EVENT template (or an unknown/removed one) is
  // legacy data — events are no longer sticky states — so it reads as default.
  String stateIdFor(String childId) {
    final id = childStates[childId]?.currentStateId ?? '';
    if (id.isEmpty) return kDefaultStateId;
    final tpl = templates.firstWhereOrNull((t) => t.key == id);
    if (tpl == null || tpl.isEvent) return kDefaultStateId;
    return id;
  }

  // Returns the display label for a child's current state
  String stateLabelFor(String childId) {
    final id = stateIdFor(childId);
    if (id == kDefaultStateId) return 'child_state_default'.tr;
    final s = childStates[childId];
    return s?.currentStateTitle ?? 'child_state_default'.tr;
  }

  // true if the child has a dated attendance record for today (present/late).
  // Drives the presence dot, the present/absent line and present-first ordering
  // — all from the same source as reception, never the stale status cache.
  bool isCheckedIn(String childId) => presentIds.contains(childId);

  /// Lets the teacher check a child in straight from the classroom-states sheet
  /// — same effect as reception's check-in — for when a child arrived but
  /// reception missed it.
  Future<void> markChildPresent(String childId) async {
    final child = children.firstWhereOrNull((c) => c.key == childId);
    Loader.show();
    final ok = await _statusService.checkInChild(
      nurseryId: _nurseryId,
      // Stamp the child's own branch, not the teacher's session branch — a
      // teacher's staff record may lack a branchId, and an empty branch on the
      // attendance record makes the manager's branch-scoped counts drop it.
      branchId: child?.branchId ?? _branchId,
      childId: childId,
      receptionistId: _session.userId ?? '',
      classroomId: child?.classroomId ?? _classroomId,
      byRole: ChildEventSource.teacher,
    );
    Loader.dismiss();
    if (ok) {
      Loader.showSuccess('checkin_success_added'.tr);
    } else {
      Loader.showError('checkin_error_failed'.tr);
    }
  }

  Future<void> updateState(
    String childId,
    String stateId,
    String stateTitle,
  ) async {
    final tpl = templates.firstWhereOrNull((t) => t.key == stateId);
    // Instant EVENT (toilet, ate…): log to the timeline and keep the child's
    // current state as-is — nothing to revert. Persistent STATUS (sleeping…):
    // becomes the current state, as before.
    if (tpl != null && tpl.isEvent) {
      final child = children.firstWhereOrNull((c) => c.key == childId);
      final key = await _stateService.logInstantEvent(
        nurseryId: _nurseryId,
        branchId: child?.branchId ?? _branchId,
        childId: childId,
        teacherId: _session.userId ?? '',
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
            nurseryId: _nurseryId,
            childId: childId,
            eventKey: key,
          ),
        );
      }
      return;
    }
    await _stateService.updateChildState(
      nurseryId: _nurseryId,
      branchId: _branchId,
      childId: childId,
      teacherId: _session.userId ?? '',
      stateId: stateId,
      stateTitle: stateTitle,
    );
  }

  /// Class-level action: put every PRESENT child into [stateId] in one tap
  /// (e.g. "الكل نام" at nap time). Only persistent statuses are applied this
  /// way; instant events stay per-child.
  Future<void> applyStatusToAll(String stateId, String stateTitle) async {
    final present = children.where((c) => isCheckedIn(c.key ?? '')).toList();
    if (present.isEmpty) return;
    Loader.show();
    for (final c in present) {
      await _stateService.updateChildState(
        nurseryId: _nurseryId,
        branchId: c.branchId,
        childId: c.key ?? '',
        teacherId: _session.userId ?? '',
        stateId: stateId,
        stateTitle: stateTitle,
      );
    }
    Loader.dismiss();
    Loader.showSuccess('child_state_bulk_done'.tr);
  }

  /// Class-level reset: return every present child to the default "with class"
  /// state (e.g. everyone woke up).
  Future<void> returnAllToClass() =>
      applyStatusToAll(kDefaultStateId, 'child_state_default'.tr);

  @override
  void onClose() {
    _statesSub?.cancel();
    _presentSub?.cancel();
    super.onClose();
  }
}
