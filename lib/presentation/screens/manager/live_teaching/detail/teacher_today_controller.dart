import '../../../../../index/index_main.dart';

/// Backs the day drill-down for a single teacher: today's activities (running
/// and completed), plus class/subject filters. Parametrised per teacher via
/// [open] before the view is pushed, so it stays a binding-resolved singleton.
class TeacherTodayController extends GetxController {
  final isLoading = true.obs;

  final teacherName = ''.obs;
  final teacherPhoto = Rxn<String>();
  final accent = Rxn<Color>();

  final filtered = <ClassroomActivityModel>[].obs;

  /// Selected filters — null means "all".
  final classFilter = Rxn<String>(); // classroomId
  final subjectFilter = Rxn<String>(); // subject label

  /// Filter options derived from the loaded activities.
  final classOptions = <MapEntry<String, String>>[].obs; // id → name
  final subjectOptions = <String>[].obs;

  final _session = SessionService();
  final _activitySvc = TeacherActivityService();
  late final ClassroomParentService _classroomSvc;

  final _classroomNames = <String, String>{};
  final _all = <ClassroomActivityModel>[];
  String _teacherId = '';

  String get nurseryId => _session.nurseryId ?? '';
  String get branchId => _session.branchId ?? '';

  @override
  void onInit() {
    super.onInit();
    _classroomSvc = Get.find<ClassroomParentService>();
  }

  /// Point the screen at a teacher and (re)load their day. Called by the home
  /// donut just before navigating in.
  Future<void> open({
    required String teacherId,
    required String name,
    String? photo,
    required Color color,
  }) async {
    _teacherId = teacherId;
    teacherName.value = name;
    teacherPhoto.value = photo;
    accent.value = color;
    classFilter.value = null;
    subjectFilter.value = null;
    await loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await _loadClassrooms();
    final ids = _classroomNames.keys.toList();
    final today = await _activitySvc.getTodayForClassrooms(nurseryId, ids);
    _all
      ..clear()
      ..addAll(
        today.where((a) => a.teacherId == _teacherId).toList()
          ..sort((a, b) => b.startedAt.compareTo(a.startedAt)),
      );

    final classes = <String>{};
    final subjects = <String>{};
    for (final a in _all) {
      classes.add(a.classroomId);
      final s = (a.subjectName ?? '').trim();
      if (s.isNotEmpty) subjects.add(s);
    }
    classOptions.assignAll(
      classes.map((id) => MapEntry(id, _classroomNames[id] ?? id)).toList(),
    );
    subjectOptions.assignAll(subjects.toList()..sort());

    _applyFilter();
    isLoading.value = false;
  }

  Future<void> _loadClassrooms() async {
    _classroomNames.clear();
    await _classroomSvc.getAll(callBack: (list) {
      for (final c in list.whereType<ClassroomModel>()) {
        if ((c.isAllBranches || c.branchIds.contains(branchId)) &&
            c.isActive &&
            c.key != null) {
          _classroomNames[c.key!] = c.name;
        }
      }
    });
  }

  String classNameOf(String id) => _classroomNames[id] ?? '';

  void selectClass(String? id) {
    classFilter.value = id;
    _applyFilter();
  }

  void selectSubject(String? subject) {
    subjectFilter.value = subject;
    _applyFilter();
  }

  void _applyFilter() {
    filtered.assignAll(
      _all.where((a) {
        if (classFilter.value != null && a.classroomId != classFilter.value) {
          return false;
        }
        if (subjectFilter.value != null &&
            (a.subjectName ?? '').trim() != subjectFilter.value) {
          return false;
        }
        return true;
      }).toList(),
    );
  }
}
