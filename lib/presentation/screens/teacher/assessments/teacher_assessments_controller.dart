import '../../../../index/index_main.dart';

/// Teacher's list of assessments to grade. Shows ACTIVE runs that touch any of
/// the teacher's classrooms, each with a graded/total progress read off the
/// materialised child rows.
class TeacherAssessmentsController extends GetxController {
  late final AssessmentRunParentService _runs;
  late final ChildAssessmentParentService _childAssessments;
  late final ClassroomParentService _classrooms;
  late final StaffParentService _staff;
  late final TeacherRunGradingController _grading;
  final _session = SessionService();

  final RxList<AssessmentRunModel> runs = <AssessmentRunModel>[].obs;
  final RxMap<String, List<ChildAssessmentModel>> rowsByRun =
      <String, List<ChildAssessmentModel>>{}.obs;
  final RxBool isLoading = true.obs;

  final Set<String> _myClassroomIds = {};

  String get uid => _session.userId ?? '';
  String get nurseryId => _session.nurseryId ?? '';

  @override
  void onInit() {
    super.onInit();
    _runs = Get.find<AssessmentRunParentService>();
    _childAssessments = Get.find<ChildAssessmentParentService>();
    _classrooms = Get.find<ClassroomParentService>();
    _staff = Get.find<StaffParentService>();
    _grading = Get.find<TeacherRunGradingController>();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await _resolveMyClassrooms();
    await _loadRunsAndRows();
    isLoading.value = false;
  }

  /// A teacher's classrooms = classrooms they lead (teacherId == uid) plus the
  /// classroom on their staff record. Resolved via ParentServices (branch-scoped).
  Future<void> _resolveMyClassrooms() async {
    _myClassroomIds.clear();
    await _classrooms.getAll(callBack: (list) {
      for (final c in list.whereType<ClassroomModel>()) {
        if (c.teacherId == uid && c.key != null) _myClassroomIds.add(c.key!);
      }
    });
    await _staff.getAll(callBack: (list) {
      for (final s in list.whereType<StaffModel>()) {
        if (s.uid == uid && s.classroomId != null && s.classroomId!.isNotEmpty) {
          _myClassroomIds.add(s.classroomId!);
        }
      }
    });
  }

  Future<void> _loadRunsAndRows() async {
    await _runs.getAll(callBack: (list) {
      runs.value = list
          .whereType<AssessmentRunModel>()
          .where((r) =>
              r.isActive &&
              r.classroomIds.any(_myClassroomIds.contains))
          .toList()
        ..sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
    });

    await _childAssessments.getAll(callBack: (list) {
      final map = <String, List<ChildAssessmentModel>>{};
      for (final row in list.whereType<ChildAssessmentModel>()) {
        if (row.classroomId != null &&
            _myClassroomIds.contains(row.classroomId)) {
          map.putIfAbsent(row.runId, () => []).add(row);
        }
      }
      rowsByRun.value = map;
    });
  }

  /// (graded, total) for a run — graded = rows past the in-progress state.
  (int, int) progressFor(String runId) {
    final rows = rowsByRun[runId] ?? const [];
    final graded =
        rows.where((r) => r.status != kChildStatusInProgress).length;
    return (graded, rows.length);
  }

  void openRun(AssessmentRunModel run) {
    _grading.open(run, _myClassroomIds.toList());
    Get.to(
      () => const TeacherRunGradingView(),
      transition: Transition.cupertino,
    )?.then((_) => loadData());
  }
}
