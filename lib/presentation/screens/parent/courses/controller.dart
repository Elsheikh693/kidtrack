import '../../../../index/index_main.dart';
import '../../../../Data/models/course_enrollment/course_enrollment_model.dart';

class ParentCoursesController extends GetxController {
  final _session = SessionService();
  final _service = CourseService();

  final activeTab        = 0.obs;
  final courses          = <NurseryCourse>[].obs;
  final isLoading        = true.obs;
  final selectedCategory = Rxn<CourseCategory>();

  // Reception-driven enrollment: courseId → set of enrolled childIds.
  final _enrollments = <String, Set<String>>{}.obs;
  // courseId → attendance records (all children), for per-card track progress.
  final _attendance  = <String, List<CourseSessionAttendance>>{}.obs;

  StreamSubscription? _coursesSub;
  StreamSubscription? _enrollSub;
  StreamSubscription? _attendSub;

  ActiveChildService? get _activeChild =>
      Get.isRegistered<ActiveChildService>()
          ? Get.find<ActiveChildService>()
          : null;

  String get _activeChildId => _activeChild?.childId.value ?? '';

  String get childName  => _session.currentUser?.displayName ?? 'ownertabs20_family'.tr;
  String get childStatus => 'inside';
  String? get childImage => null;

  @override
  void onInit() {
    super.onInit();
    _coursesSub = _service.watchActiveCourses().listen((list) {
      courses.value = _filterByBranch(list);
      isLoading.value = false;
    });
    _enrollSub = _service.watchAllEnrollments().listen((map) {
      _enrollments.value = map;
    });
    _attendSub = _service.watchAllAttendance().listen((map) {
      _attendance.value = map;
    });
  }

  @override
  void onClose() {
    _coursesSub?.cancel();
    _enrollSub?.cancel();
    _attendSub?.cancel();
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

  // ── Enrollment helpers (reception-driven, per active child) ─────────────────

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

  // Course ids the active child is enrolled in (reception added them).
  Set<String> get enrolledCourseIds {
    final cid = _activeChildId;
    if (cid.isEmpty) return const {};
    final ids = <String>{};
    _enrollments.forEach((courseId, kids) {
      if (kids.contains(cid)) ids.add(courseId);
    });
    return ids;
  }

  List<NurseryCourse> get enrolledCourses {
    final ids = enrolledCourseIds;
    return courses.where((c) => ids.contains(c.id)).toList();
  }

  int get totalCount => courses.length;
  int get enrolledCount => enrolledCourses.length;

  bool isEnrolled(String courseId) => enrolledCourseIds.contains(courseId);

  // How many sessions the active child has attended (present) in a course.
  int attendedCount(String courseId) {
    final cid = _activeChildId;
    if (cid.isEmpty) return 0;
    final records = _attendance[courseId];
    if (records == null) return 0;
    return records.where((r) => r.childId == cid && r.isPresent).length;
  }

  // Track progress (0..1) for the active child on a course.
  double progressFor(NurseryCourse course) {
    final total = course.totalSessions;
    if (total <= 0) return 0;
    return (attendedCount(course.id) / total).clamp(0, 1).toDouble();
  }
}
