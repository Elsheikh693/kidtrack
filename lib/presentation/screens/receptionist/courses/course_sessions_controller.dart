import 'dart:async';
import '../../../../index/index_main.dart';
import '../../../../Data/models/nursery_course/nursery_course_model.dart';
import '../../../../Data/models/course_enrollment/course_enrollment_model.dart';

class CourseSessionsController extends GetxController {
  CourseSessionsController(this.course);

  final NurseryCourse course;
  final _service = CourseService();

  final isLoading      = true.obs;
  final selectedIndex  = 1.obs; // 1-based session number
  final enrolled       = <CourseChildEnrollment>[].obs;
  // key: "sessionIndex_childId" → attendance record
  final _attendance    = <String, CourseSessionAttendance>{}.obs;

  StreamSubscription? _enrollSub;
  StreamSubscription? _attSub;

  int get totalSessions => course.totalSessions;

  @override
  void onInit() {
    super.onInit();
    _enrollSub = _service.watchEnrollments(course.id).listen((list) {
      enrolled.value = list;
      isLoading.value = false;
    });
    _attSub = _service.watchAttendance(course.id).listen((list) {
      _attendance.value = {for (final a in list) '${a.sessionIndex}_${a.childId}': a};
    });
  }

  @override
  void onClose() {
    _enrollSub?.cancel();
    _attSub?.cancel();
    super.onClose();
  }

  void selectSession(int index) => selectedIndex.value = index;

  CourseSessionAttendance? attendanceFor(int sessionIndex, String childId) =>
      _attendance['${sessionIndex}_$childId'];

  bool isPresent(String childId) =>
      attendanceFor(selectedIndex.value, childId)?.isPresent ?? false;

  bool isAbsent(String childId) {
    final rec = attendanceFor(selectedIndex.value, childId);
    return rec != null && !rec.isPresent;
  }

  // No attendance record yet for the selected session → not marked.
  bool isUnmarked(String childId) =>
      attendanceFor(selectedIndex.value, childId) == null;

  bool hasCheckedOut(String childId) =>
      attendanceFor(selectedIndex.value, childId)?.hasCheckedOut ?? false;

  // How many enrolled children attended a given session.
  int presentCountFor(int sessionIndex) => enrolled
      .where((e) => attendanceFor(sessionIndex, e.childId)?.isPresent ?? false)
      .length;

  int get presentCountSelected => presentCountFor(selectedIndex.value);

  // Sessions a child has attended so far (for the track dot on their tile).
  int attendedCountForChild(String childId) {
    var n = 0;
    for (var i = 1; i <= totalSessions; i++) {
      if (attendanceFor(i, childId)?.isPresent ?? false) n++;
    }
    return n;
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  Future<void> checkIn(String childId) async {
    final sessionIndex = selectedIndex.value;
    // Only notify the parent on a fresh check-in (not on a re-mark), so
    // re-tapping doesn't spam the parent.
    final wasPresent = attendanceFor(sessionIndex, childId)?.isPresent ?? false;

    await _service.markSessionCheckIn(
      courseId: course.id,
      sessionIndex: sessionIndex,
      childId: childId,
    );

    if (!wasPresent) {
      String childName = '';
      for (final e in enrolled) {
        if (e.childId == childId) {
          childName = e.childName;
          break;
        }
      }
      await _service.notifySessionAttendance(
        course: course,
        sessionIndex: sessionIndex,
        childId: childId,
        childName: childName,
      );
    }
  }

  Future<void> markAbsent(String childId) async {
    await _service.markSessionAbsent(
      courseId: course.id,
      sessionIndex: selectedIndex.value,
      childId: childId,
    );
  }

  Future<void> checkOut(String childId) async {
    await _service.markSessionCheckOut(
      courseId: course.id,
      sessionIndex: selectedIndex.value,
      childId: childId,
    );
  }

  Future<void> undo(String childId) async {
    await _service.clearSessionAttendance(
      courseId: course.id,
      sessionIndex: selectedIndex.value,
      childId: childId,
    );
  }
}
