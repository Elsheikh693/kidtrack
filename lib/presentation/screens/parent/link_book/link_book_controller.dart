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

  /// True only during the first bootstrap (resolving months + first month).
  final isLoading = true.obs;

  /// True while switching to a different month (keeps the month bar on screen).
  final daysLoading = false.obs;

  /// The SELECTED month's data only — never the whole history. Each month is
  /// fetched on demand so the book scales to years without a giant load.
  final days = <LinkBookDay>[].obs;
  final subjectHistories = <SubjectHistory>[].obs;

  /// days vs subjects view of the book.
  final viewMode = LbViewMode.days.obs;
  void setMode(LbViewMode m) => viewMode.value = m;

  /// Every month with (potentially) data, newest first — from the child's first
  /// recorded activity to the current month. Drives the month bar chips.
  final availableMonths = <DateTime>[].obs;

  /// The month currently loaded (first of the month). Always set after bootstrap.
  final selectedMonth = Rxn<DateTime>();

  // Resolved once at bootstrap and reused for every per-month fetch.
  String _childId = '';
  String _classroomId = '';
  String _nurseryId = '';

  // Fetched once at bootstrap (small, cross-month) and filtered per month.
  List<SubjectModel> _subjects = const [];
  List<NoteModel> _allNotes = const [];

  void setMonth(DateTime m) {
    final cur = selectedMonth.value;
    if (cur != null && cur.year == m.year && cur.month == m.month) return;
    selectedMonth.value = DateTime(m.year, m.month);
    _loadMonth(selectedMonth.value!);
  }

  String _childName = '';
  String get childName =>
      _childName.isNotEmpty ? _childName : 'parent_default_name'.tr;

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  Future<void> reload() => _bootstrap();

  /// Resolves the child scope, discovers the available months (one tiny read),
  /// caches the cross-month subjects + notes, then loads the newest month.
  Future<void> _bootstrap() async {
    isLoading.value = true;

    final svc = Get.find<ActiveChildService>();
    _childId = svc.childId.value;
    _classroomId = svc.classroomId.value;
    _nurseryId = _session.nurseryId ?? '';
    _childName = svc.childName.value;

    if (_childId.isEmpty || _classroomId.isEmpty || _nurseryId.isEmpty) {
      availableMonths.clear();
      days.clear();
      subjectHistories.clear();
      isLoading.value = false;
      return;
    }

    try {
      final results = await Future.wait([
        _eduSvc.getEarliestActivityMs(_nurseryId, _classroomId),
        _eduSvc.loadSubjects(_nurseryId),
        _eduSvc.watchVisibleNotes(_nurseryId, _childId).first,
      ]);
      final earliestActivityMs = results[0] as int?;
      _subjects = results[1] as List<SubjectModel>;
      _allNotes = results[2] as List<NoteModel>;

      // The book reaches back to the oldest activity OR the oldest note.
      final earliest = _minMs(earliestActivityMs, _earliestNoteMs());

      if (earliest == null) {
        // Genuinely empty book — no activities, no notes ever.
        availableMonths.clear();
        days.clear();
        subjectHistories.clear();
        isLoading.value = false;
        return;
      }

      availableMonths.assignAll(_monthsFrom(earliest));
      selectedMonth.value = availableMonths.first;
      await _loadMonth(selectedMonth.value!);
    } catch (_) {
      availableMonths.clear();
      days.clear();
      subjectHistories.clear();
    }

    isLoading.value = false;
  }

  int? _earliestNoteMs() {
    int? min;
    for (final n in _allNotes) {
      final c = n.createdAt ?? 0;
      if (c > 0 && (min == null || c < min)) min = c;
    }
    return min;
  }

  int? _minMs(int? a, int? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a < b ? a : b;
  }

  /// Month list (newest first) from [earliestMs]'s month up to the current month.
  List<DateTime> _monthsFrom(int earliestMs) {
    final now = DateTime.now();
    final last = DateTime(now.year, now.month);
    final d = DateTime.fromMillisecondsSinceEpoch(earliestMs);
    final rawFirst = DateTime(d.year, d.month);
    // Guard against a future timestamp (clock skew) so the list is never empty.
    final first = rawFirst.isAfter(last) ? last : rawFirst;
    final out = <DateTime>[];
    var cur = last;
    while (!cur.isBefore(first)) {
      out.add(cur);
      cur = DateTime(cur.year, cur.month - 1); // underflow rolls the year back
    }
    return out;
  }

  /// Fetches ONE month's activities and rebuilds the days + subjects from them
  /// (notes are the cached full set, filtered to the month).
  Future<void> _loadMonth(DateTime month) async {
    daysLoading.value = true;

    final start = DateTime(month.year, month.month, 1).millisecondsSinceEpoch;
    final end = DateTime(month.year, month.month + 1, 1)
        .subtract(const Duration(milliseconds: 1))
        .millisecondsSinceEpoch;

    try {
      final activities = await _eduSvc.getActivitiesForRange(
        _nurseryId,
        _classroomId,
        startMs: start,
        endMs: end,
      );
      final notes = _allNotes.where((n) {
        final c = n.createdAt ?? 0;
        return c >= start && c <= end;
      }).toList();

      days.assignAll(_buildDays(_childId, activities, _subjects, notes));
      subjectHistories
          .assignAll(_buildSubjects(_childId, activities, _subjects));
    } catch (_) {
      days.clear();
      subjectHistories.clear();
    }

    daysLoading.value = false;
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
        activityId: a.key,
        classroomId: a.classroomId,
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
