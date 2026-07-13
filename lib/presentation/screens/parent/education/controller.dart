import '../../../../index/index_main.dart';
import '../../../../Global/services/parent_education_service.dart';
import '../../../../Data/models/homework_submission/homework_submission_model.dart';

// ── Local UI models ────────────────────────────────────────────────────────────

enum ActivityStatus { done, active, upcoming }

class CurrentActivity {
  final String subjectKey;
  final String lessonTitle;
  final String startTime;
  final String startedAgo;

  const CurrentActivity({
    required this.subjectKey,
    required this.lessonTitle,
    required this.startTime,
    required this.startedAgo,
  });
}

class TodayActivity {
  final String time;
  final String subjectKey;
  final String title;
  final ActivityStatus status;

  const TodayActivity({
    required this.time,
    required this.subjectKey,
    required this.title,
    required this.status,
  });
}

class EduSubject {
  final String nameKey;
  final String lastActivityTitle;
  final String lastUpdated;
  final String ratingKey;

  const EduSubject({
    required this.nameKey,
    required this.lastActivityTitle,
    required this.lastUpdated,
    required this.ratingKey,
  });
}

class LearningActivity {
  final String time;
  final String subjectKey;
  final String title;

  const LearningActivity({
    required this.time,
    required this.subjectKey,
    required this.title,
  });
}

// ── Subject-grouped models (new education design) ───────────────────────────────

class SubjectActivity {
  final String title;
  final int startedAt;
  final String? evalLevel; // this child's evaluation key for the activity
  final String? note;      // this child's note for the activity

  const SubjectActivity({
    required this.title,
    required this.startedAt,
    this.evalLevel,
    this.note,
  });
}

class SubjectGroup {
  final String id;
  final String name;
  final String? icon;
  final List<SubjectActivity> activities; // newest first
  final List<EduHomework> homework;
  final String? ratingLevel; // latest assessment level for the subject

  const SubjectGroup({
    required this.id,
    required this.name,
    this.icon,
    this.activities = const [],
    this.homework = const [],
    this.ratingLevel,
  });

  int get activityCount => activities.length;
  int get pendingHomework => homework.where((h) => !h.isCompleted).length;
  SubjectActivity? get lastActivity =>
      activities.isEmpty ? null : activities.first;
}

class EduHomework {
  final String subjectKey;
  final String? subjectId;
  final String titleKey;
  final String dueDate;
  final bool isCompleted;
  final String? displayTitle;

  const EduHomework({
    required this.subjectKey,
    this.subjectId,
    required this.titleKey,
    required this.dueDate,
    this.isCompleted = false,
    this.displayTitle,
  });
}

enum NoteSeverity { positive, followup, important, info }

class TeacherNote {
  final String text;
  final NoteSeverity severity;
  const TeacherNote({required this.text, required this.severity});
}

// ── Daily Journal models (parent-first design) ──────────────────────────────────

class DayTimelineItem {
  final int startedAt;
  final int? endedAt;
  final String subjectName;
  final String? subjectId;
  final String? icon;
  final String title;
  final String? evalLevel; // this child's activity evaluation
  final String? note;      // this child's note for the activity
  final List<String> reasons; // structured evaluation reasons for this child
  final String? groupNote; // note written for the whole group/activity
  final List<String> photos;

  const DayTimelineItem({
    required this.startedAt,
    this.endedAt,
    required this.subjectName,
    this.subjectId,
    this.icon,
    required this.title,
    this.evalLevel,
    this.note,
    this.reasons = const [],
    this.groupNote,
    this.photos = const [],
  });
}

class DaySummary {
  final int activityCount;
  final int homeworkTotal;
  final int homeworkDone;
  final String? overallEval; // activity-eval scale: excellent/needs_follow/needs_attention
  final int negativeNotes;
  final List<String> skills;

  const DaySummary({
    required this.activityCount,
    required this.homeworkTotal,
    required this.homeworkDone,
    this.overallEval,
    required this.negativeNotes,
    required this.skills,
  });

  bool get hasAnyData =>
      activityCount > 0 || homeworkTotal > 0 || negativeNotes > 0;
}

// kept so existing widget files compile
class EduCourse {
  final String nameKey;
  final double progress;
  final String lastActivity;
  final String lastAssessment;
  const EduCourse({
    required this.nameKey,
    required this.progress,
    required this.lastActivity,
    required this.lastAssessment,
  });
}

