import 'package:firebase_database/firebase_database.dart';
import '../../../../index/index_main.dart';

class TeacherClassesController extends GetxController {
  final _service = TeacherAcademicService();
  final _session = SessionService();
  final _db = FirebaseDatabase.instance;

  final RxBool isLoading = true.obs;
  final RxList<ClassroomModel> myClassrooms = <ClassroomModel>[].obs;
  final RxList<SubjectModel> allSubjects = <SubjectModel>[].obs;
  final Rx<TeacherAssignmentModel?> assignment = Rx(null);

  // classroomId → child count
  final RxMap<String, int> childCounts = <String, int>{}.obs;

  // classroomId → number of children assessed today
  final RxMap<String, int> todayAssessedCounts = <String, int>{}.obs;

  // classroomId → total active children (for progress denominator)
  final RxMap<String, int> totalChildCounts = <String, int>{}.obs;

  String get _n => 'platform/${_session.nurseryId}';

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  @override
  Future<void> refresh() => _load();

  Future<void> _load() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _service.loadAssignment(),
        _service.loadClassrooms(),
        _service.loadSubjects(),
      ]);

      assignment.value = results[0] as TeacherAssignmentModel?;
      final allCl = results[1] as List<ClassroomModel>;
      allSubjects.value = results[2] as List<SubjectModel>;

      // Only show classrooms assigned to this teacher
      final asgn = assignment.value;
      if (asgn != null && asgn.classroomIds.isNotEmpty) {
        myClassrooms.value = allCl
            .where((c) => asgn.classroomIds.contains(c.key))
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
      } else {
        myClassrooms.value = allCl;
      }

      await Future.wait([
        _loadChildCounts(),
        _loadTodayAssessedCounts(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadChildCounts() async {
    final counts = <String, int>{};
    for (final cl in myClassrooms) {
      try {
        final snap = await _db
            .ref('$_n/children')
            .orderByChild('classroomId')
            .equalTo(cl.key ?? '')
            .get();
        if (snap.exists && snap.value is Map) {
          counts[cl.key ?? ''] = (snap.value as Map)
              .values
              .where((v) =>
                  v is Map &&
                  (v['status'] ?? 'active') == 'active' &&
                  _session.seesBranch(v['branchId']?.toString()))
              .length;
        } else {
          counts[cl.key ?? ''] = 0;
        }
      } catch (_) {
        counts[cl.key ?? ''] = 0;
      }
    }
    childCounts.value = counts;
  }

  Future<void> _loadTodayAssessedCounts() async {
    final today = _todayKey();
    final assessed = <String, int>{};
    try {
      final snap = await _db
          .ref('$_n/dailyAssessments')
          .orderByChild('date')
          .equalTo(today)
          .get();
      if (snap.exists && snap.value is Map) {
        for (final e in (snap.value as Map).entries) {
          if (e.value is! Map) continue;
          final cId = e.value['classroomId']?.toString() ?? '';
          if (cId.isNotEmpty) {
            assessed[cId] = (assessed[cId] ?? 0) + 1;
          }
        }
      }
    } catch (_) {}
    todayAssessedCounts.value = assessed;
  }

  List<SubjectModel> subjectsForClassroom(String classroomId) {
    final asgn = assignment.value;
    if (asgn == null) return [];
    final sIds = asgn.subjectsForClassroom(classroomId).toSet();
    return allSubjects.where((s) => sIds.contains(s.key)).toList();
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
