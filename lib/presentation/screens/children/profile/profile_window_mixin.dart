part of 'controller.dart';

/// The day / week / month attendance window shared by the absences row and the
/// activities list. Kept out of the controller body so the controller stays a
/// thin orchestrator over the loaders. Same library (part) as the controller,
/// so the private window bounds stay reachable from the loaders.
mixin ProfileWindowMixin on GetxController {
  // Attendance records loaded for the active window.
  final recentAttendance = <ChildAttendanceModel>[].obs;

  // For day & week `anchorDate` is the last day shown and the window spans back
  // from it; for month the window is the whole calendar month containing it.
  final period = ProfilePeriod.day.obs;
  final anchorDate = DateTime.now().obs;

  bool get isMonthView => period.value == ProfilePeriod.month;

  DateTime get _anchorDay {
    final a = anchorDate.value;
    return DateTime(a.year, a.month, a.day);
  }

  /// First day shown in the current window.
  DateTime get _windowStart {
    switch (period.value) {
      case ProfilePeriod.day:
        return _anchorDay;
      case ProfilePeriod.week:
        return _anchorDay.subtract(const Duration(days: 6));
      case ProfilePeriod.month:
        return DateTime(_anchorDay.year, _anchorDay.month, 1);
    }
  }

  /// Last day shown in the current window.
  DateTime get _windowEnd {
    if (period.value == ProfilePeriod.month) {
      // Day 0 of next month == last day of this month.
      return DateTime(_anchorDay.year, _anchorDay.month + 1, 0);
    }
    return _anchorDay;
  }

  int get _startMs => _windowStart.millisecondsSinceEpoch;
  // End of the window's last day (exclusive boundary, minus 1ms to stay inclusive).
  int get _endMs =>
      _windowEnd.add(const Duration(days: 1)).millisecondsSinceEpoch - 1;

  bool get canGoForward {
    if (period.value == ProfilePeriod.month) {
      final current = DateTime(_today.year, _today.month, 1);
      final anchorMonth = DateTime(_anchorDay.year, _anchorDay.month, 1);
      return anchorMonth.isBefore(current);
    }
    return _anchorDay.isBefore(_today);
  }

  DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  /// Weekly day off. Friday only for now (official holidays: TODO calendar).
  bool _isWeekend(DateTime d) => d.weekday == DateTime.friday;

  /// Human label for the current window, e.g. "20 يونيو", "14 – 20 يونيو"
  /// or "يوليو 2026".
  String get rangeLabel {
    switch (period.value) {
      case ProfilePeriod.day:
        return _dayLabel(_anchorDay);
      case ProfilePeriod.week:
        final start = _windowStart;
        final end = _anchorDay;
        if (start.month == end.month) {
          return '${start.day} – ${end.day} ${_arMonth(end)}';
        }
        return '${_dayLabel(start)} – ${_dayLabel(end)}';
      case ProfilePeriod.month:
        return '${_arMonth(_anchorDay)} ${_anchorDay.year}';
    }
  }

  /// Derived per-day attendance status across the window (oldest → newest).
  /// Status: present | late | absent | holiday | not_arrived | future.
  List<MapEntry<String, String>> get windowDaysStatus {
    final todayKey = _dateStr(DateTime.now());
    final result = <MapEntry<String, String>>[];
    var d = _windowStart;
    final end = _windowEnd;
    while (!d.isAfter(end)) {
      final key = _dateStr(d);
      final rec = recentAttendance.where((a) => a.date == key).firstOrNull;
      if (d.isAfter(_today)) {
        result.add(MapEntry(key, 'future'));
      } else if (rec != null) {
        result.add(MapEntry(key, rec.status));
      } else if (_isWeekend(d)) {
        result.add(MapEntry(key, 'holiday'));
      } else if (key == todayKey) {
        result.add(MapEntry(key, 'not_arrived'));
      } else {
        result.add(MapEntry(key, 'absent'));
      }
      d = d.add(const Duration(days: 1));
    }
    return result;
  }

  /// Number of attended school days in the current window.
  int get presentCount =>
      windowDaysStatus.where((e) => e.value == 'present').length;

  /// Number of late-arrival days in the current window.
  int get lateCount =>
      windowDaysStatus.where((e) => e.value == 'late').length;

  /// Number of absent school days in the current window.
  int get absentCount =>
      windowDaysStatus.where((e) => e.value == 'absent').length;

  ChildAttendanceModel? get todayRecord {
    final today = _dateStr(DateTime.now());
    return recentAttendance.where((a) => a.date == today).firstOrNull;
  }

  // ─── Date helpers ─────────────────────────────────────────────────────────

  String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static const _arMonths = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];
  String _arMonth(DateTime d) => _arMonths[d.month - 1];
  String _dayLabel(DateTime d) => '${d.day} ${_arMonth(d)}';
}
