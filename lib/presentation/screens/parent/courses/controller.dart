import '../../../../index/index_main.dart';

class ParentCoursesController extends GetxController {
  final _session = SessionService();
  final _service = CourseService();

  final activeTab        = 0.obs;
  final courses          = <NurseryCourse>[].obs;
  final isLoading        = true.obs;
  final progress         = <String, CourseEnrollment>{}.obs;
  final selectedCategory = Rxn<CourseCategory>();

  StreamSubscription? _coursesSub;
  StreamSubscription? _progressSub;

  String get childName  => _session.currentUser?.displayName ?? 'الأهل';
  String get childStatus => 'inside';
  String? get childImage => null;

  @override
  void onInit() {
    super.onInit();
    _coursesSub = _service.watchActiveCourses().listen((list) {
      courses.value = _filterByBranch(list);
      isLoading.value = false;
    });

    final uid = _session.userId;
    if (uid != null) {
      _progressSub = _service.watchProgress(uid).listen((map) {
        progress.value = map;
      });
    }
  }

  @override
  void onClose() {
    _coursesSub?.cancel();
    _progressSub?.cancel();
    super.onClose();
  }

  // Show all-branch courses plus those scoped to the parent's branch.
  // If the parent has no branch set, fall back to showing everything.
  List<NurseryCourse> _filterByBranch(List<NurseryCourse> list) {
    final myBranch = _session.branchId;
    if (myBranch == null || myBranch.isEmpty) return list;
    return list
        .where((c) => c.isAllBranches || c.branchIds.contains(myBranch))
        .toList();
  }

  void switchTab(int i) => activeTab.value = i;

  void selectCategory(CourseCategory? c) => selectedCategory.value = c;

  // ── Enrollment helpers ──────────────────────────────────────────────────────

  List<NurseryCourse> get availableCourses => courses;

  // Courses filtered by the selected category chip (null = all)
  List<NurseryCourse> get filteredCourses {
    final cat = selectedCategory.value;
    if (cat == null) return courses;
    return courses.where((c) => c.category == cat).toList();
  }

  // Categories that actually have courses, ordered by enum
  List<CourseCategory> get availableCategories {
    final present = courses.map((c) => c.category).toSet();
    return CourseCategory.values.where(present.contains).toList();
  }

  List<NurseryCourse> get enrolledCourses {
    final ids = progress.keys.toSet();
    return courses.where((c) => ids.contains(c.id)).toList();
  }

  int get totalCount => courses.length;
  int get enrolledCount => enrolledCourses.length;

  CourseEnrollment? enrollmentFor(String courseId) => progress[courseId];

  bool isEnrolled(String courseId) => progress.containsKey(courseId);

  // ── Mark lesson completed ───────────────────────────────────────────────────

  Future<void> markCompleted(String courseId, String lessonId) async {
    final uid = _session.userId;
    if (uid == null) return;
    await _service.markLessonCompleted(uid, courseId, lessonId);
  }
}
