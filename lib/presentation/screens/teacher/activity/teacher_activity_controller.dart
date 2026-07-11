import '../../../../index/index_main.dart';
import 'activity_child_states_mixin.dart';


enum EvalFilter { all, unevaluated, excellent, needsFollow, needsAttention }

class TeacherActivityController extends GetxController
    with ActivityChildStatesMixin {
  late final SessionService _session;
  late final TeacherActivityService _activityService;
  final _academicService = TeacherAcademicService();

  final activeActivity = Rxn<ClassroomActivityModel>();
  final children = <ChildModel>[].obs;
  // Children checked-in (present/late) today. When attendance hasn't been taken
  // for the classroom, this stays null and every child is treated as present.
  final presentChildIds = Rxn<Set<String>>();
  final subjects = <SubjectModel>[].obs;
  // classroomId → set of subjectIds assigned to that classroom (teacher matrix)
  final classroomSubjects = <String, Set<String>>{}.obs;
  final myClassrooms = <ClassroomModel>[].obs;
  // Display name of the teacher assigned to the active classroom ('' = hide).
  final currentTeacherName = ''.obs;
  final todayCompleted = <ClassroomActivityModel>[].obs;
  final todayScheduleSlots = <ScheduleModel>[].obs;
  final isLoading = true.obs;
  final isSaving = false.obs;
  final isUploadingPhoto = false.obs;
  final searchQuery = ''.obs;
  final evalFilter = EvalFilter.all.obs;
  final selectedClassroomId = ''.obs;

  final pendingHomework = Rxn<HomeworkModel>();
  final pendingSession = Rxn<SessionModel>();
  final pendingHomeworkStatuses = <String, HomeworkStatus>{}.obs;
  final isLoadingPendingHomework = false.obs;

  // Session created when the current activity was started
  final currentSessionId = Rxn<String>();

  StreamSubscription<ClassroomActivityModel?>? _activitySub;

  @override
  String get nurseryId => _session.nurseryId ?? '';
  @override
  String get teacherId => _session.userId ?? '';
  @override
  String get branchId => _session.branchId ?? '';
  @override
  List<ChildModel> get stateChildren => children;
  String get activeClassroomId => selectedClassroomId.value;
  String get _classroomId => selectedClassroomId.value;
  set _classroomId(String v) => selectedClassroomId.value = v;

  @override
  void onInit() {
    super.onInit();
    _session = Get.find<SessionService>();
    _activityService = Get.find<TeacherActivityService>();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    final uid = _session.userId;
    if (uid != null && nurseryId.isNotEmpty) {
      myClassrooms.value =
          await _activityService.resolveClassrooms(nurseryId, uid);
      _classroomId =
          myClassrooms.isNotEmpty ? (myClassrooms.first.key ?? '') : '';
      if (_classroomId.isNotEmpty) {
        await Future.wait([
          _loadChildren(),
          _loadSubjects(),
          _loadAssignment(),
          _loadTodayCompleted(),
          loadStateTemplates(),
          _loadTeacherName(),
        ]);
        await _loadTodaySchedule();
        _watchActivity();
      }
    }
    isLoading.value = false;
  }

  void setActiveClassroom(String classroomId) {
    if (_classroomId == classroomId) return;
    _classroomId = classroomId;
    _activitySub?.cancel();
    _watchActivity();
    _loadChildren();
    _loadTeacherName();
    _reloadTodayData();
  }

  /// Resolves the active classroom's assigned teacher name for the header.
  Future<void> _loadTeacherName() async {
    final cls = myClassrooms.firstWhereOrNull((c) => c.key == _classroomId);
    currentTeacherName.value = await _activityService.resolveStaffName(
      nurseryId,
      cls?.teacherId ?? '',
    );
  }

  void _watchActivity() {
    _activitySub?.cancel();
    _activitySub =
        _activityService.watchActiveActivity(nurseryId, _classroomId).listen(
      (a) {
        activeActivity.value = a;
      },
    );
  }

  // ── Computed ──────────────────────────────────────────────────────────────

  List<ChildModel> get filteredChildren {
    var list = presentChildren;
    final q = searchQuery.value.trim();
    if (q.isNotEmpty) {
      list = list
          .where((c) =>
              c.fullName.contains(q) ||
              c.firstName.contains(q) ||
              c.lastName.contains(q))
          .toList();
    }
    final filter = evalFilter.value;
    final activity = activeActivity.value;
    if (filter != EvalFilter.all && activity != null) {
      list = list.where((c) {
        final eval = activity.evalFor(c.key ?? '');
        return switch (filter) {
          EvalFilter.unevaluated => eval == null,
          EvalFilter.excellent => eval == EvalLevel.excellent,
          EvalFilter.needsFollow => eval == EvalLevel.needsFollow,
          EvalFilter.needsAttention => eval == EvalLevel.needsAttention,
          EvalFilter.all => true,
        };
      }).toList();
    }
    return list;
  }

  int get evaluatedCount => activeActivity.value?.evaluations.length ?? 0;
  int get unevaluatedCount =>
      (children.length - evaluatedCount).clamp(0, children.length);
  double get evalProgress => children.isEmpty
      ? 0.0
      : (evaluatedCount / children.length).clamp(0.0, 1.0);

  // ── Data loading ──────────────────────────────────────────────────────────

  Future<void> _loadChildren() async {
    children.value =
        await _activityService.loadChildren(nurseryId, _classroomId);
    await _loadPresentToday();
    watchChildStates();
  }

  /// Recomputes the present set from live statuses — call when opening the
  /// evaluation sheet so attendance changes since load are reflected.
  Future<void> refreshPresentChildren() => _loadPresentToday();

  Future<void> _loadPresentToday() async {
    if (_classroomId.isEmpty) {
      presentChildIds.value = null;
      return;
    }
    final ids = children
        .map((c) => c.key ?? '')
        .where((id) => id.isNotEmpty)
        .toList();
    presentChildIds.value =
        await _activityService.loadPresentChildIds(nurseryId, ids);
  }

  /// Children to evaluate: only those present today when attendance was taken,
  /// otherwise every child in the classroom.
  List<ChildModel> get presentChildren {
    final ids = presentChildIds.value;
    if (ids == null) return children.toList();
    return children.where((c) => ids.contains(c.key)).toList();
  }

  Future<void> _loadSubjects() async {
    subjects.value = await _activityService.loadSubjects(nurseryId);
  }

  Future<void> _loadAssignment() async {
    final a = await _academicService.loadAssignment();
    if (a == null) return;
    final m = <String, Set<String>>{};
    for (final e in a.assignments) {
      (m[e.classroomId] ??= <String>{}).add(e.subjectId);
    }
    classroomSubjects.value = m;
  }

  bool get hasAssignment => classroomSubjects.isNotEmpty;

  /// Subjects the teacher is assigned to teach in [classroomId].
  /// Falls back to all nursery subjects when the teacher has no assignment yet.
  List<SubjectModel> subjectsForClassroom(String? classroomId) {
    if (classroomId == null || classroomId.isEmpty || !hasAssignment) {
      return subjects.toList();
    }
    final allowed = classroomSubjects[classroomId] ?? const <String>{};
    return subjects.where((s) => allowed.contains(s.key)).toList();
  }

  Future<void> _loadTodayCompleted() async {
    todayCompleted.value =
        await _activityService.getTodayCompleted(nurseryId, _classroomId);
  }

  Future<void> _reloadTodayData() async {
    await _loadTodayCompleted();
    await _loadTodaySchedule();
  }

  Future<void> _loadTodaySchedule() async {
    if (_classroomId.isEmpty) return;
    final slots = await _activityService.getTodayScheduleForClassroom(
      nurseryId: nurseryId,
      classroomId: _classroomId,
    );
    final completedSubjectIds = todayCompleted
        .where((a) => a.subjectId != null && a.subjectId!.isNotEmpty)
        .map((a) => a.subjectId!)
        .toSet();
    final completedTitles = todayCompleted
        .where((a) => a.subjectId == null || a.subjectId!.isEmpty)
        .map((a) => a.title.toLowerCase())
        .toSet();
    todayScheduleSlots.value = slots.where((s) {
      if (s.subjectId != null && s.subjectId!.isNotEmpty) {
        return !completedSubjectIds.contains(s.subjectId);
      }
      return !completedTitles.contains(scheduleTitle(s).toLowerCase());
    }).toList();
  }

  String scheduleTitle(ScheduleModel s) {
    if (s.subjectId != null) {
      final sub = _subjectById(s.subjectId);
      if (sub != null) return sub.name;
    }
    const labels = {
      'lesson': 'حصة دراسية',
      'break': 'استراحة',
      'outdoor': 'وقت خارجي',
      'lunch': 'وجبة الغداء',
      'nap': 'قيلولة',
      'other': 'نشاط',
    };
    return s.note ?? labels[s.activityType] ?? s.activityType;
  }

  SubjectModel? _subjectById(String? id) {
    if (id == null) return null;
    for (final s in subjects) {
      if (s.key == id) return s;
    }
    return null;
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> startActivity({
    required String title,
    String? subjectId,
    String? subjectName,
    String? classroomId,
  }) async {
    final cId = classroomId ?? _classroomId;
    if (cId.isEmpty) return;
    if (cId != _classroomId) {
      _classroomId = cId;
      _activitySub?.cancel();
      _watchActivity();
      await _loadChildren();
    }
    // A child's day track starts only when they've arrived (checked-in), so the
    // activity is fanned out to the present children only — a not-yet-arrived
    // child must not get it on their track. Falls back to every child when
    // attendance isn't tracked (presentChildIds == null via presentChildren).
    await refreshPresentChildren();
    final ids = presentChildren
        .map((c) => c.key ?? '')
        .where((id) => id.isNotEmpty)
        .toList();
    isSaving.value = true;
    final result = await _activityService.startActivity(
      nurseryId: nurseryId,
      branchId: _session.branchId ?? '',
      classroomId: cId,
      teacherId: teacherId,
      title: title,
      childIds: ids,
      subjectId: subjectId,
      subjectName: subjectName,
    );
    currentSessionId.value = result.sessionId;
    isSaving.value = false;
  }

  Future<void> endCurrentActivity() async {
    final a = activeActivity.value;
    if (a?.key == null) return;
    isSaving.value = true;
    await _activityService.endActivity(
      nurseryId: nurseryId,
      branchId: _session.branchId ?? '',
      classroomId: _classroomId,
      activityId: a!.key!,
      activity: a,
    );
    await _reloadTodayData();
    isSaving.value = false;
  }

  Future<void> endWithData({
    required Map<String, String> finalEvals,
    required Map<String, String> finalNotes,
    Map<String, List<String>> finalReasons = const {},
    String? groupNote,
    HomeworkModel? homework,
  }) async {
    final a = activeActivity.value;
    if (a?.key == null) return;
    isSaving.value = true;
    await _activityService.endActivityWithData(
      nurseryId: nurseryId,
      branchId: _session.branchId ?? '',
      classroomId: _classroomId,
      activityId: a!.key!,
      activity: a,
      finalEvals: finalEvals,
      finalNotes: finalNotes,
      finalReasons: finalReasons,
      groupNote: groupNote,
      homework: homework,
      sessionId: currentSessionId.value,
    );
    currentSessionId.value = null;
    await _reloadTodayData();
    isSaving.value = false;
  }

  Future<void> startFromSchedule(ScheduleModel s) async {
    final title = scheduleTitle(s);
    final subName = _subjectById(s.subjectId)?.name;
    await startActivity(
        title: title, subjectId: s.subjectId, subjectName: subName);
    todayScheduleSlots.removeWhere((slot) => slot.key == s.key);
  }

  Future<void> setAllEval(EvalLevel level) async {
    final a = activeActivity.value;
    if (a?.key == null || children.isEmpty) return;
    isSaving.value = true;
    final ids = children
        .map((c) => c.key ?? '')
        .where((id) => id.isNotEmpty)
        .toList();
    await _activityService.bulkEvaluation(
      nurseryId: nurseryId,
      classroomId: _classroomId,
      activityId: a!.key!,
      childIds: ids,
      level: level,
    );
    isSaving.value = false;
  }

  Future<void> toggleEval(String childId, EvalLevel level) async {
    final a = activeActivity.value;
    if (a?.key == null) return;
    final current = a!.evalFor(childId);
    if (current == level) {
      await _activityService.removeEvaluation(
        nurseryId: nurseryId,
        classroomId: _classroomId,
        activityId: a.key!,
        childId: childId,
      );
    } else {
      await _activityService.updateEvaluation(
        nurseryId: nurseryId,
        classroomId: _classroomId,
        activityId: a.key!,
        childId: childId,
        level: level,
      );
    }
  }

  Future<void> saveNote(String childId, String note) async {
    final a = activeActivity.value;
    if (a?.key == null) return;
    await _activityService.saveNote(
      nurseryId: nurseryId,
      classroomId: _classroomId,
      activityId: a!.key!,
      childId: childId,
      note: note,
      teacherId: teacherId,
    );
  }

  Future<void> uploadActivityPhoto() async {
    final a = activeActivity.value;
    final activityKey = a?.key;
    if (activityKey == null) return;
    await PickedImage().pickMultiImages(callBack: (files) async {
      if (files.isEmpty) return;
      isUploadingPhoto.value = true;
      for (final file in files) {
        final result = await _activityService.uploadActivityPhoto(
          nurseryId: nurseryId,
          classroomId: _classroomId,
          activityId: activityKey,
          file: file,
        );
        if (result != null) {
          final (photoId, url) = result;
          final current = activeActivity.value;
          if (current != null) {
            activeActivity.value = current.copyWith(
              photos: Map<String, String>.from(current.photos)
                ..[photoId] = url,
            );
          }
        } else {
          Loader.showError('teacher_activity_photo_error'.tr);
        }
      }
      isUploadingPhoto.value = false;
    });
  }

  Future<void> removeActivityPhoto(String photoId) async {
    final a = activeActivity.value;
    if (a?.key == null) return;
    final current = activeActivity.value;
    if (current != null) {
      activeActivity.value = current.copyWith(
        photos: Map<String, String>.from(current.photos)..remove(photoId),
      );
    }
    await _activityService.deleteActivityPhoto(
      nurseryId: nurseryId,
      classroomId: _classroomId,
      activityId: a!.key!,
      photoId: photoId,
    );
  }

  Future<void> saveGroupNote(String note) async {
    final a = activeActivity.value;
    if (a?.key == null) return;
    await _activityService.saveGroupNote(
      nurseryId: nurseryId,
      classroomId: _classroomId,
      activityId: a!.key!,
      note: note,
    );
  }

  Future<void> postQuickHomework({
    required String title,
    String? description,
  }) async {
    Loader.show();
    final ok = await _activityService.postQuickHomework(
      nurseryId: nurseryId,
      classroomId: _classroomId,
      teacherId: teacherId,
      title: title,
      description: description,
    );
    if (ok) {
      Loader.showSuccess('teacher_homework_post_success'.tr);
    } else {
      Loader.showError('teacher_homework_post_error'.tr);
    }
  }

  // ── Homework follow-up ────────────────────────────────────────────────────

  Future<void> loadPendingHomeworkForSubject(String? subjectId) async {
    pendingHomework.value = null;
    pendingSession.value = null;
    pendingHomeworkStatuses.clear();
    if (subjectId == null || subjectId.isEmpty || _classroomId.isEmpty) return;
    isLoadingPendingHomework.value = true;
    try {
      // Find last completed session that has homework for this subject+classroom
      final session = await _activityService.getLastCompletedSession(
        nurseryId: nurseryId,
        classroomId: _classroomId,
        subjectId: subjectId,
      );
      pendingSession.value = session;
      if (session?.homeworkId != null) {
        final hw = await _activityService.getHomeworkById(
          nurseryId: nurseryId,
          homeworkId: session!.homeworkId!,
        );
        pendingHomework.value = hw;
        if (hw?.key != null) {
          final statuses = await _activityService.getHomeworkStatuses(
            nurseryId: nurseryId,
            homeworkId: hw!.key!,
          );
          pendingHomeworkStatuses.value = statuses;
        }
      }
    } finally {
      isLoadingPendingHomework.value = false;
    }
  }

  void setHomeworkStatus(String childId, HomeworkStatus status) {
    if (pendingHomeworkStatuses[childId] == status) {
      pendingHomeworkStatuses.remove(childId);
    } else {
      pendingHomeworkStatuses[childId] = status;
    }
  }

  void setAllHomeworkStatus(HomeworkStatus status) {
    for (final c in children) {
      final id = c.key ?? '';
      if (id.isNotEmpty) pendingHomeworkStatuses[id] = status;
    }
  }

  Future<void> savePendingHomeworkStatuses() async {
    final hw = pendingHomework.value;
    if (hw?.key == null) return;
    await _activityService.saveAllHomeworkStatuses(
      nurseryId: nurseryId,
      homeworkId: hw!.key!,
      classroomId: _classroomId,
      statuses: Map.from(pendingHomeworkStatuses),
      teacherId: teacherId,
    );
  }

  int get hwCompletedCount => pendingHomeworkStatuses.values
      .where((s) => s == HomeworkStatus.completed)
      .length;
  int get hwPartialCount => pendingHomeworkStatuses.values
      .where((s) => s == HomeworkStatus.partiallyCompleted)
      .length;
  int get hwNotCompletedCount => pendingHomeworkStatuses.values
      .where((s) => s == HomeworkStatus.notCompleted)
      .length;
  int get hwAbsentCount => pendingHomeworkStatuses.values
      .where((s) => s == HomeworkStatus.absent)
      .length;
  bool get hwReviewed => pendingHomeworkStatuses.isNotEmpty;

  // ── Refresh ───────────────────────────────────────────────────────────────

  Future<void> refresh() async {
    await Future.wait([_loadTodayCompleted(), _loadChildren()]);
    await _loadTodaySchedule();
  }

  @override
  void onClose() {
    _activitySub?.cancel();
    disposeChildStates();
    super.onClose();
  }
}
