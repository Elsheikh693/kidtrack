import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../../../../index/index_main.dart';
import '../../../../Data/models/nursery_course/nursery_course_model.dart';

class CourseEnrollController extends GetxController {
  CourseEnrollController(this.course);

  final NurseryCourse course;
  final _db = FirebaseDatabase.instance;
  final _service = CourseService();
  final _session = SessionService();

  final isLoading   = true.obs;
  final searchQuery = ''.obs;
  final enrolledIds = <String>{}.obs;

  List<ChildModel> _allChildren = [];
  final children = <ChildModel>[].obs;

  StreamSubscription? _enrollSub;

  @override
  void onInit() {
    super.onInit();
    _loadChildren();
    _enrollSub = _service.watchEnrollments(course.id).listen((list) {
      enrolledIds.assignAll(list.map((e) => e.childId));
    });
  }

  @override
  void onClose() {
    _enrollSub?.cancel();
    super.onClose();
  }

  Future<void> _loadChildren() async {
    isLoading.value = true;
    final nurseryId = _session.nurseryId ?? '';
    final branchId = _session.branchId ?? '';
    if (nurseryId.isEmpty) {
      isLoading.value = false;
      return;
    }
    try {
      final snap = await _db.ref('platform/$nurseryId/children').get();
      if (snap.exists && snap.value != null) {
        final map = Map<String, dynamic>.from(snap.value as Map);
        _allChildren = map.entries
            .where((e) => e.value is Map)
            .map((e) => ChildModel.fromJson(
                Map<String, dynamic>.from(e.value as Map),
                key: e.key))
            .where((c) =>
                (branchId.isEmpty || c.branchId == branchId) &&
                c.status == 'active')
            .toList()
          ..sort((a, b) => a.fullName.compareTo(b.fullName));
      }
    } catch (e) {
      AppLogger.error('COURSE_ENROLL', 'loadChildren: $e');
    }
    isLoading.value = false;
    _rebuild();
  }

  void _rebuild() {
    final q = searchQuery.value.trim().toLowerCase();
    children.assignAll(
      q.isEmpty
          ? _allChildren
          : _allChildren
              .where((c) => c.fullName.toLowerCase().contains(q))
              .toList(),
    );
  }

  void setSearch(String q) {
    searchQuery.value = q;
    _rebuild();
  }

  bool isEnrolled(String childId) => enrolledIds.contains(childId);

  int get enrolledTotal => enrolledIds.length;

  Future<void> toggle(ChildModel child) async {
    final id = child.key;
    if (id == null) return;
    if (enrolledIds.contains(id)) {
      await _service.unenrollChild(course.id, id);
    } else {
      await _service.enrollChild(
        courseId: course.id,
        childId: id,
        childName: child.fullName,
        childImage: child.hasImage ? child.profileImage : null,
      );
    }
    // Stream refreshes enrolledIds automatically.
  }
}
