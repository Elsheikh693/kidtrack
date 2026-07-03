import 'package:firebase_database/firebase_database.dart';
import '../../../../../index/index_main.dart';
import '../models/owner_metrics.dart';
import '../models/branch_metrics.dart';
import '../models/monthly_finance_point.dart';

/// A current + previous month pair of metrics, plus a short monthly trend.
/// The InsightService diffs the pair to derive deltas and folds the trend into
/// the dashboard data; the UI never sees this directly.
typedef OwnerMetricsPair = ({
  OwnerMetrics current,
  OwnerMetrics previous,
  List<MonthlyFinancePoint> trend,
});

/// The full computed picture, built ONCE per refresh from a single raw fetch:
///   • [network]  — every branch aggregated (expenses include overhead)
///   • [branches] — one [BranchMetricsEntry] per active branch (DIRECT costs only)
///   • overhead   — network-level expenses (expense.branchId == null) this/last month
///
/// The scope switcher just picks which slice to render — no extra fetch needed.
typedef OwnerMetricsBundle = ({
  OwnerMetricsPair network,
  List<BranchMetricsEntry> branches,
  double overheadCurrent,
  double overheadPrevious,
});

/// How many months of history the finance trend chart / history list show.
const int kFinanceTrendMonths = 12;

/// How recent a classroom activity must be to count toward teacher-activity
/// health (the "are teachers still posting?" signal).
const int kTeacherActivityWindowDays = 7;

/// Loads every raw collection ONCE from Firebase and folds it into a branch-aware
/// [OwnerMetricsBundle]. This is the ONLY place numbers are computed —
/// everything downstream just reads the result.
///
/// Per-branch joins: children / classrooms / enrollments / waitingList carry
/// `branchId` directly; invoices & payments do NOT, so they're attributed via a
/// `childId → child.branchId` lookup (compute only, no schema change).
class OwnerMetricsService {
  Future<OwnerMetricsBundle> loadBundle() async {
    final invoicesF = _fetch<InvoiceModel>('invoices');
    final paymentsF = _fetch<PaymentModel>('payments');
    final expensesF = _fetch<ExpenseModel>('expenses');
    final classroomsF = _fetch<ClassroomModel>('classrooms');
    final childrenF = _fetch<ChildModel>('children');
    final enrollmentsF = _fetch<EnrollmentModel>('enrollments');
    final waitingF = _fetch<WaitingListModel>('waitingList');
    final branchesF = _fetch<BranchModel>('branches');
    final staffF = _fetch<StaffModel>('staff');
    final recentActivityF = _recentActivityClassroomIds();

    await Future.wait([
      invoicesF, paymentsF, expensesF, classroomsF, childrenF,
      enrollmentsF, waitingF, branchesF, staffF, recentActivityF,
    ]);

    final invoices = await invoicesF;
    final payments = await paymentsF;
    final expenses = await expensesF;
    final classrooms = await classroomsF;
    final children = await childrenF;
    final enrollments = await enrollmentsF;
    final waiting = await waitingF;
    final branches = (await branchesF).where((b) => b.isActive).toList();
    final staff = (await staffF)
        .where((s) => s.isActive && s.role != UserType.owner)
        .toList();
    final recentActivity = await recentActivityF;

    final now = DateTime.now();

    // childId → branchId, so invoices/payments (which lack branchId) can be
    // attributed to a branch.
    final childBranch = <String, String>{
      for (final c in children)
        if (c.key != null) c.key!: c.branchId,
    };

    // ── Network (all branches aggregated; expenses include overhead) ─────────
    final network = _computePair(
      now: now,
      invoices: invoices,
      payments: payments,
      expenses: expenses,
      classrooms: classrooms,
      children: children,
      enrollments: enrollments,
      waiting: waiting,
      staffCount: staff.length,
      recentActivityClassroomIds: recentActivity,
    );

    // ── Per-branch (DIRECT costs only) ───────────────────────────────────────
    final branchEntries = <BranchMetricsEntry>[];
    for (final b in branches) {
      final id = b.key;
      if (id == null) continue;
      final pair = _computePair(
        now: now,
        invoices: invoices.where((i) => childBranch[i.childId] == id).toList(),
        payments: payments.where((p) => childBranch[p.childId] == id).toList(),
        expenses: expenses.where((e) => e.branchId == id).toList(),
        classrooms: classrooms.where((c) => c.isAllBranches || c.branchIds.contains(id)).toList(),
        children: children.where((c) => c.branchId == id).toList(),
        enrollments: enrollments.where((e) => e.branchId == id).toList(),
        waiting: waiting.where((w) => w.branchId == id).toList(),
        staffCount: staff.where((s) => s.branchId == id).length,
        recentActivityClassroomIds: recentActivity,
      );
      branchEntries.add(BranchMetricsEntry(
        branchId: id,
        branchName: b.name,
        current: pair.current,
        previous: pair.previous,
        trend: pair.trend,
      ));
    }

    // ── Network overhead (expense.branchId == null) per month ────────────────
    final curMonth = DateTime(now.year, now.month);
    final prevMonth = DateTime(now.year, now.month - 1);
    final overhead = expenses.where((e) => e.branchId == null);
    double overheadIn(DateTime m) => overhead
        .where((e) => _inMonth(e.dueDate ?? e.createdAt, m))
        .fold(0.0, (s, e) => s + e.amount);

    return (
      network: network,
      branches: branchEntries,
      overheadCurrent: overheadIn(curMonth),
      overheadPrevious: overheadIn(prevMonth),
    );
  }

