import '../../../../index/index_main.dart';
import '../../../../Data/models/child_current_status/child_current_status_model.dart';
import '../../../../Global/services/child_status_service.dart';

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
  final RxString classroomName = ''.obs;

  String _classroomId = '';
  String _nurseryId = '';
  String _branchId = '';

  StreamSubscription<Map<String, ChildCurrentStatusModel?>>? _statesSub;

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
    children.clear();
    childStates.clear();
    isLoading.value = true;

    await Future.wait([_loadChildren(), _loadTemplates()]);

    _watchStates();
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

  /// Children ordered so present (checked-in) ones come first, keeping the
  /// existing (name) order within each group.
  List<ChildModel> get sortedChildren {
    final present = <ChildModel>[];
    final absent = <ChildModel>[];
    for (final c in children) {
      (isCheckedIn(c.key ?? '') ? present : absent).add(c);
    }
    return [...present, ...absent];
  }

  /// Number of children currently checked in.
  int get presentCount =>
      children.where((c) => isCheckedIn(c.key ?? '')).length;

  // Returns the current stateId for a child ('with_classroom' if none set)
  String stateIdFor(String childId) {
    final s = childStates[childId];
    final id = s?.currentStateId ?? '';
    return id.isEmpty ? kDefaultStateId : id;
  }

  // Returns the display label for a child's current state
  String stateLabelFor(String childId) {
    final id = stateIdFor(childId);
    if (id == kDefaultStateId) return 'child_state_default'.tr;
    final s = childStates[childId];
    return s?.currentStateTitle ?? 'child_state_default'.tr;
  }

  // true if child is currently checked in (state changes are relevant)
  bool isCheckedIn(String childId) {
    final s = childStates[childId];
    if (s == null) return false;
    return s.status == ChildStatus.checkedIn ||
        s.status == ChildStatus.havingMeal ||
        s.status == ChildStatus.sleeping;
  }

  /// Lets the teacher check a child in straight from the classroom-states sheet
  /// — same effect as reception's check-in — for when a child arrived but
  /// reception missed it.
  Future<void> markChildPresent(String childId) async {
    final child = children.firstWhereOrNull((c) => c.key == childId);
    Loader.show();
    final ok = await _statusService.checkInChild(
      nurseryId: _nurseryId,
      branchId: _branchId,
      childId: childId,
      receptionistId: _session.userId ?? '',
      classroomId: child?.classroomId ?? _classroomId,
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
    await _stateService.updateChildState(
      nurseryId: _nurseryId,
      branchId: _branchId,
      childId: childId,
      teacherId: _session.userId ?? '',
      stateId: stateId,
      stateTitle: stateTitle,
    );
  }

  @override
  void onClose() {
    _statesSub?.cancel();
    super.onClose();
  }
}
