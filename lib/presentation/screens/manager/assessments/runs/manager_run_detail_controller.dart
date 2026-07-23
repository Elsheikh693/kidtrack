import '../../../../../index/index_main.dart';

/// Manager review of one run: sees every child's status/score, publishes
/// completed children (making them parent-visible), freezes with a lock, and —
/// the audited exception — unlocks for a correction.
class ManagerRunDetailController extends GetxController {
  late final ChildAssessmentParentService _childAssessments;
  late final ChildParentService _children;
  late final StaffParentService _staff;
  final _session = SessionService();

  final Rxn<AssessmentRunModel> run = Rxn<AssessmentRunModel>();
  final RxList<ChildAssessmentModel> rows = <ChildAssessmentModel>[].obs;
  final RxList<StaffModel> teachers = <StaffModel>[].obs;
  final RxBool isLoading = true.obs;

  final Map<String, ChildModel> _childById = {};

  String get uid => _session.userId ?? '';

  @override
  void onInit() {
    super.onInit();
    _childAssessments = Get.find<ChildAssessmentParentService>();
    _children = Get.find<ChildParentService>();
    _staff = Get.find<StaffParentService>();
  }

  Future<void> open(AssessmentRunModel r) async {
    run.value = r;
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
    await _staff.getAll(callBack: (list) {
      teachers.value = list
          .whereType<StaffModel>()
          .where((s) => s.role.isClassroomRole)
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    });
    await _childAssessments.getAll(callBack: (list) {
      rows.value = list
          .whereType<ChildAssessmentModel>()
          .where((row) => row.runId == r.key)
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

  // ─── Counts (for the header summary) ─────────────────────────────────────
  int get pendingCount =>
      rows.where((r) => r.status == kChildStatusInProgress).length;
  int get completedCount =>
      rows.where((r) => r.status == kChildStatusTeacherCompleted).length;
  int get publishedCount => rows
      .where((r) =>
          r.status == kChildStatusPublished || r.status == kChildStatusLocked)
      .length;

  bool get hasCompletedToPublish => completedCount > 0;

  /// Tapping a child: an ungraded one goes STRAIGHT to grading; a graded one
  /// opens the result (where publish / lock / edit / retake live).
  void openChild(ChildAssessmentModel row) {
    if (row.status == kChildStatusInProgress) {
      openGradeChild(row.childId);
    } else {
      openChildResult(row);
    }
  }

  void openChildResult(ChildAssessmentModel row) {
    Get.to(
      () => ManagerChildResultView(childId: row.childId),
      transition: Transition.cupertino,
    )?.then((_) => reload());
  }

  /// Let the manager grade (or edit) a child directly — reuses the same grading
  /// engine the teacher uses, bound to this run across all its classrooms.
  Future<void> openGradeChild(String childId) async {
    final r = run.value;
    if (r == null) return;
    final grading = Get.find<TeacherRunGradingController>();
    await grading.open(r, r.classroomIds);
    await Get.to(
      () => TeacherGradeChildView(childId: childId),
      transition: Transition.cupertino,
    );
    await reload();
  }

  ChildAssessmentModel? rowForChild(String childId) {
    for (final row in rows) {
      if (row.childId == childId) return row;
    }
    return null;
  }

  Future<void> _setStatus(
    ChildAssessmentModel row,
    String status, {
    bool silent = false,
    Map<String, dynamic>? audit,
  }) async {
    var updated = row.copyWith(status: status);
    if (audit != null) {
      updated = updated.copyWith(
        unlockedBy: audit['by'] as String?,
        unlockedAt: audit['at'] as int?,
        unlockReason: audit['reason'] as String?,
      );
    }
    await _childAssessments.update(
      item: updated,
      callBack: (_) {},
    );
  }

  /// Publish one completed child → parent-visible.
  Future<void> publishChild(ChildAssessmentModel row) async {
    Loader.show();
    await _setStatus(row, kChildStatusPublished);
    Loader.dismiss();
    Loader.showSuccess('assessment_published_one'.tr);
    await reload();
  }

  /// Publish every teacher-completed child at once.
  Future<void> publishAllCompleted() async {
    final toPublish = rows
        .where((r) => r.status == kChildStatusTeacherCompleted)
        .toList();
    if (toPublish.isEmpty) return;
    Loader.show();
    for (final row in toPublish) {
      await _setStatus(row, kChildStatusPublished, silent: true);
    }
    Loader.dismiss();
    Loader.showSuccess(
        'assessment_published_many'.trParams({'count': '${toPublish.length}'}));
    await reload();
  }

  /// Freeze a published child (no more edits without an unlock).
  Future<void> lockChild(ChildAssessmentModel row) async {
    Loader.show();
    await _setStatus(row, kChildStatusLocked);
    Loader.dismiss();
    Loader.showSuccess('assessment_locked_one'.tr);
    await reload();
  }

  /// Schedule a retake for a child. Attaches the plan (date / items / teacher /
  /// notify) to the child's official attempt — which is the LAST attempt so far,
  /// so [ChildAssessmentModel.hasPendingRetake] flips true and the teacher can
  /// re-grade the scoped items into a new attempt. A retake is a normal flow
  /// (not the audited correction), so no unlock is needed.
  Future<void> scheduleRetake(
    ChildAssessmentModel row, {
    required int date,
    required List<String> itemIds,
    String? teacherId,
    required bool notifyParent,
  }) async {
    if (row.attempts.isEmpty) return;
    final attempts = [...row.attempts];
    var idx = attempts.indexWhere((a) => a.attemptNo == row.officialAttemptNo);
    if (idx < 0) idx = attempts.length - 1;
    attempts[idx] = attempts[idx].copyWith(
      scheduledRetakeDate: date,
      scheduledRetakeTeacherId: teacherId,
      scheduledRetakeItemIds: itemIds,
      scheduledRetakeNotifyParent: notifyParent,
    );

    Loader.show();
    await _childAssessments.update(
      item: row.copyWith(attempts: attempts),
      callBack: (_) {},
    );
    Loader.dismiss();
    Loader.showSuccess('assessment_retake_saved'.tr);
    await reload();
  }

  /// Manager explicitly marks which attempt counts (never inferred).
  Future<void> setOfficialAttempt(
      ChildAssessmentModel row, int attemptNo) async {
    Loader.show();
    await _childAssessments.update(
      item: row.copyWith(officialAttemptNo: attemptNo),
      callBack: (_) {},
    );
    Loader.dismiss();
    Loader.showSuccess('assessment_official_set'.tr);
    await reload();
  }

  /// Unlock for a correction (the audited exception). Returns the child to
  /// teacher_completed so grades can be edited, recording who/when/why.
  Future<void> unlockChild(ChildAssessmentModel row, String reason) async {
    Loader.show();
    await _setStatus(
      row,
      kChildStatusTeacherCompleted,
      audit: {
        'by': uid,
        'at': DateTime.now().millisecondsSinceEpoch,
        'reason': reason.trim(),
      },
    );
    Loader.dismiss();
    Loader.showSuccess('assessment_unlocked_one'.tr);
    await reload();
  }
}
