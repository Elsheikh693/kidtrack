import '../../../../index/index_main.dart';

/// Drives the per-classroom exams list for staff (teacher + manager). Opened via
/// `Get.to(() => ClassroomExamsView(), arguments: {classroomId, classroomName})`
/// so a fresh instance loads each classroom. Owns creating exams; grading is a
/// separate screen ([ExamGradingController]).
class ClassroomExamsController extends GetxController {
  late final ExamParentService _examService;
  late final ExamResultParentService _resultService;
  late final TeacherActivityService _teacherService;

  final exams = <ExamModel>[].obs;

  /// examId → how many children already have a graded result (for the card
  /// progress line).
  final gradedCounts = <String, int>{}.obs;

  /// Size of the classroom roster (denominator of the progress line).
  final rosterSize = 0.obs;

  final isLoading = false.obs;

  late final String classroomId;
  late final String classroomName;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    classroomId = args['classroomId']?.toString() ?? '';
    classroomName = args['classroomName']?.toString() ?? '';

    _examService = Get.find<ExamParentService>();
    _resultService = Get.find<ExamResultParentService>();
    _teacherService = Get.find<TeacherActivityService>();

    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final list = await _examService.getForClassroom(classroomId);
      exams.assignAll(list);
      await _loadCounts(list);
      await _loadRoster();
    } catch (_) {
      // A soft failure leaves the (possibly empty) list — the empty state shows.
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadCounts(List<ExamModel> list) async {
    final counts = <String, int>{};
    for (final e in list) {
      final id = e.key;
      if (id == null) continue;
      final results = await _resultService.getForExam(id);
      counts[id] = results.where((r) => r.grade.isNotEmpty).length;
    }
    gradedCounts.assignAll(counts);
  }

  Future<void> _loadRoster() async {
    final nurseryId = SessionService().nurseryId ?? '';
    final children =
        await _teacherService.loadChildren(nurseryId, classroomId);
    rosterSize.value = children.length;
  }

  /// Creates a new class exam then reloads. [subject] is required; [title] is an
  /// optional friendly name.
  Future<void> createExam({
    required String subject,
    required String title,
    required DateTime date,
  }) async {
    final session = SessionService();
    final exam = ExamModel(
      // A client-generated key is REQUIRED: the CRUD layer PATCHes to
      // `exams/{key}.json`, so an empty key would write the fields to the node
      // root instead of creating a record (the exam would "vanish").
      key: 'exam_${DateTime.now().millisecondsSinceEpoch}',
      nurseryId: session.nurseryId ?? '',
      branchId: session.branchId ?? '',
      classroomId: classroomId,
      classroomName: classroomName,
      subjectName: subject.trim(),
      title: title.trim(),
      examDate: _startOfDay(date),
      createdBy: session.userId ?? '',
      createdByName: session.currentUser?.displayName ?? '',
      createdByRole: session.userType?.name ?? '',
    );

    Loader.show();
    try {
      await _examService.add(
        item: exam,
        callBack: (status) {
          if (status == ResponseStatus.success) {
            Loader.showSuccess('exam_create_success'.tr);
          } else {
            Loader.showError('exam_create_error'.tr);
          }
        },
      );
      await load();
    } catch (_) {
      Loader.showError('exam_create_error'.tr);
    }
  }

  Future<void> deleteExam(String id) async {
    Loader.show();
    try {
      await _examService.delete(
        id: id,
        callBack: (status) {
          if (status == ResponseStatus.success) {
            Loader.showSuccess('exam_delete_success'.tr);
          } else {
            Loader.showError('exam_delete_error'.tr);
          }
        },
      );
      await load();
    } catch (_) {
      Loader.showError('exam_delete_error'.tr);
    }
  }

  static int _startOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day).millisecondsSinceEpoch;
}
