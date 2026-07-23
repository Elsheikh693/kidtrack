import '../../../../index/index_main.dart';
import 'package:firebase_database/firebase_database.dart';

class TeacherAssessmentController extends GetxController {
  final _service = TeacherAcademicService();
  final _session = SessionService();

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;

  final RxList<ClassroomModel> myClassrooms = <ClassroomModel>[].obs;
  final RxList<ChildModel> children = <ChildModel>[].obs;
  final Rx<ClassroomModel?> selectedClassroom = Rx<ClassroomModel?>(null);

  // childId → DailyRating
  final RxMap<String, DailyRating> ratings = <String, DailyRating>{}.obs;
  // childId → comment
  final RxMap<String, String> comments = <String, String>{}.obs;

  // Track which children have existing assessments today
  final RxMap<String, DailyAssessmentModel> existing =
      <String, DailyAssessmentModel>{}.obs;

  String get today {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String get nurseryId => _session.nurseryId ?? '';

  int get assessedCount => ratings.entries
      .where((e) => existing[e.key] != null || ratings[e.key] != null)
      .length;

  @override
  void onInit() {
    super.onInit();
    _loadClassrooms();
  }

  Future<void> _loadClassrooms() async {
    isLoading.value = true;
    try {
      final assignment = await _service.loadAssignment();
      if (assignment == null || assignment.classroomIds.isEmpty) {
        isLoading.value = false;
        return;
      }

      final snap = await FirebaseDatabase.instance
          .ref('platform/$nurseryId/classrooms')
          .get();
      if (snap.exists && snap.value is Map) {
        final data = snap.value as Map;
        myClassrooms.value = data.entries
            .where((e) =>
                e.value is Map &&
                assignment.classroomIds.contains(e.key.toString()))
            .map((e) => ClassroomModel.fromJson(
                  Map<String, dynamic>.from(e.value as Map),
                  key: e.key.toString(),
                ))
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
      }

      if (myClassrooms.isNotEmpty) {
        selectedClassroom.value = myClassrooms.first;
        await _loadChildren();
      }
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> selectClassroom(ClassroomModel c) async {
    selectedClassroom.value = c;
    await _loadChildren();
  }

  Future<void> _loadChildren() async {
    final cId = selectedClassroom.value?.key;
    if (cId == null) return;
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _service.loadClassroomChildren(cId),
        _service.loadTodayAssessments(classroomId: cId, date: today),
      ]);
      children.value = results[0] as List<ChildModel>;
      final existingMap =
          results[1] as Map<String, DailyAssessmentModel>;
      existing.value = existingMap;

      // Initialize ratings from existing or default to 'good'
      final newRatings = <String, DailyRating>{};
      final newComments = <String, String>{};
      for (final child in children) {
        final id = child.key ?? '';
        if (existingMap.containsKey(id)) {
          newRatings[id] = existingMap[id]!.rating;
          newComments[id] = existingMap[id]!.comment ?? '';
        } else {
          newRatings[id] = DailyRating.good;
          newComments[id] = '';
        }
      }
      ratings.value = newRatings;
      comments.value = newComments;
    } catch (_) {}
    isLoading.value = false;
  }

  void setRating(String childId, DailyRating rating) {
    ratings[childId] = rating;
    ratings.refresh();
  }

  void setComment(String childId, String comment) {
    comments[childId] = comment;
  }

  Future<void> saveAll() async {
    final cId = selectedClassroom.value?.key;
    if (cId == null || isSaving.value) return;
    isSaving.value = true;
    try {
      final commentMap = <String, String?>{};
      for (final id in comments.keys) {
        commentMap[id] = comments[id]?.isEmpty == true ? null : comments[id];
      }
      await _service.saveBatchAssessments(
        classroomId: cId,
        date: today,
        ratings: Map.from(ratings),
        comments: commentMap,
      );
      // Refresh to show saved state
      await _loadChildren();
      Get.snackbar(
        'teacheract34_saved_title'.tr,
        'teacheract34_saved_body'.trParams({'count': '${children.length}'}),
        backgroundColor: const Color(0xFF16A34A).withValues(alpha: 0.1),
        colorText: const Color(0xFF166534),
        duration: const Duration(seconds: 2),
      );
    } catch (_) {
      Get.snackbar('teacheract34_error_title'.tr, 'teacheract34_save_error'.tr);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> refresh() => _loadChildren();
}
