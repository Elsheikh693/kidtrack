import '../../../../index/index_main.dart';

/// One display day of guardian notes (newest session first within the day).
class ParentNotesDay {
  final DateTime date;
  final List<GuardianNoteModel> notes;
  const ParentNotesDay({required this.date, required this.notes});
}

/// Staff-side inbox of guardian-authored session notes. Scope adapts to the
/// role: a teacher sees only their own classrooms; a manager (or owner acting
/// as one) sees every classroom in their branch. A date filter narrows to a
/// single past day.
class ParentNotesInboxController extends GetxController {
  final _session = SessionService();

  final isLoading = false.obs;
  final _all = <GuardianNoteModel>[].obs;

  /// null = show every day; otherwise only notes whose session fell on this day.
  /// Defaults to TODAY — the staff opens the inbox on today's notes first.
  final selectedDate = Rxn<DateTime>();

  final _classroomNames = <String, String>{};

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    selectedDate.value = DateTime(now.year, now.month, now.day);
    load();
  }

  String get _nurseryId => _session.nurseryId ?? '';

  String classroomName(GuardianNoteModel n) => n.classroomName.isNotEmpty
      ? n.classroomName
      : (_classroomNames[n.classroomId] ?? 'parent_notes_class_fallback'.tr);

  // ── Loading ────────────────────────────────────────────────────────────────

  Future<void> load() async {
    if (_nurseryId.isEmpty) return;
    isLoading.value = true;
    try {
      final ids = await _resolveScopeClassrooms();
      final svc = Get.find<GuardianNoteParentService>();
      final notes = await svc.getForClassrooms(ids);
      _all.assignAll(notes);
    } catch (_) {
      _all.clear();
    }
    isLoading.value = false;
  }

  Future<void> reload() => load();

  /// The classroom ids in scope, filling [_classroomNames] as a side effect.
  Future<Set<String>> _resolveScopeClassrooms() async {
    _classroomNames.clear();
    if (_session.isTeacher) {
      final list = await Get.find<TeacherActivityService>()
          .resolveClassrooms(_nurseryId, _session.userId ?? '');
      for (final c in list) {
        if (c.key != null) _classroomNames[c.key!] = c.name;
      }
      return _classroomNames.keys.toSet();
    }

    // Manager / owner-as-manager: every branch-visible classroom.
    final classrooms = <ClassroomModel>[];
    await Get.find<ClassroomParentService>().getAll(
      callBack: (list) => classrooms.addAll(list.whereType<ClassroomModel>()),
    );
    for (final c in classrooms) {
      final visible = c.isAllBranches || c.branchIds.any(_session.seesBranch);
      if (visible && c.key != null) _classroomNames[c.key!] = c.name;
    }
    return _classroomNames.keys.toSet();
  }

  // ── Date filter ──────────────────────────────────────────────────────────────

  void selectDate(DateTime? date) {
    selectedDate.value =
        date == null ? null : DateTime(date.year, date.month, date.day);
  }

  void clearDate() => selectedDate.value = null;

  String get formattedDate {
    final d = selectedDate.value;
    if (d == null) return 'parent_notes_all_days'.tr;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sel = DateTime(d.year, d.month, d.day);
    if (sel == today) return 'parent_notes_today'.tr;
    if (sel == today.subtract(const Duration(days: 1))) {
      return 'parent_notes_yesterday'.tr;
    }
    return '${d.day}/${d.month}/${d.year}';
  }

  // ── Derived view data ────────────────────────────────────────────────────────

  List<GuardianNoteModel> get _filtered {
    final d = selectedDate.value;
    if (d == null) return _all;
    final start = DateTime(d.year, d.month, d.day).millisecondsSinceEpoch;
    final end = DateTime(d.year, d.month, d.day)
        .add(const Duration(days: 1))
        .millisecondsSinceEpoch;
    return _all.where((n) {
      final anchor = n.dayKey != 0 ? n.dayKey : n.activityStartedAt;
      return anchor >= start && anchor < end;
    }).toList();
  }

  int get totalCount => _filtered.length;

  /// Notes grouped by day, newest day first, newest session first within a day.
  List<ParentNotesDay> get days {
    final byDay = <int, List<GuardianNoteModel>>{};
    for (final n in _filtered) {
      final ms = n.dayKey != 0 ? n.dayKey : n.activityStartedAt;
      final d = DateTime.fromMillisecondsSinceEpoch(ms);
      final key = DateTime(d.year, d.month, d.day).millisecondsSinceEpoch;
      byDay.putIfAbsent(key, () => []).add(n);
    }
    final keys = byDay.keys.toList()..sort((a, b) => b.compareTo(a));
    return [
      for (final k in keys)
        ParentNotesDay(
          date: DateTime.fromMillisecondsSinceEpoch(k),
          notes: byDay[k]!
            ..sort((a, b) => b.activityStartedAt.compareTo(a.activityStartedAt)),
        ),
    ];
  }
}
