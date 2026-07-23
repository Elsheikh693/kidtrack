import '../../../../index/index_main.dart';

/// Parent's list of their active child's PUBLISHED assessment results. Pairs
/// each visible child row with its run snapshot (title/scale/items) so the
/// report can render. Reacts to the active-child switcher.
class ParentAssessmentsController extends GetxController {
  late final ChildAssessmentParentService _childAssessments;
  late final AssessmentRunParentService _runs;
  late final NurseryParentService _nurserySvc;
  late final ActiveChildService _active;

  final RxList<ChildAssessmentModel> rows = <ChildAssessmentModel>[].obs;
  final RxMap<String, AssessmentRunModel> runsById =
      <String, AssessmentRunModel>{}.obs;
  final RxBool isLoading = true.obs;

  // Nursery branding, for the shareable report image.
  String nurseryName = '';
  String? nurseryLogo;

  Worker? _childWorker;

  @override
  void onInit() {
    super.onInit();
    _childAssessments = Get.find<ChildAssessmentParentService>();
    _runs = Get.find<AssessmentRunParentService>();
    _nurserySvc = Get.find<NurseryParentService>();
    _active = Get.find<ActiveChildService>();
    loadData();
    _childWorker = ever(_active.childId, (_) => loadData());
  }

  String get childName => _active.childName.value;

  @override
  void onClose() {
    _childWorker?.dispose();
    super.onClose();
  }

  String get _childId => _active.childId.value;

  Future<void> loadData() async {
    isLoading.value = true;

    await _runs.getAll(callBack: (list) {
      final map = <String, AssessmentRunModel>{};
      for (final r in list.whereType<AssessmentRunModel>()) {
        if (r.key != null) map[r.key!] = r;
      }
      runsById.value = map;
    });

    await _loadNursery();

    await _childAssessments.getAll(callBack: (list) {
      final id = _childId;
      final visible = list
          .whereType<ChildAssessmentModel>()
          .where((row) =>
              row.childId == id &&
              row.isVisibleToParent &&
              (runsById[row.runId]?.visibleToParentAfterPublish ?? true))
          .toList();
      // Newest first by the run's start date (fallback to row updatedAt).
      visible.sort((a, b) {
        final da = runsById[a.runId]?.startDate ?? a.updatedAt ?? 0;
        final db = runsById[b.runId]?.startDate ?? b.updatedAt ?? 0;
        return db.compareTo(da);
      });
      rows.value = visible;
    });

    // Opening the list clears the home "new assessments" badge.
    await ParentDashboardController.markAssessmentsSeen(_childId);

    isLoading.value = false;
  }

  Future<void> _loadNursery() async {
    final id = SessionService().nurseryId ?? '';
    await _nurserySvc.getAll(callBack: (list) {
      final nurseries = list.whereType<NurseryModel>();
      if (nurseries.isEmpty) return;
      final n = nurseries.firstWhere(
        (item) => item.key == id,
        orElse: () => nurseries.first,
      );
      nurseryName = n.name;
      nurseryLogo = n.logo;
    });
  }

  AssessmentRunModel? runFor(String runId) => runsById[runId];

  void openResult(ChildAssessmentModel row) {
    final run = runFor(row.runId);
    if (run == null) return;
    Get.to(
      () => ParentAssessmentResultView(
        row: row,
        run: run,
        childName: childName,
        nurseryName: nurseryName,
        nurseryLogo: nurseryLogo,
      ),
      transition: Transition.cupertino,
    );
  }
}
