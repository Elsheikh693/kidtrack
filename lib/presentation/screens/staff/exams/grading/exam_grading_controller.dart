import 'dart:io';

import '../../../../../index/index_main.dart';

/// Drives the grading screen for ONE exam: the classroom roster with each
/// child's editable result (verbal grade + photo of their paper + optional
/// note). Opened via `Get.to(() => ExamGradingView(), arguments: {exam})`.
/// Each per-child card saves independently through [saveResult].
class ExamGradingController extends GetxController {
  late final ExamResultParentService _resultService;
  late final TeacherActivityService _teacherService;
  late final FirebaseCredentialsService _credentials;

  final children = <ChildModel>[].obs;

  /// childId → the child's saved result (prefills the card, drives progress).
  final results = <String, ExamResultModel>{}.obs;

  final isLoading = false.obs;

  late final ExamModel exam;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    exam = args['exam'] as ExamModel;

    _resultService = Get.find<ExamResultParentService>();
    _teacherService = Get.find<TeacherActivityService>();
    _credentials = Get.find<FirebaseCredentialsService>();

    load();
  }

  int get gradedCount => results.values.where((r) => r.grade.isNotEmpty).length;

  ExamResultModel? existingFor(String childId) => results[childId];

  Future<void> load() async {
    isLoading.value = true;
    try {
      final nurseryId = SessionService().nurseryId ?? '';
      final roster =
          await _teacherService.loadChildren(nurseryId, exam.classroomId);
      children.assignAll(roster);

      final existing = await _resultService.getForExam(exam.key ?? '');
      results.assignAll({for (final r in existing) r.childId: r});
    } catch (_) {
      // Empty roster / results just render the empty state.
    } finally {
      isLoading.value = false;
    }
  }

  /// Upserts one child's result. [paperFile] (a freshly picked photo) is
  /// uploaded first; when null the [existingPaperUrl] is kept.
  Future<void> saveResult({
    required ChildModel child,
    required ExamGrade grade,
    File? paperFile,
    String? existingPaperUrl,
    required String note,
  }) async {
    Loader.show();
    try {
      String? paperUrl = existingPaperUrl;
      if (paperFile != null) {
        final uploaded = await _uploadPaper(child, paperFile);
        if (uploaded != null) paperUrl = uploaded;
      }

      final session = SessionService();
      final result = ExamResultModel(
        key: ExamResultModel.buildKey(exam.key ?? '', child.key ?? ''),
        nurseryId: exam.nurseryId,
        branchId: exam.branchId,
        examId: exam.key ?? '',
        childId: child.key ?? '',
        childName: child.fullName,
        classroomId: exam.classroomId,
        subjectName: exam.subjectName,
        examTitle: exam.title,
        examDate: exam.examDate,
        grade: grade.key,
        paperUrl: paperUrl,
        note: note.trim(),
        gradedBy: session.userId ?? '',
        gradedByName: session.currentUser?.displayName ?? '',
      );

      await _resultService.upsert(
        item: result,
        callBack: (status) {
          if (status == ResponseStatus.success) {
            results[result.childId] = result;
            Loader.showSuccess('exam_grade_saved'.tr);
          } else {
            Loader.showError('exam_grade_save_error'.tr);
          }
        },
      );
    } catch (_) {
      Loader.showError('exam_grade_save_error'.tr);
    }
  }

  Future<String?> _uploadPaper(ChildModel child, File file) async {
    final key =
        'examPapers/${exam.nurseryId}/${exam.key}/${child.key}_${DateTime.now().millisecondsSinceEpoch}';
    final result = await _credentials.uploadImage(key, file);
    return result.fold((_) => null, (url) => url);
  }
}
