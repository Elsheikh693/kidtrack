import '../../../../index/index_main.dart';

/// Holds ONE run the teacher is grading: its child rows (limited to the
/// teacher's classrooms) with names/photos, and the save path for a child's
/// attempt. Registered globally; [open] rebinds it to the tapped run.
class TeacherRunGradingController extends GetxController {
  late final ChildAssessmentParentService _childAssessments;
  late final ChildParentService _children;
  final _session = SessionService();

  final Rxn<AssessmentRunModel> run = Rxn<AssessmentRunModel>();
  final RxList<ChildAssessmentModel> rows = <ChildAssessmentModel>[].obs;
  final RxBool isLoading = true.obs;

  final Map<String, ChildModel> _childById = {};
  List<String> _myClassroomIds = const [];

  String get nurseryId => _session.nurseryId ?? '';
  String get uid => _session.userId ?? '';

  @override
  void onInit() {
    super.onInit();
    _childAssessments = Get.find<ChildAssessmentParentService>();
    _children = Get.find<ChildParentService>();
  }

  /// Rebind to a run and load its child rows + child details.
  Future<void> open(AssessmentRunModel r, List<String> myClassroomIds) async {
    run.value = r;
    _myClassroomIds = myClassroomIds;
    await reload();
  }

  Future<void> reload() async {
    isLoading.value = true;
    final r = run.value;
    if (r == null) {
      isLoading.value = false;
      return;
    }

    await _children.getAll(callBack: (list) {
      _childById.clear();
      for (final c in list.whereType<ChildModel>()) {
        if (c.key != null) _childById[c.key!] = c;
      }
    });

    await _childAssessments.getAll(callBack: (list) {
      rows.value = list
          .whereType<ChildAssessmentModel>()
          .where((row) =>
              row.runId == r.key &&
              row.classroomId != null &&
              _myClassroomIds.contains(row.classroomId))
          .toList()
        ..sort((a, b) => childName(a.childId).compareTo(childName(b.childId)));
    });
    isLoading.value = false;
  }

  String childName(String childId) {
    final c = _childById[childId];
    if (c == null) return '';
    return '${c.firstName} ${c.lastName}'.trim();
  }

  String? childImage(String childId) => _childById[childId]?.profileImage;

  ChildAssessmentModel? rowForChild(String childId) {
    for (final row in rows) {
      if (row.childId == childId) return row;
    }
    return null;
  }

  void openGrade(String childId) {
    Get.to(
      () => TeacherGradeChildView(childId: childId),
      transition: Transition.cupertino,
    )?.then((_) => reload());
  }

  /// Persist a child's attempt. A first grade writes attempt 1 (official); a
  /// scheduled retake APPENDS a new attempt (kind retake) covering the scoped
  /// items — the official attempt is left for the manager to choose. Either way
  /// the child moves to teacher_completed for (re)review.
  Future<void> saveChild({
    required String childId,
    required List<AssessmentItemResult> results,
    required String overallNote,
  }) async {
    final row = rowForChild(childId);
    if (row == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final note = overallNote.trim().isEmpty ? null : overallNote.trim();
    final total = AssessmentAttempt.computeTotalFraction(results);

    final schedule = row.latestAttempt;
    final isRetake = schedule?.hasScheduledRetake ?? false;

    late final List<AssessmentAttempt> attempts;
    if (isRetake) {
      final nextNo = row.attempts
              .map((a) => a.attemptNo)
              .fold<int>(0, (a, b) => a > b ? a : b) +
          1;
      attempts = [
        ...row.attempts,
        AssessmentAttempt(
          attemptNo: nextNo,
          date: now,
          kind: kAttemptKindRetake,
          scopedItemIds: schedule!.scheduledRetakeItemIds,
          results: results,
          overallNote: note,
          totalFraction: total,
        ),
      ];
    } else {
      attempts = [
        AssessmentAttempt(
          attemptNo: 1,
          date: now,
          kind: kAttemptKindOfficial,
          results: results,
          overallNote: note,
          totalFraction: total,
        ),
      ];
    }

    final updated = row.copyWith(
      attempts: attempts,
      officialAttemptNo: isRetake ? row.officialAttemptNo : 1,
      status: kChildStatusTeacherCompleted,
    );

    Loader.show();
    await _childAssessments.update(
      item: updated,
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('assessment_grade_saved'.tr);
          Get.back();
        } else {
          Loader.showError('assessment_grade_error'.tr);
        }
      },
    );
  }
}
