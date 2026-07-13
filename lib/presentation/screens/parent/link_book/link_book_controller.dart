import '../../../../index/index_main.dart';
import '../../../../Global/services/parent_education_service.dart';

/// One full day in the parent's Link Book — everything that happened to the
/// child that day, pre-built so the day-detail screen needs no extra fetch.
class LinkBookDay {
  final DateTime date;
  final List<DayTimelineItem> timeline; // sorted by startedAt
  final List<TeacherNote> notes;
  final String? overallEval; // excellent / needs_follow / needs_attention
  final int photoCount;

  const LinkBookDay({
    required this.date,
    required this.timeline,
    required this.notes,
    required this.overallEval,
    required this.photoCount,
  });

  int get activityCount => timeline.length;

  int get negativeNotes => notes
      .where((n) =>
          n.severity == NoteSeverity.important ||
          n.severity == NoteSeverity.followup)
      .length;

  /// Distinct subject names for the day (for the grid card chips).
  List<String> get subjects {
    final out = <String>[];
    for (final t in timeline) {
      if (!out.contains(t.subjectName)) out.add(t.subjectName);
    }
    return out;
  }

  /// Every photo taken across the day's activities, time-ordered, each tagged
  /// with the activity it belongs to — feeds the day album + full-screen viewer.
  List<LinkBookPhoto> get photos {
    final out = <LinkBookPhoto>[];
    for (final t in timeline) {
      for (final url in t.photos) {
        out.add(LinkBookPhoto(
          url: url,
          activityTitle: t.title.isNotEmpty ? t.title : t.subjectName,
          takenAt: t.startedAt,
        ));
      }
    }
    return out;
  }

  int get dayKey =>
      DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
}

/// A single Link Book photo with the context it was captured in.
class LinkBookPhoto {
  final String url;
  final String activityTitle;
  final int takenAt;

  const LinkBookPhoto({
    required this.url,
    required this.activityTitle,
    required this.takenAt,
  });
}

/// Whether the book is browsed by day or by subject.
enum LbViewMode { days, subjects }

