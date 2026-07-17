import '../../../../../index/index_main.dart';

/// One working day inside the report week.
class AttendanceDay {
  final DateTime date;
  final String status; // present | late | absent | excused | none | upcoming
  final int? checkInTime;

  const AttendanceDay({
    required this.date,
    required this.status,
    this.checkInTime,
  });

  /// Weekday int (Mon=1 … Sun=7) → localization key for the short day name.
  String get dayKey => const {
        1: 'report_day_mon',
        2: 'report_day_tue',
        3: 'report_day_wed',
        4: 'report_day_thu',
        5: 'report_day_fri',
        6: 'report_day_sat',
        7: 'report_day_sun',
      }[date.weekday]!;
}

/// Aggregated numbers for a single week, produced by [_computeWeek].
class _WeekStats {
  final List<AttendanceDay> days;
  final int present;
  final int late;
  final int absent;
  final int excused;
  final double avgArrivalMinutes; // -1 when no arrivals

  const _WeekStats({
    required this.days,
    required this.present,
    required this.late,
    required this.absent,
    required this.excused,
    required this.avgArrivalMinutes,
  });

  /// Working days that actually counted (excludes excused, upcoming, no-record).
  int get schoolDays => present + late + absent;
  int get rate =>
      schoolDays == 0 ? 0 : (((present + late) / schoolDays) * 100).round();
  bool get isEmpty => present + late + absent + excused == 0;
}

class WeeklyAttendanceController extends GetxController {
  late final ChildAttendanceParentService _attendanceSvc;
  late final NurseryParentService _nurserySvc;
  late final ChildParentService _childSvc;
  late final ShiftParentService _shiftSvc;
  late final ActiveChildService _activeChild;

  final isLoading = true.obs;
  final weekOffset = 0.obs; // 0 = current week, -1 = last week, …

  // Reactive report state (recomputed on week change, no refetch).
  final days = <AttendanceDay>[].obs;
  final rate = 0.obs;
  final presentCount = 0.obs;
  final lateCount = 0.obs;
  final absentCount = 0.obs;
  final excusedCount = 0.obs;
  final schoolDays = 0.obs;
  final isEmptyWeek = false.obs;

  final avgArrivalLabel = ''.obs;
  final arrivalComparison = ''.obs; // '' when no shift to compare against
  final arrivalOnTime = true.obs;

  final insight = ''.obs;
  final trendDelta = 0.obs;
  final trendThisWeek = 0.obs;
  final trendLastWeek = 0.obs;
  final hasTrend = false.obs;

  String childName = '';
  ShiftModel? _shift;
  List<int> _workingDays = const [1, 2, 3, 4, 6, 7];
  final Map<String, ChildAttendanceModel> _byDate = {};

  String nurseryName = '';
  String? nurseryLogo;

  bool get canGoNext => weekOffset.value < 0;

  @override
  void onInit() {
    super.onInit();
    _attendanceSvc = Get.find<ChildAttendanceParentService>();
    _nurserySvc = Get.find<NurseryParentService>();
    _childSvc = Get.find<ChildParentService>();
    _shiftSvc = Get.find<ShiftParentService>();
    _activeChild = Get.find<ActiveChildService>();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    final childId = _activeChild.childId.value;
    childName = _activeChild.childName.value;

    // Independent fetches run concurrently; only the shift selection waits on
    // the child's shift key, and the shift list is prefetched in parallel too.
    final nurseryF = _loadNursery();
    final shiftKeyF = _loadChildShiftKey(childId);
    final attendanceF = _loadAttendance(childId);
    final shiftsF = _shiftSvc.getActive();

    await nurseryF;
    await attendanceF;
    final childShiftKey = await shiftKeyF;
    final shifts = await shiftsF;
    if (childShiftKey != null && childShiftKey.isNotEmpty) {
      for (final s in shifts) {
        if (s.key == childShiftKey) {
          _shift = s;
          break;
        }
      }
    }

    _recompute();
    isLoading.value = false;
  }

  Future<void> _loadNursery() async {
    final sessionNurseryId = SessionService().nurseryId ?? '';
    await _nurserySvc.getAll(
      callBack: (list) {
        final nurseries = list.whereType<NurseryModel>();
        if (nurseries.isEmpty) return;
        final n = nurseries.firstWhere(
          (item) => item.key == sessionNurseryId,
          orElse: () => nurseries.first,
        );
        _workingDays = n.effectiveWorkingDays;
        nurseryName = n.name;
        nurseryLogo = n.logo;
      },
    );
  }

  Future<String?> _loadChildShiftKey(String childId) async {
    String? shiftKey;
    await _childSvc.getAll(
      callBack: (list) {
        for (final c in list.whereType<ChildModel>()) {
          if (c.key == childId) {
            shiftKey = c.shift;
            break;
          }
        }
      },
    );
    return shiftKey;
  }

  Future<void> _loadAttendance(String childId) async {
    _byDate.clear();
    await _attendanceSvc.getAll(
      callBack: (list) {
        for (final a in list.whereType<ChildAttendanceModel>()) {
          if (a.childId == childId) _byDate[a.date] = a;
        }
      },
    );
  }