class DevSkillGroup {
  final String titleKey;
  final List<DevSkill> skills;
  const DevSkillGroup({required this.titleKey, required this.skills});
}

class DevSkill {
  final String labelKey;
  final double level;
  const DevSkill({required this.labelKey, required this.level});
}

class EduAchievement {
  final String titleKey;
  final IconData icon;
  final Color color;
  final String date;
  const EduAchievement({
    required this.titleKey,
    required this.icon,
    required this.color,
    required this.date,
  });
}

class EduSkill {
  final String labelKey;
  final double level;
  const EduSkill({required this.labelKey, required this.level});
}

class HomeworkDay {
  final String label;
  final String dateStr;
  final List<EduHomework> homeworkList;
  final List<TeacherNote> notes;
  const HomeworkDay({
    required this.label,
    required this.dateStr,
    required this.homeworkList,
    required this.notes,
  });
}

// ── Controller ─────────────────────────────────────────────────────────────────

class ParentEducationController extends GetxController {
  final _session = SessionService();
  late final ParentEducationService _eduSvc;

  StreamSubscription<dynamic>? _notesSub;
  StreamSubscription<dynamic>? _activitySub;
  StreamSubscription<dynamic>? _hwSub;
  StreamSubscription<List<AssessmentModel>>? _assessmentsSub;
  Worker? _childWorker;

  // Child state
  final _childId = ''.obs;
  final _classroomId = ''.obs;
  final _childFullName = ''.obs;

  // Reactive UI state
  final teacherNotes = <TeacherNote>[].obs;
  final activeActivity = Rxn<CurrentActivity>();
  final todayActivities = <TodayActivity>[].obs;
  final subjects = <EduSubject>[].obs;
  final homework = <EduHomework>[].obs;
  final isLoading = true.obs;

  // ── Subject-grouped state (new design) ──────────────────────────────────────
  final selectedDate = DateTime.now().obs;
  final selectedSubjectId = RxnString();
  final subjectGroups = <SubjectGroup>[].obs;
  final isRangeLoading = false.obs;

  // ── Daily Journal state (parent-first) ──────────────────────────────────────
  final timeline = <DayTimelineItem>[].obs;
  final daySummary = Rxn<DaySummary>();

  // Internal accumulators feeding _rebuildGroups()
  List<SubjectModel> _allSubjects = const [];
  List<ClassroomActivityModel> _rangeActivities = const [];
  List<AssessmentModel> _allAssessments = const []; // raw, for day filtering
  List<NoteModel> _allNotes = const []; // raw, for day filtering
  List<HomeworkModel> _allHomework = const []; // raw, for day filtering
  Set<String> _submittedIds = const {}; // homeworkIds this child has submitted
  final Map<String, String> _ratingBySubjectId = {}; // subjectId → level (day-scoped)
  final Map<String, String> _nameToId = {}; // subjectName → subjectId

  SubjectGroup? get selectedGroup {
    final id = selectedSubjectId.value;
    if (id == null) return null;
    for (final g in subjectGroups) {
      if (g.id == id) return g;
    }
    return null;
  }

  // Getters for view
  String get childName =>
      _childFullName.value.isNotEmpty
          ? _childFullName.value
          : (_session.currentUser?.displayName ?? 'parent_default_name'.tr);
  String get childStatus => 'inside';
  String? get childImage => null;

  // Recent (completed) activities for RecentActivitiesSection
  List<LearningActivity> get recentActivities => todayActivities
      .where((a) => a.status == ActivityStatus.done)
      .map((a) => LearningActivity(time: a.time, subjectKey: a.subjectKey, title: a.title))
      .toList();

  // Derived homework lists (for HomeworkSection)
  List<EduHomework> get pendingHomework =>
      homework.where((h) => !h.isCompleted).toList();
  List<EduHomework> get completedHomework =>
      homework.where((h) => h.isCompleted).toList();
  bool get allHomeworkDone =>
      homework.isNotEmpty && homework.every((h) => h.isCompleted);

