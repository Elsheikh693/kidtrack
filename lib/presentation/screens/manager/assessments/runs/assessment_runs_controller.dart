import '../../../../../index/index_main.dart';

/// Manager hub for assessment RUNS (executions of a template on a branch's
/// classes). Lists the branch's runs, creates a draft from a template, then
/// PUBLISHES it — which snapshots nothing new (the run already holds the
/// template snapshot) but flips it to active and materialises one
/// ChildAssessment row per active child in the selected classrooms.
class AssessmentRunsController extends GetxController {
  late final AssessmentRunParentService _runs;
  late final AssessmentTemplateParentService _templates;
  late final ChildAssessmentParentService _childAssessments;
  late final ChildParentService _children;
  late final ClassroomParentService _classrooms;
  late final StaffParentService _staff;
  final _session = SessionService();

  final RxList<AssessmentRunModel> items = <AssessmentRunModel>[].obs;
  final RxList<AssessmentTemplateModel> templates =
      <AssessmentTemplateModel>[].obs;
  final RxList<ClassroomModel> classrooms = <ClassroomModel>[].obs;
  final RxList<StaffModel> teachers = <StaffModel>[].obs;
  final RxBool isLoading = true.obs;

  String get branchId => _session.branchId ?? '';
  String get nurseryId => _session.nurseryId ?? '';
  String get currentUid => _session.currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    _runs = Get.find<AssessmentRunParentService>();
    _templates = Get.find<AssessmentTemplateParentService>();
    _childAssessments = Get.find<ChildAssessmentParentService>();
    _children = Get.find<ChildParentService>();
    _classrooms = Get.find<ClassroomParentService>();
    _staff = Get.find<StaffParentService>();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await Future.wait([
      _loadRuns(),
      _loadTemplates(),
      _loadClassrooms(),
      _loadTeachers(),
    ]);
    isLoading.value = false;
  }

  Future<void> _loadRuns() async {
    await _runs.getAll(callBack: (list) {
      items.value = list.whereType<AssessmentRunModel>().toList()
        ..sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
    });
  }

  Future<void> _loadTemplates() async {
    await _templates.getAll(callBack: (list) {
      templates.value = list
          .whereType<AssessmentTemplateModel>()
          .where((t) => t.isActive)
          .toList()
        ..sort((a, b) => a.title.compareTo(b.title));
    });
  }

  Future<void> _loadClassrooms() async {
    await _classrooms.getAll(callBack: (list) {
      classrooms.value = list
          .whereType<ClassroomModel>()
          .where((c) => c.isActive)
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    });
  }

  Future<void> _loadTeachers() async {
    await _staff.getAll(callBack: (list) {
      teachers.value = list
          .whereType<StaffModel>()
          .where((s) => s.role.isClassroomRole)
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    });
  }

  /// Open the create form for a chosen template.
  void openCreate(AssessmentTemplateModel template) {
    Get.to(
      () => AssessmentRunCreateView(template: template),
      transition: Transition.cupertino,
    )?.then((_) => _loadRuns());
  }

  /// Persist a new draft run (built by the create form).
  Future<void> createDraft(AssessmentRunModel run) async {
    Loader.show();
    await _runs.add(
      item: run,
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('assessment_run_created'.tr);
          Get.back();
        } else {
          Loader.showError('assessment_run_error'.tr);
        }
      },
    );
  }

  /// Flip a draft run to active and create the per-child rows. Idempotent: rows
  /// are keyed `{runId}_{childId}`, so re-publishing never duplicates a child.
  Future<void> publish(AssessmentRunModel run) async {
    final runId = run.key;
    if (runId == null || runId.isEmpty) return;

    Loader.show();

    // Collect active children in the run's classrooms.
    final targets = <ChildModel>[];
    await _children.getAll(callBack: (list) {
      for (final c in list.whereType<ChildModel>()) {
        if (c.status == 'active' &&
            c.classroomId != null &&
            run.classroomIds.contains(c.classroomId)) {
          targets.add(c);
        }
      }
    });

    // Materialise a row per child (silent — one Loader wraps the whole batch).
    for (final child in targets) {
      final row = ChildAssessmentModel(
        key: '${runId}_${child.key}',
        nurseryId: nurseryId,
        runId: runId,
        childId: child.key ?? '',
        branchId: run.branchId,
        classroomId: child.classroomId,
        status: kChildStatusInProgress,
      );
      await _childAssessments.add(item: row, callBack: (_) {}, silent: true);
    }

    // Activate the run.
    await _runs.update(
      item: run.copyWith(status: kRunStatusActive),
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess(
            'assessment_run_published'.trParams({'count': '${targets.length}'}),
          );
          _loadRuns();
        } else {
          Loader.showError('assessment_run_error'.tr);
        }
      },
    );
  }

  Future<void> deleteRun(AssessmentRunModel run) async {
    Loader.show();
    await _runs.delete(
      id: run.key ?? '',
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('assessment_run_deleted'.tr);
          _loadRuns();
        } else {
          Loader.showError('assessment_run_error'.tr);
        }
      },
    );
  }

  /// Open a published run for review (manager sees every child + publish/lock).
  void openRun(AssessmentRunModel run) {
    Get.find<ManagerRunDetailController>().open(run);
    Get.to(
      () => const ManagerRunDetailView(),
      transition: Transition.cupertino,
    )?.then((_) => _loadRuns());
  }

  void openTemplates() => Get.toNamed(assessmentTemplatesView);

  String classroomName(String id) {
    for (final c in classrooms) {
      if (c.key == id) return c.name;
    }
    return '';
  }
}
