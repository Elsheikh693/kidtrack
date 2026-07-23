import '../../../../../index/index_main.dart';

/// Raw snapshot behind the owner's non-finance analytics reports (academic,
/// satisfaction, safety, staff-cost). Loaded ONCE and shared, mirroring
/// [OwnerFinanceDataService]'s compute-once philosophy — these reports need
/// row-level records (exam results, incidents, staff attendance/leave, parent
/// feedback) the executive bundle doesn't surface, so they read here instead of
/// re-fetching per report.
class OwnerReportsData {
  final List<ExamResultModel> examResults;
  final List<IncidentModel> incidents;
  final List<StaffAttendanceModel> staffAttendance;
  final List<StaffLeaveModel> staffLeaves;
  final List<StaffModel> staff;
  final List<NurseryFeedbackModel> feedback;

  const OwnerReportsData({
    required this.examResults,
    required this.incidents,
    required this.staffAttendance,
    required this.staffLeaves,
    required this.staff,
    required this.feedback,
  });
}

class OwnerReportsDataService extends GetxService {
  final Rxn<OwnerReportsData> data = Rxn<OwnerReportsData>();
  final RxBool isFirstLoading = false.obs;
  final RxBool isRefreshing = false.obs;

  /// Load once; subsequent report opens reuse the snapshot.
  Future<void> ensureLoaded() async {
    if (data.value != null) return;
    isFirstLoading.value = true;
    await refresh();
  }

  Future<void> refresh() async {
    isRefreshing.value = true;
    try {
      final r = await Future.wait([
        _fetch<ExamResultModel>('examResults'),
        _fetch<IncidentModel>('incidents'),
        _fetch<StaffAttendanceModel>('staffAttendance'),
        _fetch<StaffLeaveModel>('staffLeaves'),
        _fetch<StaffModel>('staff'),
        _fetch<NurseryFeedbackModel>('nurseryFeedback'),
      ]);
      data.value = OwnerReportsData(
        examResults: r[0].whereType<ExamResultModel>().toList(),
        incidents: r[1].whereType<IncidentModel>().toList(),
        staffAttendance: r[2].whereType<StaffAttendanceModel>().toList(),
        staffLeaves: r[3].whereType<StaffLeaveModel>().toList(),
        staff: r[4].whereType<StaffModel>().toList(),
        feedback: r[5].whereType<NurseryFeedbackModel>().toList(),
      );
    } finally {
      isFirstLoading.value = false;
      isRefreshing.value = false;
    }
  }

  Future<List<dynamic>> _fetch<T>(String tag) {
    final c = Completer<List<dynamic>>();
    Get.find<BaseService<T>>(tag: tag).getData(
      data: {},
      voidCallBack: (list) {
        if (!c.isCompleted) c.complete(list);
      },
    );
    return c.future;
  }

  // ── Scope helpers ───────────────────────────────────────────────────────────

  /// Graded exam results for [scope] (results carry their own branchId).
  List<ExamResultModel> examResultsFor(OwnerScope scope) {
    final d = data.value;
    if (d == null) return const [];
    return d.examResults
        .where((e) =>
            e.grade.isNotEmpty &&
            (scope.isNetwork || e.branchId == scope.branchId))
        .toList();
  }

  /// Incidents for [scope].
  List<IncidentModel> incidentsFor(OwnerScope scope) {
    final d = data.value;
    if (d == null) return const [];
    return d.incidents
        .where((i) => scope.isNetwork || i.branchId == scope.branchId)
        .toList();
  }

  /// Staff-attendance rows for [scope].
  List<StaffAttendanceModel> staffAttendanceFor(OwnerScope scope) {
    final d = data.value;
    if (d == null) return const [];
    return d.staffAttendance
        .where((a) => scope.isNetwork || a.branchId == scope.branchId)
        .toList();
  }

  /// Active staff in [scope].
  List<StaffModel> activeStaffFor(OwnerScope scope) {
    final d = data.value;
    if (d == null) return const [];
    return d.staff
        .where((s) =>
            s.isActive && (scope.isNetwork || s.branchId == scope.branchId))
        .toList();
  }

  /// Pending leave requests for [scope] (leave carries no branchId — resolved
  /// through the requesting staff member).
  List<StaffLeaveModel> pendingLeavesFor(OwnerScope scope) {
    final d = data.value;
    if (d == null) return const [];
    final branchOf = {
      for (final s in d.staff)
        if (s.key != null) s.key!: s.branchId,
    };
    return d.staffLeaves
        .where((l) =>
            l.status == 'pending' &&
            (scope.isNetwork || branchOf[l.staffId] == scope.branchId))
        .toList();
  }

  /// Parent feedback (network-level — feedback carries no branch dimension).
  List<NurseryFeedbackModel> get feedback => data.value?.feedback ?? const [];

  // ── Shared date helpers ─────────────────────────────────────────────────────

  static bool inMonth(int? ms, DateTime month) {
    if (ms == null) return false;
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return d.year == month.year && d.month == month.month;
  }

  static bool withinDays(int? ms, int days) {
    if (ms == null) return false;
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return DateTime.fromMillisecondsSinceEpoch(ms).isAfter(cutoff);
  }
}