  // Legacy (kept so existing widget files compile)
  final List<EduCourse> courses = const [];
  final List<DevSkillGroup> skillGroups = const [];
  final List<EduAchievement> achievements = const [];
  final List<EduSkill> skills = const [];
  final RxInt selectedDayIndex = 0.obs;
  HomeworkDay get selectedDay => HomeworkDay(
        label: 'اليوم',
        dateStr: '',
        homeworkList: homework.toList(),
        notes: teacherNotes.toList(),
      );
  void changeDay(int index) => selectedDayIndex.value = index;
  final List<HomeworkDay> allDays = const [];

  @override
  void onInit() {
    super.onInit();
    _eduSvc = ParentEducationService();
    _loadData();
    _childWorker = ever<String>(
      Get.find<ActiveChildService>().childId,
      (_) => _reloadForNewChild(),
    );
    ParentEngagementService().markActivityView();
  }

  @override
  void onClose() {
    _childWorker?.dispose();
    _notesSub?.cancel();
    _activitySub?.cancel();
    _hwSub?.cancel();
    _assessmentsSub?.cancel();
    super.onClose();
  }

  /// Re-resolves the active child and reloads all education data when the
  /// parent switches to a different child.
  void _reloadForNewChild() {
    final svc = Get.find<ActiveChildService>();
    if (svc.childId.value.isEmpty || svc.childId.value == _childId.value) return;

    _notesSub?.cancel();
    _activitySub?.cancel();
    _hwSub?.cancel();
    _assessmentsSub?.cancel();

    teacherNotes.clear();
    activeActivity.value = null;
    todayActivities.clear();
    subjects.clear();
    homework.clear();
    subjectGroups.clear();
    selectedSubjectId.value = null;
    timeline.clear();
    daySummary.value = null;
    _allSubjects = const [];
    _rangeActivities = const [];
    _allAssessments = const [];
    _allNotes = const [];
    _allHomework = const [];
    _submittedIds = const {};

    isLoading.value = true;
    _loadData();
  }

  // ── Data loading ─────────────────────────────────────────────────────────────

  Future<void> _loadData() async {
    await _resolveChild();
    final childId = _childId.value;
    final classroomId = _classroomId.value;
    final nurseryId = _session.nurseryId ?? '';

    if (childId.isEmpty || nurseryId.isEmpty) {
      isLoading.value = false;
      return;
    }

    // Start real-time streams immediately (no await needed)
    _notesSub = _eduSvc.watchVisibleNotes(nurseryId, childId).listen((notes) {
      _allNotes = notes;
      _rebuildNotes();
      // Notes arrive live, but the day's activities are a one-shot fetch on a
      // kept-alive tab. A note almost always accompanies a completed activity,
      // so when a fresh note lands for the day being viewed, re-pull that day's
      // activities too — otherwise the parent sees "a note on a day with no
      // activities". Skipped during the initial load (handled below).
      if (!isLoading.value && _isViewingToday()) {
        _refreshRangeAndRebuild();
      }
    });

    if (classroomId.isNotEmpty) {
      _activitySub =
          _eduSvc.watchActiveActivity(nurseryId, classroomId).listen((act) {
        final prevLesson = activeActivity.value?.lessonTitle;
        activeActivity.value = act == null ? null : _mapActivity(act);
        // The day's completed activities are fetched one-shot, but this tab is
        // kept alive in an IndexedStack — so an activity the teacher completes
        // AFTER the parent first opened the tab would never appear, even though
        // its note streams in live (producing "a note on a day with no
        // activities"). watchActiveActivity emits whenever the classroom's
        // active activity changes — including completion, where it drops out of
        // the status=='active' query. On that transition, refresh today's
        // timeline so activities stay in sync with the live notes.
        final newLesson = activeActivity.value?.lessonTitle;
        if (prevLesson != newLesson && _isViewingToday()) {
          _refreshRangeAndRebuild();
        }
      });
      _subscribeHomework(nurseryId, classroomId, childId);
    }

    // Load subjects once + today's activities, then set up reactive assessments stream
    final todayFuture = classroomId.isNotEmpty
        ? _eduSvc.getTodayActivities(nurseryId, classroomId)
        : Future.value(<ClassroomActivityModel>[]);
    final subjectsFuture = _eduSvc.loadSubjects(nurseryId);

    final results = await Future.wait([todayFuture, subjectsFuture]);

    if (classroomId.isNotEmpty) {
      todayActivities.value = (results[0] as List)
          .map((a) => _mapTodayActivity(a as ClassroomActivityModel))
          .toList();
    }

    _allSubjects = (results[1] as List).cast<SubjectModel>();
    final subjectMap = {for (final s in _allSubjects) s.key ?? '': s.name};
    _nameToId
      ..clear()
      ..addEntries(_allSubjects
          .where((s) => s.key != null && s.name.isNotEmpty)
          .map((s) => MapEntry(s.name, s.key!)));

    // Reactive assessments — updates automatically when teacher adds evaluations.
    // We keep the full (non-deduped) list so ratings can be filtered by day.
    _assessmentsSub?.cancel();
    _assessmentsSub =
        _eduSvc.watchAllAssessments(nurseryId, childId).listen((assessments) {
      _allAssessments = assessments;

      // Legacy `subjects` list = most-recent assessment per subject (all-time)
      final seen = <String>{};
      final recent = <EduSubject>[];
      for (final a in assessments) {
        final bucket = a.subjectId?.isNotEmpty == true ? a.subjectId! : a.title;
        if (!seen.add(bucket)) continue;
        final subjectName =
            subjectMap[a.subjectId ?? ''] ?? a.subjectId ?? a.title;
        recent.add(EduSubject(
          nameKey: subjectName,
          lastActivityTitle: a.title,
          lastUpdated: _formatDate(a.date),
          ratingKey: _ratingKey(a.level),
        ));
      }
      subjects.value = recent;

      _rebuildGroups();
    });

    // Fetch activities for the default scope and build the subject groups
    await _fetchRangeActivities();

    isLoading.value = false;
  }

