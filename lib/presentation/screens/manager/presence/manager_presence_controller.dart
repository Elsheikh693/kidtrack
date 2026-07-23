import '../../../../index/index_main.dart';
import '../children/models/presence_entry.dart';

/// Full attendance movement for a single day: who arrived, who is still on-site,
/// and who has already gone home — with a date picker so the manager can review
/// past days too. Read-only; it reshapes the same `childAttendance` records the
/// dashboard ring summarises.
class ManagerPresenceController extends GetxController {
  final isLoading = true.obs;
  final selectedDate = DateTime.now().obs;
  final entries = <PresenceEntry>[].obs;

  late final ChildParentService _childSvc;
  late final ClassroomParentService _classroomSvc;
  late final ChildAttendanceParentService _attendanceSvc;

  final _session = SessionService();
  final _childNames = <String, String>{};
  final _childClassroom = <String, String?>{};
  final _classroomNames = <String, String>{};

  String get branchId => _session.branchId ?? '';

  int get insideCount => entries.where((e) => e.isInside).length;
  int get leftCount => entries.where((e) => !e.isInside).length;
  int get totalAttended => entries.length;

  bool get isToday {
    final n = DateTime.now();
    final d = selectedDate.value;
    return n.year == d.year && n.month == d.month && n.day == d.day;
  }

  String get _dateStr {
    final d = selectedDate.value;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  @override
  void onInit() {
    super.onInit();
    _childSvc = Get.find<ChildParentService>();
    _classroomSvc = Get.find<ClassroomParentService>();
    _attendanceSvc = Get.find<ChildAttendanceParentService>();
    loadData();
  }

  String classroomName(String? id) =>
      (id == null || _classroomNames[id] == null)
          ? 'manager_children_no_class'.tr
          : _classroomNames[id]!;

  Future<void> openChild(String childId) async {
    if (childId.isEmpty) return;
    await Get.toNamed(childProfileView, arguments: {'childId': childId});
  }

  Future<void> pickDate() async {
    final picked = await showAppDatePicker(
      Get.context!,
      initialDate: selectedDate.value,
      maximumDate: DateTime.now(),
    );
    if (picked == null) return;
    selectedDate.value = DateTime(picked.year, picked.month, picked.day);
    await loadData();
  }

  void goPreviousDay() {
    final d = selectedDate.value;
    selectedDate.value = DateTime(d.year, d.month, d.day - 1);
    loadData();
  }

  void goNextDay() {
    if (isToday) return;
    final d = selectedDate.value;
    final next = DateTime(d.year, d.month, d.day + 1);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    selectedDate.value = next.isAfter(today) ? today : next;
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    // Children + classrooms supply the display names; both are independent.
    await Future.wait([_loadChildren(), _loadClassrooms()]);
    await _loadAttendance();
    isLoading.value = false;
  }

  Future<void> _loadChildren() async {
    await _childSvc.getAll(callBack: (list) {
      final branch = list
          .whereType<ChildModel>()
          .where((c) => c.branchId == branchId && _session.seesShift(c.shift))
          .toList();
      _childNames
        ..clear()
        ..addEntries(branch
            .where((c) => c.key != null)
            .map((c) => MapEntry(c.key!, c.fullName)));
      _childClassroom
        ..clear()
        ..addEntries(branch
            .where((c) => c.key != null)
            .map((c) => MapEntry(c.key!, c.classroomId)));
    });
  }

  Future<void> _loadClassrooms() async {
    await _classroomSvc.getAll(callBack: (list) {
      final rooms = list
          .whereType<ClassroomModel>()
          .where((c) =>
              (c.isAllBranches || c.branchIds.contains(branchId)) && c.isActive)
          .toList();
      _classroomNames
        ..clear()
        ..addEntries(
            rooms.where((c) => c.key != null).map((c) => MapEntry(c.key!, c.name)));
    });
  }

  Future<void> _loadAttendance() async {
    await _attendanceSvc.getAll(callBack: (list) {
      // Scope by the branch roster (childId), not the record's stored branchId:
      // a teacher check-in may carry an empty branchId, which would otherwise
      // drop those present children from the presence list.
      final day = list
          .whereType<ChildAttendanceModel>()
          .where((a) =>
              _childNames.containsKey(a.childId) &&
              a.date == _dateStr &&
              (a.status == 'present' || a.status == 'late'))
          .toList();

      final result = day
          .map((a) => PresenceEntry(
                childId: a.childId,
                name: _childNames[a.childId] ??
                    'manager_children_unknown_child'.tr,
                classroomName: classroomName(_childClassroom[a.childId]),
                checkInMs: a.checkInTime,
                checkOutMs: a.checkOutTime,
              ))
          .toList()
        // Most recent arrival first; the still-inside cohort naturally floats up.
        ..sort((x, y) => (y.checkInMs ?? 0).compareTo(x.checkInMs ?? 0));
      entries.assignAll(result);
    });
  }
}
