import '../../../../index/index_main.dart';
import '../../../../Data/models/child/child_model.dart';
import '../../../../Data/models/homework/homework_model.dart';
import '../../../../Data/models/subject/subject_model.dart';
import 'teacher_activity_controller.dart';

class ActivityEndController extends GetxController {
  late final TeacherActivityController _mainCtrl;

  final groupNoteCtrl = TextEditingController();
  final hwTitleCtrl = TextEditingController();
  final hwDescCtrl = TextEditingController();

  final childEvals = <String, String>{}.obs;
  final childNotes = <String, String>{}.obs;
  final childReasons = <String, List<String>>{}.obs;
  // Holds the selected default level's KEY (dynamic eval levels).
  final defaultEval = RxnString();
  final showHomework = true.obs;

  final reasons = <EvaluationReasonModel>[].obs;
  final isLoadingReasons = true.obs;
  late final EvaluationReasonsService _reasonsService;
  late final TeacherActivityService _activityService;
  late final EvalLevelsRegistry _levelsRegistry;

  /// The nursery's active evaluation levels (dynamic, highest-score first).
  List<EvalLevelTemplateModel> get levels => _levelsRegistry.levels;
  final selectedSubjectId = RxnString();
  final selectedSubjectName = RxnString();
  final dueDate = Rxn<DateTime>();

  /// Nursery school days; defaults to "every day except Friday" until loaded.
  List<int> _workingDays = const [1, 2, 3, 4, 6, 7];

  @override
  void onInit() {
    super.onInit();
    _mainCtrl = Get.find<TeacherActivityController>();
    _reasonsService = Get.find<EvaluationReasonsService>();
    _activityService = Get.find<TeacherActivityService>();
    _levelsRegistry = Get.find<EvalLevelsRegistry>();
    _levelsRegistry.ensureLoaded();
    ever(_mainCtrl.activeActivity, (_) => initFromActivity());
    // Default the homework date to the next school day when homework is enabled.
    ever(showHomework, (on) {
      if (on == true && dueDate.value == null) {
        dueDate.value = nextSchoolDay(_workingDays);
      }
    });
    initFromActivity();
    _loadReasons();
    _loadWorkingDays();
  }

  Future<void> _loadWorkingDays() async {
    _workingDays =
        await _activityService.getNurseryWorkingDays(_mainCtrl.nurseryId);
  }

  void initFromActivity() {
    final activity = _mainCtrl.activeActivity.value;
    if (activity == null) return;
    childEvals.value = Map<String, String>.from(activity.evaluations);
    childNotes.value = Map<String, String>.from(activity.notes);
    groupNoteCtrl.text = activity.groupNote ?? '';
    selectedSubjectId.value = activity.subjectId;
    selectedSubjectName.value = activity.subjectName;
    childReasons.clear();
    defaultEval.value = null;
    showHomework.value = true;
    // Homework is enabled by default, so seed the due date up front (the
    // showHomework listener won't fire when the value is unchanged).
    dueDate.value = nextSchoolDay(_workingDays);
    hwTitleCtrl.clear();
    hwDescCtrl.clear();
  }

  List<ChildModel> get children => _mainCtrl.presentChildren;
  List<SubjectModel> get subjects =>
      _mainCtrl.subjectsForClassroom(_mainCtrl.activeClassroomId);

  int get totalCount => children.length;
  int get evaluatedCount {
    final ids = children.map((c) => c.key).toSet();
    return childEvals.keys.where(ids.contains).length;
  }

  String get classroomName {
    final id = _mainCtrl.selectedClassroomId.value;
    for (final c in _mainCtrl.myClassrooms) {
      if (c.key == id) return c.name;
    }
    return '';
  }

  void setDefaultEval(String levelKey) {
    defaultEval.value = levelKey;
    bulkSetAll(levelKey);
  }

  void setChildEval(String childId, String levelKey) {
    childEvals[childId] = levelKey;
    childEvals.refresh();
  }

  int summaryCount(String levelKey) {
    final ids = children.map((c) => c.key).toSet();
    return childEvals.entries
        .where((e) => ids.contains(e.key) && e.value == levelKey)
        .length;
  }

  // ── Reasons ──────────────────────────────────────────────────────────────

  Future<void> _loadReasons() async {
    isLoadingReasons.value = true;
    reasons.value = await _reasonsService.getAll(_mainCtrl.nurseryId);
    isLoadingReasons.value = false;
  }

  Future<void> refreshReasons() => _loadReasons();

  List<String> getChildReasons(String childId) =>
      List.unmodifiable(childReasons[childId] ?? []);

  int reasonCount(String childId) => (childReasons[childId] ?? []).length;

  void toggleReason(String childId, String title) {
    final current = List<String>.from(childReasons[childId] ?? []);
    if (current.contains(title)) {
      current.remove(title);
    } else {
      current.add(title);
    }
    childReasons[childId] = current;
    childReasons.refresh();
  }

  Future<void> addNewReason(String childId, String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    await _reasonsService.addOrGet(_mainCtrl.nurseryId, trimmed);
    await _loadReasons();
    final current = List<String>.from(childReasons[childId] ?? []);
    if (!current.contains(trimmed)) {
      current.add(trimmed);
      childReasons[childId] = current;
      childReasons.refresh();
    }
  }

  void bulkSetAll(String evalKey) {
    for (final c in children) {
      if (c.key != null) childEvals[c.key!] = evalKey;
    }
    childEvals.refresh();
  }

  void toggleChildEval(String childId, String evalKey) {
    if (childEvals[childId] == evalKey) {
      childEvals.remove(childId);
    } else {
      childEvals[childId] = evalKey;
    }
    childEvals.refresh();
  }

  void setChildNote(String childId, String note) {
    if (note.trim().isEmpty) {
      childNotes.remove(childId);
    } else {
      childNotes[childId] = note.trim();
    }
    childNotes.refresh();
  }

  void selectSubject(String? id, String? name) {
    selectedSubjectId.value = id;
    selectedSubjectName.value = name;
  }

  HomeworkModel? buildHomework() {
    if (!showHomework.value) return null;
    final title = hwTitleCtrl.text.trim();
    if (title.isEmpty) return null;
    final activity = _mainCtrl.activeActivity.value;
    return HomeworkModel(
      nurseryId: activity?.nurseryId ?? '',
      classroomId: activity?.classroomId ?? '',
      subjectId: selectedSubjectId.value,
      subjectName: selectedSubjectName.value,
      activityId: activity?.key,
      title: title,
      description:
          hwDescCtrl.text.trim().isEmpty ? null : hwDescCtrl.text.trim(),
      dueDate: dueDate.value?.millisecondsSinceEpoch,
      createdBy: activity?.teacherId ?? '',
    );
  }

  @override
  void onClose() {
    groupNoteCtrl.dispose();
    hwTitleCtrl.dispose();
    hwDescCtrl.dispose();
    super.onClose();
  }
}