  // ── Subject-group date filtering ───────────────────────────────────────────────

  Future<void> setDate(DateTime date) async {
    final cur = selectedDate.value;
    if (cur.year == date.year && cur.month == date.month && cur.day == date.day) {
      return;
    }
    selectedDate.value = DateTime(date.year, date.month, date.day);
    await _fetchRangeActivities();
    _rebuildHomework();
    _rebuildNotes();
  }

  void selectSubject(String? subjectId) =>
      selectedSubjectId.value = subjectId;

  ({int start, int end}) _dayRange() {
    final d = selectedDate.value;
    final start = DateTime(d.year, d.month, d.day).millisecondsSinceEpoch;
    final end = DateTime(d.year, d.month, d.day)
        .add(const Duration(days: 1))
        .millisecondsSinceEpoch;
    return (start: start, end: end);
  }

  // Teacher notes scoped to the selected day
  void _rebuildNotes() {
    final r = _dayRange();
    teacherNotes.value = _allNotes
        .where((n) =>
            (n.createdAt ?? 0) >= r.start && (n.createdAt ?? 0) < r.end)
        .map(_mapNote)
        .toList();
    _rebuildJournal();
  }

  // ── Daily Journal builder ──────────────────────────────────────────────────────
  // Flattens the selected day's activities into a time-ordered timeline and a
  // single summary card — the parent reads "what my child did today" at a glance.
  void _rebuildJournal() {
    final childId = _childId.value;
    final iconById = {
      for (final s in _allSubjects)
        if (s.key != null && s.key!.isNotEmpty) s.key!: s.icon,
    };

    final items = _rangeActivities
        .where((a) => _childParticipated(a, childId))
        .map((a) => DayTimelineItem(
              startedAt: a.startedAt,
              endedAt: a.endedAt,
              subjectName:
                  a.subjectName?.isNotEmpty == true ? a.subjectName! : a.title,
              subjectId: a.subjectId,
              icon: a.subjectId == null ? null : iconById[a.subjectId],
              title: a.title,
              evalLevel: a.evaluations[childId],
              note: a.notes[childId],
              reasons: a.childReasons[childId] ?? const [],
              groupNote: a.groupNote,
              photos: a.approvedUrlsForChild(childId),
            ))
        .toList()
      ..sort((a, b) => a.startedAt.compareTo(b.startedAt));
    timeline.assignAll(items);

    // Overall day evaluation = average of the child's per-activity evaluations.
    var score = 0, rated = 0;
    for (final i in items) {
      final s = _evalScore(i.evalLevel);
      if (s == 0) continue;
      score += s;
      rated++;
    }
    String? overall;
    if (rated > 0) {
      final avg = score / rated;
      overall = avg >= 2.5
          ? 'excellent'
          : avg >= 1.6
              ? 'needs_follow'
              : 'needs_attention';
    }

    final negative = teacherNotes
        .where((n) =>
            n.severity == NoteSeverity.important ||
            n.severity == NoteSeverity.followup)
        .length;

    final skills = <String>[];
    for (final i in items) {
      if (!skills.contains(i.title)) skills.add(i.title);
      if (skills.length >= 6) break;
    }

    daySummary.value = DaySummary(
      activityCount: items.length,
      homeworkTotal: homework.length,
      homeworkDone: homework.where((h) => h.isCompleted).length,
      overallEval: overall,
      negativeNotes: negative,
      skills: skills,
    );
  }