  // ── The single compute: filtered raw lists → a current+previous pair ────────
  OwnerMetricsPair _computePair({
    required DateTime now,
    required List<InvoiceModel> invoices,
    required List<PaymentModel> payments,
    required List<ExpenseModel> expenses,
    required List<ClassroomModel> classrooms,
    required List<ChildModel> children,
    required List<EnrollmentModel> enrollments,
    required List<WaitingListModel> waiting,
    required int staffCount,
    required Set<String> recentActivityClassroomIds,
  }) {
    final curMonth = DateTime(now.year, now.month);
    final prevMonth = DateTime(now.year, now.month - 1);
    final today = DateTime(now.year, now.month, now.day);

    // ── Current-state finance (accounts receivable "as of now") ──────────────
    bool unpaid(InvoiceModel i) => i.status == 'pending' || i.status == 'overdue';
    final outstanding = invoices.where(unpaid).fold(0.0, (s, i) => s + i.totalAmount);

    bool overdueNow(InvoiceModel i) =>
        unpaid(i) &&
        i.dueDate != null &&
        DateTime.fromMillisecondsSinceEpoch(i.dueDate!).isBefore(today);
    final overdueList = invoices.where(overdueNow).toList();
    final overdueAmount = overdueList.fold(0.0, (s, i) => s + i.totalAmount);

    final cutoff60 = today.subtract(const Duration(days: 60));
    final over60 = overdueList
        .where((i) =>
            DateTime.fromMillisecondsSinceEpoch(i.dueDate!).isBefore(cutoff60))
        .toList();
    final overdue60Families = over60.map((i) => i.childId).toSet().length;
    final overdue60Amount = over60.fold(0.0, (s, i) => s + i.totalAmount);

    // ── Current-state occupancy ──────────────────────────────────────────────
    final activeChildrenNow = children.where((c) => c.status == 'active').length;
    final activeRooms = classrooms.where((c) => c.isActive).toList();
    final totalCapacity = activeRooms.fold(0, (s, c) => s + (c.capacity ?? 0));
    final waitingListCount = waiting.where((w) => w.status == 'pending').length;

    final classroomsWithRecentActivity = activeRooms
        .where((c) => recentActivityClassroomIds.contains(c.key))
        .length;

    int enrolledIn(String? roomId) => enrollments
        .where((e) => e.classroomId == roomId && e.status == 'enrolled')
        .length;
    final classroomOcc = activeRooms
        .map((c) => ClassroomOccupancy(
              id: c.key ?? '',
              name: c.name,
              enrolled: enrolledIn(c.key),
              capacity: c.capacity ?? 0,
            ))
        .toList();

    // ── Per-period flows ─────────────────────────────────────────────────────
    double billedIn(DateTime m) => invoices
        .where((i) => _inMonth(i.createdAt, m))
        .fold(0.0, (s, i) => s + i.totalAmount);
    double collectedIn(DateTime m) =>
        payments.where((p) => _inMonth(p.paidAt, m)).fold(0.0, (s, p) => s + p.amount);
    double expensesIn(DateTime m) => expenses
        .where((e) => _inMonth(e.dueDate ?? e.createdAt, m))
        .fold(0.0, (s, e) => s + e.amount);
    int newIn(DateTime m) => enrollments
        .where((e) => e.status == 'enrolled' && _inMonth(e.enrollmentDate ?? e.startDate, m))
        .length;
    int withdrawnIn(DateTime m) => enrollments
        .where((e) => e.status == 'withdrawn' && _inMonth(e.endDate ?? e.updatedAt, m))
        .length;

    // Reconstruct last month's active count (no history table yet).
    final prevActive =
        (activeChildrenNow - newIn(curMonth) + withdrawnIn(curMonth))
            .clamp(0, 1 << 30);

    OwnerMetrics build(DateTime m, int activeChildren) => OwnerMetrics(
          period: MetricsPeriod.month(m),
          revenue: billedIn(m),
          collected: collectedIn(m),
          expenses: expensesIn(m),
          outstanding: outstanding,
          overdueInvoices: overdueList.length,
          overdueAmount: overdueAmount,
          overdue60Families: overdue60Families,
          overdue60Amount: overdue60Amount,
          activeChildren: activeChildren,
          totalCapacity: totalCapacity,
          newEnrollments: newIn(m),
          withdrawnChildren: withdrawnIn(m),
          waitingListCount: waitingListCount,
          classrooms: classroomOcc,
          staffCount: staffCount,
          classroomsWithRecentActivity: classroomsWithRecentActivity,
        );

    final trend = List<MonthlyFinancePoint>.generate(kFinanceTrendMonths, (i) {
      final m = DateTime(now.year, now.month - (kFinanceTrendMonths - 1 - i));
      return MonthlyFinancePoint(
        year: m.year,
        month: m.month,
        revenue: billedIn(m),
        collected: collectedIn(m),
        expenses: expensesIn(m),
      );
    });

    return (
      current: build(curMonth, activeChildrenNow),
      previous: build(prevMonth, prevActive),
      trend: trend,
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Future<List<T>> _fetch<T>(String tag) {
    final completer = Completer<List<T>>();
    Get.find<BaseService<T>>(tag: tag).getData(
      data: {},
      voidCallBack: (list) {
        if (!completer.isCompleted) {
          completer.complete(list.whereType<T>().toList());
        }
      },
    );
    return completer.future;
  }

  /// Reads the nested `classroomActivities` subtree once and returns the set of
  /// classroomIds that have at least one activity started within the recent
  /// window. Structure: `{ classroomId: { activityId: { startedAt, ... } } }`.
  Future<Set<String>> _recentActivityClassroomIds() async {
    final result = <String>{};
    try {
      final snap =
          await FirebaseDatabase.instance.ref(ApiConstants.classroomActivities).get();
      final raw = snap.value;
      if (raw is! Map) return result;

      final cutoff = DateTime.now()
          .subtract(const Duration(days: kTeacherActivityWindowDays))
          .millisecondsSinceEpoch;

      raw.forEach((classroomId, activities) {
        if (activities is! Map) return;
        final hasRecent = activities.values.any((a) {
          if (a is! Map) return false;
          final started = a['startedAt'] ?? a['createdAt'];
          final ms = started is int
              ? started
              : int.tryParse(started?.toString() ?? '');
          return ms != null && ms >= cutoff;
        });
        if (hasRecent) result.add(classroomId.toString());
      });
    } catch (_) {}
    return result;
  }

  bool _inMonth(int? ms, DateTime month) {
    if (ms == null) return false;
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return d.year == month.year && d.month == month.month;
  }
}
