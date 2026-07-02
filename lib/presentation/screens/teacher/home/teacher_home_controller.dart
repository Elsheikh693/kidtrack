import 'package:firebase_database/firebase_database.dart';
import '../../../../index/index_main.dart';
import '../../../../Data/models/child_current_status/child_current_status_model.dart';
import 'child_attention_entry.dart';
import 'child_preview.dart';
import 'top_performer_entry.dart';
import 'classroom_states_controller.dart';

class TeacherHomeController extends GetxController {
  late final SessionService _session;
  late final TeacherActivityService _activityService;
  late final ChildStateService _childStateService;
  final TeacherAcademicService _academicService = TeacherAcademicService();

  final RxBool isLoading = true.obs;
  final Rx<ClassroomActivityModel?> activeActivity =
      Rx<ClassroomActivityModel?>(null);

  final RxList<ClassroomModel> myClassrooms = <ClassroomModel>[].obs;
  final RxList<SubjectModel> mySubjects = <SubjectModel>[].obs;
  final RxMap<String, int> classroomChildCount = <String, int>{}.obs;

  /// classroomId → a few children (name + image) for the avatar stack.
  final RxMap<String, List<ChildPreview>> classroomChildPreviews =
      <String, List<ChildPreview>>{}.obs;

  /// Teacher → (classroom, subject) assignments. Drives the per-class subject chips.
  final Rx<TeacherAssignmentModel?> assignment = Rx<TeacherAssignmentModel?>(null);
  final Map<String, SubjectModel> _subjectById = {};

  final Map<String, List<String>> _classroomChildIds = {};
  final Map<String, String> _childNames = {};

  final RxList<ChildAttentionEntry> attentionChildren =
      <ChildAttentionEntry>[].obs;
  final RxMap<String, int> classroomAttentionCount = <String, int>{}.obs;

  final RxInt totalChildren = 0.obs;
  final RxInt presentToday = 0.obs;
  final RxInt todayActivitiesDone = 0.obs;
  final RxInt studentsEvaluatedToday = 0.obs;
  final RxDouble averagePerformance = 0.0.obs;

  final RxList<ClassroomActivityModel> todayActivities =
      <ClassroomActivityModel>[].obs;
  final RxInt todayActivitiesTotal = 0.obs;

  final RxList<TopPerformerEntry> topPerformers =
      <TopPerformerEntry>[].obs;

  final RxMap<String, int> classroomActivitiesCount = <String, int>{}.obs;
  final RxMap<String, double> classroomAvgRating = <String, double>{}.obs;

  StreamSubscription<ClassroomActivityModel?>? _activitySub;
  StreamSubscription<Map<String, ChildCurrentStatusModel?>>? _statesSub;

  String get teacherName => _session.currentUser?.displayName ?? '';
  String get nurseryId => _session.nurseryId ?? '';
  String get teacherId => _session.userId ?? '';

  String get primaryClassroomName =>
      myClassrooms.isNotEmpty ? myClassrooms.first.name : '';

  @override
  void onInit() {
    super.onInit();
    _session = Get.find<SessionService>();
    _activityService = Get.find<TeacherActivityService>();
    _childStateService = Get.find<ChildStateService>();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    await Future.wait([_loadMyClassrooms(), _loadMySubjects(), _loadAssignment()]);
    if (myClassrooms.isNotEmpty) {
      _watchActivity();
      await Future.wait([
        _loadChildrenCount(),
        _loadPresentCount(),
        _loadTodaySummary(),
      ]);
    }
    isLoading.value = false;
  }