  // A child sees an activity only if they were present when it started
  // (childIds is the check-in snapshot taken at start) — or were explicitly
  // evaluated/noted (covers a late arrival the teacher still assessed). Empty
  // childIds = legacy activity or attendance not tracked → shown to everyone.
  bool _childParticipated(ClassroomActivityModel a, String childId) {
    if (a.childIds.isEmpty) return true;
    return a.childIds.contains(childId) ||
        a.evaluations.containsKey(childId) ||
        a.notes.containsKey(childId);
  }

  int _evalScore(String? level) {
    switch (level) {
      case 'excellent':
        return 3;
      case 'needs_follow':
        return 2;
      case 'needs_attention':
        return 1;
      default:
        return 0;
    }
  }

  Future<void> _fetchRangeActivities() async {
    final nurseryId = _session.nurseryId ?? '';
    final classroomId = _classroomId.value;
    if (nurseryId.isEmpty || classroomId.isEmpty) {
      _rangeActivities = const [];
      _rebuildGroups();
      return;
    }
    isRangeLoading.value = true;
    final r = _dayRange();
    try {
      _rangeActivities = await _eduSvc.getActivitiesForRange(
        nurseryId,
        classroomId,
        startMs: r.start,
        endMs: r.end,
      );
    } catch (_) {
      _rangeActivities = const [];
    }
    isRangeLoading.value = false;
    // Rebuild the journal/summary AFTER the data lands. Critical on cold start:
    // the notes/assessments streams fire and rebuild while this awaited fetch is
    // still in flight (with _rangeActivities empty), then the fetch resolves —
    // without this rebuild the timeline would stay frozen empty until the parent
    // manually changes the date. (setDate rebuilds separately; the extra call is
    // cheap and keeps both paths correct.)
    _rebuildGroups();
  }