int lbEvalScore(String? level) {
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

/// One entry in a subject's history — a single activity the child did in it.
class SubjectHistoryEntry {
  final int startedAt;
  final String title;
  final String? evalLevel;
  final String? note; // teacher comment for this child
  final String? groupNote;
  final List<String> reasons;
  final List<String> photos;

  const SubjectHistoryEntry({
    required this.startedAt,
    required this.title,
    this.evalLevel,
    this.note,
    this.groupNote,
    this.reasons = const [],
    this.photos = const [],
  });
}

/// A subject's full journey for the child: every activity, comment, evaluation
/// and photo over time, plus a derived development trend.
class SubjectHistory {
  final String id;
  final String name;
  final String? icon;
  final List<SubjectHistoryEntry> entries; // newest first

  const SubjectHistory({
    required this.id,
    required this.name,
    this.icon,
    required this.entries,
  });

  int get activityCount => entries.length;

  int get photoCount =>
      entries.fold(0, (acc, e) => acc + e.photos.length);

  int get ratedCount =>
      entries.where((e) => lbEvalScore(e.evalLevel) > 0).length;

  String? get latestEval {
    for (final e in entries) {
      if (e.evalLevel != null && e.evalLevel!.isNotEmpty) return e.evalLevel;
    }
    return null;
  }

  /// Evaluation scores oldest → newest (rated only) — feeds the sparkline.
  List<int> get evalSeries {
    final out = <int>[];
    for (var i = entries.length - 1; i >= 0; i--) {
      final s = lbEvalScore(entries[i].evalLevel);
      if (s > 0) out.add(s);
    }
    return out;
  }

  /// 'up' / 'down' / 'steady' / null — comparing the older vs newer half of
  /// the child's evaluations in this subject.
  String? get trend {
    final s = evalSeries;
    if (s.length < 2) return null;
    final mid = s.length ~/ 2;
    final older = s.sublist(0, mid == 0 ? 1 : mid);
    final newer = s.sublist(mid == 0 ? 1 : mid);
    final oa = older.reduce((a, b) => a + b) / older.length;
    final na = newer.reduce((a, b) => a + b) / newer.length;
    final d = na - oa;
    if (d > 0.25) return 'up';
    if (d < -0.25) return 'down';
    return 'steady';
  }

  List<LinkBookPhoto> get photosList {
    final out = <LinkBookPhoto>[];
    for (final e in entries) {
      for (final url in e.photos) {
        out.add(LinkBookPhoto(
          url: url,
          activityTitle: e.title,
          takenAt: e.startedAt,
        ));
      }
    }
    return out;
  }
}

class ParentLinkBookController extends GetxController {
  final _session = SessionService();
  final _eduSvc = ParentEducationService();

  /// How far back the book reaches.
  static const _historyDays = 60;

  final isLoading = true.obs;
  final days = <LinkBookDay>[].obs;
  final subjectHistories = <SubjectHistory>[].obs;

  /// days vs subjects view of the book.
  final viewMode = LbViewMode.days.obs;
  void setMode(LbViewMode m) => viewMode.value = m;

  /// null = "all months". Drives the grid month filter.
  final selectedMonth = Rxn<DateTime>();

  /// Distinct months present in the book, newest first (days are already sorted).
  List<DateTime> get months {
    final seen = <String>{};
    final out = <DateTime>[];
    for (final d in days) {
      final key = '${d.date.year}-${d.date.month}';
      if (seen.add(key)) out.add(DateTime(d.date.year, d.date.month));
    }
    return out;
  }

  List<LinkBookDay> get filteredDays {
    final m = selectedMonth.value;
    if (m == null) return days;
    return days
        .where((d) => d.date.year == m.year && d.date.month == m.month)
        .toList();
  }

  void setMonth(DateTime? m) => selectedMonth.value = m;

  String _childName = '';
  String get childName =>
      _childName.isNotEmpty ? _childName : 'parent_default_name'.tr;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> reload() => _load();

  Future<void> _load() async {
    isLoading.value = true;
    selectedMonth.value = null;

    final svc = Get.find<ActiveChildService>();
    final childId = svc.childId.value;
    final classroomId = svc.classroomId.value;
    final nurseryId = _session.nurseryId ?? '';
    _childName = svc.childName.value;

    if (childId.isEmpty || classroomId.isEmpty || nurseryId.isEmpty) {
      days.clear();
      subjectHistories.clear();
      isLoading.value = false;
      return;
    }

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: _historyDays))
        .millisecondsSinceEpoch;
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999)
        .millisecondsSinceEpoch;

    try {
      final results = await Future.wait([
        _eduSvc.getActivitiesForRange(nurseryId, classroomId,
            startMs: start, endMs: end),
        _eduSvc.loadSubjects(nurseryId),
        _eduSvc.watchVisibleNotes(nurseryId, childId).first,
      ]);

      final activities = results[0] as List<ClassroomActivityModel>;
      final subjects = results[1] as List<SubjectModel>;
      final notes = results[2] as List<NoteModel>;

      days.assignAll(_buildDays(childId, activities, subjects, notes));
      subjectHistories.assignAll(_buildSubjects(childId, activities, subjects));
    } catch (_) {
      days.clear();
      subjectHistories.clear();
    }

    isLoading.value = false;
  }

  List<SubjectHistory> _buildSubjects(
    String childId,
    List<ClassroomActivityModel> activities,
    List<SubjectModel> subjects,
  ) {
    final names = <String, String>{};
    final icons = <String, String?>{};
    for (final s in subjects) {
      final id = s.key ?? '';
      if (id.isEmpty) continue;
      names[id] = s.name;
      icons[id] = s.icon;
    }

    final accum = <String, List<SubjectHistoryEntry>>{};
    for (final a in activities) {
      final id = (a.subjectId?.isNotEmpty == true)
          ? a.subjectId!
          : (a.subjectName?.isNotEmpty == true ? a.subjectName! : '');
      if (id.isEmpty) continue;
      if (a.subjectName?.isNotEmpty == true) {
        names.putIfAbsent(id, () => a.subjectName!);
      }
      accum.putIfAbsent(id, () => []).add(SubjectHistoryEntry(
            startedAt: a.startedAt,
            title: a.title,
            evalLevel: a.evaluations[childId],
            note: a.notes[childId],
            groupNote: a.groupNote,
            reasons: a.childReasons[childId] ?? const [],
            photos: a.approvedUrlsForChild(childId),
          ));
    }

    final out = accum.entries.map((e) {
      final entries = e.value
        ..sort((a, b) => b.startedAt.compareTo(a.startedAt)); // newest first
      return SubjectHistory(
        id: e.key,
        name: names[e.key] ?? e.key,
        icon: icons[e.key],
        entries: entries,
      );
    }).toList()
      ..sort((a, b) =>
          b.entries.first.startedAt.compareTo(a.entries.first.startedAt));
    return out;
  }

  List<LinkBookDay> _buildDays(
    String childId,
    List<ClassroomActivityModel> activities,
    List<SubjectModel> subjects,
    List<NoteModel> notes,
  ) {
    final iconById = {
      for (final s in subjects)
        if (s.key != null && s.key!.isNotEmpty) s.key!: s.icon,
    };

    int dayKeyOf(int ms) {
      final d = DateTime.fromMillisecondsSinceEpoch(ms);
      return DateTime(d.year, d.month, d.day).millisecondsSinceEpoch;
    }

    // Group activities by day → timeline items
    final timelineByDay = <int, List<DayTimelineItem>>{};
    for (final a in activities) {
      final item = DayTimelineItem(
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
      );
      timelineByDay.putIfAbsent(dayKeyOf(a.startedAt), () => []).add(item);
    }

    // Group visible notes by day
    final notesByDay = <int, List<TeacherNote>>{};
    for (final n in notes) {
      final created = n.createdAt ?? 0;
      if (created == 0) continue;
      notesByDay
          .putIfAbsent(dayKeyOf(created), () => [])
          .add(TeacherNote(
            text: n.content,
            severity: _severityFromCategory(n.category),
          ));
    }

    final allKeys = <int>{...timelineByDay.keys, ...notesByDay.keys}.toList()
      ..sort((a, b) => b.compareTo(a)); // newest first

    final out = <LinkBookDay>[];
    for (final key in allKeys) {
      final timeline = (timelineByDay[key] ?? [])
        ..sort((a, b) => a.startedAt.compareTo(b.startedAt));
      final dayNotes = notesByDay[key] ?? const <TeacherNote>[];

      var photoCount = 0;
      for (final t in timeline) {
        photoCount += t.photos.length;
      }

      out.add(LinkBookDay(
        date: DateTime.fromMillisecondsSinceEpoch(key),
        timeline: timeline,
        notes: dayNotes,
        overallEval: _overallEval(timeline),
        photoCount: photoCount,
      ));
    }
    return out;
  }

  String? _overallEval(List<DayTimelineItem> items) {
    var score = 0, rated = 0;
    for (final i in items) {
      final s = _evalScore(i.evalLevel);
      if (s == 0) continue;
      score += s;
      rated++;
    }
    if (rated == 0) return null;
    final avg = score / rated;
    if (avg >= 2.5) return 'excellent';
    if (avg >= 1.6) return 'needs_follow';
    return 'needs_attention';
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
}