  Future<void> _loadMyClassrooms() async {
    final uid = _session.userId;
    if (uid == null || nurseryId.isEmpty) return;

    final classrooms = <ClassroomModel>[];
    final loadedIds = <String>{};

    try {
      final staffSnap = await FirebaseDatabase.instance
          .ref('platform/$nurseryId/staff/$uid')
          .get();
      if (staffSnap.exists && staffSnap.value is Map) {
        final d = Map<String, dynamic>.from(staffSnap.value as Map);
        final idsToLoad = <String>{};
        final single = d['classroomId']?.toString() ?? '';
        if (single.isNotEmpty) idsToLoad.add(single);
        final multi = d['classroomIds'];
        if (multi is List) {
          for (final v in multi) {
            if (v != null) idsToLoad.add(v.toString());
          }
        } else if (multi is Map) {
          for (final v in multi.values) {
            if (v != null) idsToLoad.add(v.toString());
          }
        }
        for (final cId in idsToLoad) {
          try {
            final cSnap = await FirebaseDatabase.instance
                .ref('platform/$nurseryId/classrooms/$cId')
                .get();
            if (cSnap.exists && cSnap.value is Map) {
              classrooms.add(ClassroomModel.fromJson(
                Map<String, dynamic>.from(cSnap.value as Map),
                key: cId,
              ));
              loadedIds.add(cId);
            }
          } catch (_) {}
        }
      }
    } catch (_) {}

    try {
      final snap = await FirebaseDatabase.instance
          .ref('platform/$nurseryId/classrooms')
          .orderByChild('teacherId')
          .equalTo(uid)
          .get();
      if (snap.exists && snap.value is Map) {
        for (final e in (snap.value as Map).entries) {
          final key = e.key.toString();
          if (e.value is Map && !loadedIds.contains(key)) {
            final c = ClassroomModel.fromJson(
              Map<String, dynamic>.from(e.value as Map),
              key: key,
            );
            classrooms.add(c);
            loadedIds.add(key);
          }
        }
      }
    } catch (_) {}

    myClassrooms.value = classrooms..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> _loadMySubjects() async {
    try {
      final uid = _session.userId;
      if (uid == null || nurseryId.isEmpty) return;

      final staffSnap = await FirebaseDatabase.instance
          .ref('platform/$nurseryId/staff/$uid/subjectIds')
          .get();

      List<String> ids = [];
      if (staffSnap.exists) {
        final val = staffSnap.value;
        if (val is List) {
          ids = val.map((e) => e.toString()).toList();
        } else if (val is Map) {
          ids = val.values.map((e) => e.toString()).toList();
        }
      }
      if (ids.isEmpty) {
        mySubjects.value = [];
        return;
      }

      final subSnap = await FirebaseDatabase.instance
          .ref('platform/$nurseryId/subjects')
          .get();
      if (!subSnap.exists || subSnap.value == null) return;
      final data = subSnap.value as Map? ?? {};
      _subjectById.clear();
      for (final e in data.entries) {
        if (e.value is! Map) continue;
        final subject = SubjectModel.fromJson(
          Map<String, dynamic>.from(e.value as Map),
          key: e.key.toString(),
        );
        _subjectById[subject.key ?? e.key.toString()] = subject;
      }
      mySubjects.value = _subjectById.values
          .where((s) => ids.contains(s.key))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } catch (_) {}
  }

  Future<void> _loadAssignment() async {
    try {
      assignment.value = await _academicService.loadAssignment();
    } catch (_) {}
  }

  /// Subjects this teacher teaches in [classroomId], resolved to full models.
  List<SubjectModel> subjectsForClassroom(String classroomId) {
    final asgn = assignment.value;
    if (asgn == null) return const [];
    return asgn
        .subjectsForClassroom(classroomId)
        .toSet()
        .map((id) => _subjectById[id])
        .whereType<SubjectModel>()
        .toList();
  }

  void _watchActivity() {
    final cId = myClassrooms.isNotEmpty ? (myClassrooms.first.key ?? '') : '';
    if (cId.isEmpty) return;
    _activitySub?.cancel();
    _activitySub = _activityService
        .watchActiveActivity(nurseryId, cId)
        .listen((a) => activeActivity.value = a);
  }

  Future<void> _loadChildrenCount() async {
    try {
      int total = 0;
      final counts = <String, int>{};
      final previews = <String, List<ChildPreview>>{};
      _classroomChildIds.clear();
      _childNames.clear();

      for (final c in myClassrooms) {
        final cId = c.key ?? '';
        final snap = await FirebaseDatabase.instance
            .ref('platform/$nurseryId/children')
            .orderByChild('classroomId')
            .equalTo(cId)
            .get();
        int count = 0;
        final ids = <String>[];
        final classPreviews = <ChildPreview>[];
        if (snap.exists && snap.value is Map) {
          for (final e in (snap.value as Map).entries) {
            if (e.value is! Map) continue;
            final d = Map<String, dynamic>.from(e.value as Map);
            if ((d['status'] ?? 'active') != 'active') continue;
            count++;
            final childId = e.key.toString();
            ids.add(childId);
            final firstName = d['firstName']?.toString() ?? '';
            final lastName = d['lastName']?.toString() ?? '';
            _childNames[childId] = '$firstName $lastName'.trim();
            if (classPreviews.length < 6) {
              classPreviews.add(ChildPreview(
                name: firstName.isNotEmpty ? firstName : lastName,
                image: d['profileImage']?.toString() ?? '',
              ));
            }
          }
        }
        counts[cId] = count;
        previews[cId] = classPreviews;
        _classroomChildIds[cId] = ids;
        total += count;
      }
      classroomChildCount.value = counts;
      classroomChildPreviews.value = previews;
      totalChildren.value = total;
      _watchChildrenStates();
    } catch (_) {}
  }

  void _watchChildrenStates() {
    _statesSub?.cancel();
    final allIds = _classroomChildIds.values.expand((ids) => ids).toList();
    if (allIds.isEmpty || nurseryId.isEmpty) return;

    _statesSub = _childStateService
        .watchChildrenStates(nurseryId, allIds)
        .listen(_onStatesUpdate);
  }

  void _onStatesUpdate(Map<String, ChildCurrentStatusModel?> states) {
    final attention = <ChildAttentionEntry>[];
    final badgeCounts = <String, int>{};

    for (final entry in _classroomChildIds.entries) {
      final classroomId = entry.key;
      final childIds = entry.value;
      final classroomName = myClassrooms
              .where((c) => c.key == classroomId)
              .firstOrNull
              ?.name ??
          '';
      int badge = 0;
      for (final childId in childIds) {
        final s = states[childId];
        if (s == null) continue;
        if (s.status == ChildStatus.checkedOut ||
            s.status == ChildStatus.notArrived) continue;
        final stateId = s.currentStateId ?? '';
        if (stateId.isEmpty || stateId == kDefaultStateId) continue;
        badge++;
        attention.add(ChildAttentionEntry(
          childId: childId,
          childName: _childNames[childId] ?? '',
          classroomId: classroomId,
          classroomName: classroomName,
          stateTitle: s.currentStateTitle ?? stateId,
        ));
      }
      if (badge > 0) badgeCounts[classroomId] = badge;
    }

    attentionChildren.value = attention;
    classroomAttentionCount.value = badgeCounts;
  }

  void prepareClassroomStates(ClassroomModel classroom) {
    Get.find<ClassroomStatesController>().initForClassroom(classroom);
  }

  Future<void> _loadPresentCount() async {
    try {
      final today = _todayKey();
      final cIds = myClassrooms.map((c) => c.key ?? '').toSet();
      final snap = await FirebaseDatabase.instance
          .ref('platform/$nurseryId/childAttendance')
          .orderByChild('date')
          .equalTo(today)
          .get();
      if (!snap.exists || snap.value == null) {
        presentToday.value = 0;
        return;
      }
      final data = snap.value as Map? ?? {};
      presentToday.value = data.values
          .where((v) =>
              v is Map &&
              cIds.contains(v['classroomId']?.toString()) &&
              (v['status'] == 'present' || v['status'] == 'late'))
          .length;
    } catch (_) {}
  }

  Future<void> _loadTodaySummary() async {
    try {
      int done = 0;
      int totalEvals = 0;
      double scoreSum = 0;
      final activities = <ClassroomActivityModel>[];
      final cActCount = <String, int>{};
      final cAvgSum = <String, double>{};
      final cAvgCount = <String, int>{};
      final childEvalMap = <String, Map<String, int>>{};

      final todayStart = _todayStartMillis().toDouble();

      for (final c in myClassrooms) {
        final cId = c.key ?? '';
        final snap = await FirebaseDatabase.instance
            .ref('platform/$nurseryId/classroomActivities/$cId')
            .orderByChild('startedAt')
            .startAt(todayStart)
            .get();
        if (!snap.exists || snap.value == null) continue;
        int cDone = 0;
        for (final entry in (snap.value as Map? ?? {}).entries) {
          if (entry.value is! Map) continue;
          final raw = Map<String, dynamic>.from(entry.value as Map);
          final activity = ClassroomActivityModel.fromJson(raw,
              key: entry.key.toString());
          activities.add(activity);
          if (activity.status == 'completed') {
            cDone++;
            done++;
            double actScoreSum = 0;
            int actScoreCount = 0;
            for (final evalEntry in activity.evaluations.entries) {
              totalEvals++;
              final level = EvalLevel.fromKey(evalEntry.value);
              final score = _evalScore(level);
              scoreSum += score;
              actScoreSum += score;
              actScoreCount++;
              final childId = evalEntry.key;
              final map = childEvalMap.putIfAbsent(
                  childId, () => {'excellent': 0, 'total': 0, 'score': 0});
              map['total'] = (map['total'] ?? 0) + 1;
              if (level == EvalLevel.excellent) {
                map['excellent'] = (map['excellent'] ?? 0) + 1;
              }
              map['score'] = (map['score'] ?? 0) + score.toInt();
            }
            if (actScoreCount > 0) {
              cAvgSum[cId] = (cAvgSum[cId] ?? 0) + actScoreSum;
              cAvgCount[cId] = (cAvgCount[cId] ?? 0) + actScoreCount;
            }
          }
          cActCount[cId] = cDone;
        }
      }

      int scheduleTotal = 0;
      for (final c in myClassrooms) {
        final cId = c.key ?? '';
        if (cId.isEmpty) continue;
        final slots = await _activityService.getTodayScheduleForClassroom(
          nurseryId: nurseryId,
          classroomId: cId,
        );
        scheduleTotal += slots.length;
      }

      activities.sort((a, b) => a.startedAt.compareTo(b.startedAt));
      todayActivities.value = activities;
      todayActivitiesTotal.value =
          activities.length > scheduleTotal ? activities.length : scheduleTotal;
      todayActivitiesDone.value = done;
      studentsEvaluatedToday.value = totalEvals;
      averagePerformance.value =
          totalEvals > 0 ? (scoreSum / totalEvals) : 0.0;

      final cAvg = <String, double>{};
      for (final cId in cAvgSum.keys) {
        final cnt = cAvgCount[cId] ?? 0;
        cAvg[cId] = cnt > 0 ? (cAvgSum[cId]! / cnt) : 0.0;
      }
      classroomActivitiesCount.value = cActCount;
      classroomAvgRating.value = cAvg;

      final performers = childEvalMap.entries.map((e) {
        final data = e.value;
        final total = data['total'] ?? 0;
        final score = data['score'] ?? 0;
        return TopPerformerEntry(
          childId: e.key,
          childName: _childNames[e.key] ?? e.key,
          excellentCount: data['excellent'] ?? 0,
          avgScore: total > 0 ? score / total : 0.0,
        );
      }).toList()
        ..sort((a, b) {
          final cmp = b.excellentCount.compareTo(a.excellentCount);
          if (cmp != 0) return cmp;
          return b.avgScore.compareTo(a.avgScore);
        });
      topPerformers.value = performers.take(3).toList();
    } catch (_) {}
  }

  double _evalScore(EvalLevel level) {
    switch (level) {
      case EvalLevel.excellent:
        return 5.0;
      case EvalLevel.needsFollow:
        return 3.0;
      case EvalLevel.needsAttention:
        return 1.0;
    }
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static int _todayStartMillis() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
  }

  Future<void> refreshTodaySummary() => _loadTodaySummary();

  @override
  Future<void> refresh() => _load();

  @override
  void onClose() {
    _activitySub?.cancel();
    _statesSub?.cancel();
    super.onClose();
  }
}