  void previousWeek() {
    weekOffset.value -= 1;
    _recompute();
  }

  void nextWeek() {
    if (!canGoNext) return;
    weekOffset.value += 1;
    _recompute();
  }

  // ── Computation ─────────────────────────────────────────────────────────

  void _recompute() {
    final stats = _computeWeek(weekOffset.value);
    days.value = stats.days;
    presentCount.value = stats.present;
    lateCount.value = stats.late;
    absentCount.value = stats.absent;
    excusedCount.value = stats.excused;
    schoolDays.value = stats.schoolDays;
    rate.value = stats.rate;
    isEmptyWeek.value = stats.isEmpty;

    _buildArrival(stats);
    _buildTrend(stats);
    _buildInsight(stats);
  }

  DateTime _weekStart(int offset) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Week starts Saturday (weekday 6). Days since the most recent Saturday.
    // offset shifts whole weeks: 0 = current, -1 = previous, …
    final daysSinceSat = (today.weekday - DateTime.saturday + 7) % 7;
    return today.subtract(Duration(days: daysSinceSat - offset * 7));
  }

  _WeekStats _computeWeek(int offset) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = _weekStart(offset);

    final result = <AttendanceDay>[];
    var present = 0, late = 0, absent = 0, excused = 0;
    var arrivalSum = 0, arrivalCount = 0;

    for (var i = 0; i < 7; i++) {
      final date = start.add(Duration(days: i));
      if (!_workingDays.contains(date.weekday)) continue;

      String status;
      int? checkIn;
      if (date.isAfter(today)) {
        status = 'upcoming';
      } else {
        final record = _byDate[_dateKey(date)];
        if (record == null) {
          // Attendance is actively taken every working day, so a past working
          // day with no check-in record means the child was absent. Today
          // itself stays pending ('none') — the child may still arrive.
          if (date.isBefore(today)) {
            status = 'absent';
            absent++;
          } else {
            status = 'none';
          }
        } else {
          status = record.status;
          checkIn = record.checkInTime;
          switch (record.status) {
            case 'present':
              present++;
              break;
            case 'late':
              late++;
              break;
            case 'absent':
              absent++;
              break;
            case 'excused':
              excused++;
              break;
          }
          if ((record.status == 'present' || record.status == 'late') &&
              checkIn != null) {
            final t = DateTime.fromMillisecondsSinceEpoch(checkIn);
            arrivalSum += t.hour * 60 + t.minute;
            arrivalCount++;
          }
        }
      }
      result.add(AttendanceDay(date: date, status: status, checkInTime: checkIn));
    }

    return _WeekStats(
      days: result,
      present: present,
      late: late,
      absent: absent,
      excused: excused,
      avgArrivalMinutes: arrivalCount == 0 ? -1 : arrivalSum / arrivalCount,
    );
  }

  void _buildArrival(_WeekStats stats) {
    if (stats.avgArrivalMinutes < 0) {
      avgArrivalLabel.value = '—';
      arrivalComparison.value = '';
      return;
    }
    final avg = stats.avgArrivalMinutes.round();
    avgArrivalLabel.value = ShiftModel.formatMinutes(avg);
    final shift = _shift;
    if (shift == null) {
      arrivalComparison.value = '';
      return;
    }
    if (avg <= shift.onTimeCutoff) {
      arrivalOnTime.value = true;
      arrivalComparison.value = 'report_arrival_on_time'.tr;
    } else {
      arrivalOnTime.value = false;
      final lateBy = avg - shift.startMinutes;
      arrivalComparison.value =
          'report_arrival_late'.trParams({'m': '$lateBy'});
    }
  }

  void _buildTrend(_WeekStats current) {
    final last = _computeWeek(weekOffset.value - 1);
    if (last.isEmpty) {
      hasTrend.value = false;
      return;
    }
    hasTrend.value = true;
    trendThisWeek.value = current.rate;
    trendLastWeek.value = last.rate;
    trendDelta.value = current.rate - last.rate;
  }

  void _buildInsight(_WeekStats stats) {
    final name = childName;
    if (stats.isEmpty) {
      insight.value = '';
      return;
    }
    if (stats.absent >= 2) {
      insight.value = 'report_insight_absences'.trParams({'name': name});
    } else if (stats.late >= 2) {
      insight.value = 'report_insight_late'.trParams({'name': name});
    } else if (stats.rate >= 90) {
      insight.value = 'report_insight_excellent'
          .trParams({'name': name, 'rate': '${stats.rate}'});
    } else {
      insight.value = 'report_insight_neutral'.trParams({'name': name});
    }
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${_two(d.month)}-${_two(d.day)}';
  String _two(int v) => v.toString().padLeft(2, '0');

  /// "6/7 - 12/7" style range for the current week window.
  String get weekRangeLabel {
    final start = _weekStart(weekOffset.value);
    final end = start.add(const Duration(days: 6));
    return '${start.day}/${start.month} - ${end.day}/${end.month}';
  }
}