  bool _isViewingToday() {
    final d = selectedDate.value;
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  /// Live refresh of the selected day's activities (timeline + day summary),
  /// triggered when the classroom's active activity changes (start/complete).
  /// Keeps the kept-alive education tab in sync instead of staying frozen at
  /// whatever was fetched on first open.
  Future<void> _refreshRangeAndRebuild() async {
    final nurseryId = _session.nurseryId ?? '';
    final classroomId = _classroomId.value;
    if (classroomId.isNotEmpty && _isViewingToday()) {
      todayActivities.value =
          (await _eduSvc.getTodayActivities(nurseryId, classroomId))
              .map(_mapTodayActivity)
              .toList();
    }
    await _fetchRangeActivities();
    _rebuildGroups(); // also rebuilds the day journal + summary
  }

  void _rebuildGroups() {
    final childId = _childId.value;
    final accums = <String, _GroupAccum>{};

    // Ratings scoped to the selected day: most-recent per subject within the day
    final r = _dayRange();
    _ratingBySubjectId.clear();
    for (final a in _allAssessments) {
      if (a.date < r.start || a.date >= r.end) continue;
      final sid = a.subjectId ?? '';
      if (sid.isEmpty) continue;
      _ratingBySubjectId.putIfAbsent(sid, () => a.level); // list is date-desc
    }

    String canonId(String? subjectId, String? subjectName) {
      if (subjectId != null && subjectId.isNotEmpty) return subjectId;
      if (subjectName != null && subjectName.isNotEmpty) {
        return _nameToId[subjectName] ?? subjectName;
      }
      return '';
    }

    _GroupAccum accumFor(String id, String name, String? icon) =>
        accums.putIfAbsent(
          id,
          () => _GroupAccum(id: id, name: name, icon: icon),
        );

    // Seed from loaded subjects so name/icon resolve consistently
    for (final s in _allSubjects) {
      final id = s.key ?? '';
      if (id.isEmpty) continue;
      accumFor(id, s.name, s.icon);
    }

    // Activities in the selected date range (only ones the child was part of)
    for (final a in _rangeActivities) {
      if (!_childParticipated(a, childId)) continue;
      final id = canonId(a.subjectId, a.subjectName);
      if (id.isEmpty) continue;
      final name = a.subjectName?.isNotEmpty == true ? a.subjectName! : id;
      final acc = accumFor(id, name, null);
      acc.activities.add(SubjectActivity(
        title: a.title,
        startedAt: a.startedAt,
        evalLevel: a.evaluations[childId],
        note: a.notes[childId],
      ));
    }

    // Homework grouped by subject
    for (final hw in homework) {
      final id = canonId(hw.subjectId, hw.subjectKey);
      if (id.isEmpty) continue;
      final acc = accumFor(id, hw.subjectKey.isNotEmpty ? hw.subjectKey : id, null);
      acc.homework.add(hw);
    }

    final groups = accums.values
        .map((acc) {
          acc.activities.sort((a, b) => b.startedAt.compareTo(a.startedAt));
          return SubjectGroup(
            id: acc.id,
            name: acc.name,
            icon: acc.icon,
            activities: List.unmodifiable(acc.activities),
            homework: List.unmodifiable(acc.homework),
            ratingLevel: _ratingBySubjectId[acc.id],
          );
        })
        .where((g) =>
            g.activities.isNotEmpty ||
            g.homework.isNotEmpty ||
            g.ratingLevel != null)
        .toList()
      ..sort((a, b) {
        final ax = a.lastActivity?.startedAt ?? 0;
        final bx = b.lastActivity?.startedAt ?? 0;
        if (ax != bx) return bx.compareTo(ax);
        return a.name.compareTo(b.name);
      });

    subjectGroups.assignAll(groups);

    // Drop a stale subject selection if it no longer has content
    final sel = selectedSubjectId.value;
    if (sel != null && groups.every((g) => g.id != sel)) {
      selectedSubjectId.value = null;
    }

    _rebuildJournal();
  }

  /// Reads the active child from [ActiveChildService] (the single source of
  /// truth for which child the parent is viewing). Populated by the dashboard
  /// on startup and updated by the child switcher.
  Future<void> _resolveChild() async {
    final svc = Get.find<ActiveChildService>();
    _childId.value = svc.childId.value;
    _classroomId.value = svc.classroomId.value;
    _childFullName.value = svc.childName.value;
  }

  // ── Homework stream ───────────────────────────────────────────────────────────

  void _subscribeHomework(
      String nurseryId, String classroomId, String childId) {
    _hwSub?.cancel();
    _hwSub = _eduSvc
        .watchAllClassroomHomework(nurseryId, classroomId)
        .asyncMap((hwList) async {
          final ids = hwList
              .map((hw) => hw.key)
              .whereType<String>()
              .toList(growable: false);
          final submitted =
              await _eduSvc.getSubmittedHomeworkIds(nurseryId, childId, ids);
          return (homework: hwList, submitted: submitted);
        })
        .listen((data) {
          _allHomework = data.homework;
          _submittedIds = data.submitted;
          _rebuildHomework();
        });
  }

  // Homework scoped to the selected day. A homework belongs to the day it was
  // ASSIGNED (createdAt) — the day the child brought it home to do — falling
  // back to dueDate only if createdAt is missing. This keeps each journal page
  // anchored to its own day instead of always showing the latest "active"
  // homework under today.
  void _rebuildHomework() {
    final r = _dayRange();
    final list = _allHomework
        .where((hw) => hw.key != null)
        .where((hw) {
          final anchor = hw.createdAt ?? hw.dueDate ?? 0;
          return anchor >= r.start && anchor < r.end;
        })
        .map((hw) => EduHomework(
              subjectKey: hw.subjectName ?? hw.subjectId ?? '',
              subjectId: hw.subjectId,
              titleKey: hw.key!,
              displayTitle: hw.title,
              dueDate: _formatDueDate(hw.dueDate),
              isCompleted: _submittedIds.contains(hw.key),
            ))
        .toList();
    homework.assignAll(list);
    _rebuildGroups();
  }

  static String _formatDueDate(int? ms) {
    if (ms == null) return 'اليوم';
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }

  // ── Homework submission ───────────────────────────────────────────────────────
  // A submission records the parent's confirmation that the homework was done
  // at home (who helped + an optional note). It carries no quality judgment —
  // the teacher's review is a separate record.

  bool isSubmitted(String homeworkId) => _submittedIds.contains(homeworkId);

  void _setLocalSubmitted(String homeworkId, bool submitted) {
    final idx = homework.indexWhere((h) => h.titleKey == homeworkId);
    if (idx != -1) {
      final hw = homework[idx];
      homework[idx] = EduHomework(
        subjectKey: hw.subjectKey,
        subjectId: hw.subjectId,
        titleKey: hw.titleKey,
        displayTitle: hw.displayTitle,
        dueDate: hw.dueDate,
        isCompleted: submitted,
      );
    }
    _submittedIds = {..._submittedIds};
    if (submitted) {
      _submittedIds.add(homeworkId);
    } else {
      _submittedIds.remove(homeworkId);
    }
    _rebuildGroups();
  }

  Future<void> submitHomework(
    String homeworkId, {
    required SubmittedBy by,
    String? note,
  }) async {
    final nurseryId = _session.nurseryId ?? '';
    final classroomId = _classroomId.value;
    final childId = _childId.value;
    if (nurseryId.isEmpty || childId.isEmpty) return;
    _setLocalSubmitted(homeworkId, true);
    await _eduSvc.submitHomework(
      nurseryId: nurseryId,
      classroomId: classroomId,
      homeworkId: homeworkId,
      childId: childId,
      submittedBy: by,
      submittedByUid: _session.currentUser?.uid ?? '',
      note: note,
    );
  }

  Future<void> unsubmitHomework(String homeworkId) async {
    final nurseryId = _session.nurseryId ?? '';
    final childId = _childId.value;
    if (nurseryId.isEmpty || childId.isEmpty) return;
    _setLocalSubmitted(homeworkId, false);
    await _eduSvc.removeHomeworkSubmission(
      nurseryId: nurseryId,
      homeworkId: homeworkId,
      childId: childId,
    );
  }

  // ── Mappers ───────────────────────────────────────────────────────────────────

  TeacherNote _mapNote(NoteModel n) => TeacherNote(
        text: n.content,
        severity: _severityFromCategory(n.category),
      );

  NoteSeverity _severityFromCategory(String cat) {
    switch (cat) {
      case 'positive':
        return NoteSeverity.positive;
      case 'needs_follow':
        return NoteSeverity.followup;
      case 'important':
        return NoteSeverity.important;
      default:
        return NoteSeverity.info;
    }
  }

  CurrentActivity _mapActivity(ClassroomActivityModel act) {
    final mins = act.elapsed.inMinutes;
    final ago = mins < 1
        ? 'الآن'
        : mins < 60
            ? 'منذ $mins دقيقة'
            : 'منذ ${act.elapsed.inHours} ساعة';
    return CurrentActivity(
      subjectKey: act.subjectName ?? act.subjectId ?? act.title,
      lessonTitle: act.title,
      startTime: _formatTime(act.startedAt),
      startedAgo: ago,
    );
  }

  TodayActivity _mapTodayActivity(ClassroomActivityModel act) => TodayActivity(
        time: _formatTime(act.startedAt),
        subjectKey: act.subjectName ?? act.subjectId ?? act.title,
        title: act.title,
        status: act.isActive ? ActivityStatus.active : ActivityStatus.done,
      );

  String _ratingKey(String level) {
    switch (level) {
      case 'excellent':
        return 'parent_edu_rating_excellent';
      case 'good':
        return 'parent_edu_rating_very_good';
      case 'average':
        return 'parent_edu_rating_good';
      default:
        return 'parent_edu_rating_good';
    }
  }

  String _formatTime(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${dt.day} ${_monthName(dt.month)}';
  }

  String _monthName(int m) {
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    return months[m - 1];
  }
}

// ── Mutable accumulator used while building SubjectGroups ────────────────────────

class _GroupAccum {
  final String id;
  final String name;
  final String? icon;
  final List<SubjectActivity> activities = [];
  final List<EduHomework> homework = [];

  _GroupAccum({required this.id, required this.name, this.icon});
}
