import 'dart:async';
import '../../../../index/index_main.dart';
import '../../../../Data/models/nursery_course/nursery_course_model.dart';

class ReceptionistCoursesController extends GetxController {
  final _service = CourseService();

  final courses   = <NurseryCourse>[].obs;
  final isLoading = true.obs;
  final filterCat = Rxn<CourseCategory>();

  // Live enrolled-children count per course.
  final enrolledCounts = <String, int>{}.obs;

  StreamSubscription? _sub;
  final Map<String, StreamSubscription> _enrollSubs = {};

  @override
  void onInit() {
    super.onInit();
    _sub = _service.watchAllCourses().listen((list) {
      courses.value = list;
      isLoading.value = false;
      _syncEnrollmentWatchers(list);
    });
  }

  @override
  void onClose() {
    _sub?.cancel();
    for (final s in _enrollSubs.values) {
      s.cancel();
    }
    _enrollSubs.clear();
    super.onClose();
  }

  void _syncEnrollmentWatchers(List<NurseryCourse> list) {
    final ids = list.map((c) => c.id).toSet();
    // Drop watchers for removed courses.
    _enrollSubs.keys.where((id) => !ids.contains(id)).toList().forEach((id) {
      _enrollSubs.remove(id)?.cancel();
      enrolledCounts.remove(id);
    });
    // Add watchers for new courses.
    for (final c in list) {
      if (_enrollSubs.containsKey(c.id)) continue;
      _enrollSubs[c.id] = _service.watchEnrollments(c.id).listen((enrolled) {
        enrolledCounts[c.id] = enrolled.length;
      });
    }
  }

  List<NurseryCourse> get filtered {
    if (filterCat.value == null) return courses;
    return courses.where((c) => c.category == filterCat.value).toList();
  }

  List<CourseCategory> get availableCategories {
    final present = courses.map((c) => c.category).toSet();
    return CourseCategory.values.where(present.contains).toList();
  }

  void filterBy(CourseCategory? cat) => filterCat.value = cat;

  int enrolledCount(String courseId) => enrolledCounts[courseId] ?? 0;
}
