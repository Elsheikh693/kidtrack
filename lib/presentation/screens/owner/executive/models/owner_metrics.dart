/// The granularity a metrics snapshot covers. Lets the InsightService phrase
/// itself ("this month" vs "this quarter") and lets callers ask for a range
/// without re-deriving it from raw dates.
enum MetricsPeriodType { day, week, month, quarter, year }

/// The time window an [OwnerMetrics] snapshot was computed over. Carries its
/// own [type] so downstream code never has to guess the granularity from the
/// start/end span.
class MetricsPeriod {
  final DateTime start;
  final DateTime end;
  final MetricsPeriodType type;

  const MetricsPeriod({
    required this.start,
    required this.end,
    required this.type,
  });

  /// The calendar month that contains [anchor].
  factory MetricsPeriod.month(DateTime anchor) {
    final start = DateTime(anchor.year, anchor.month);
    final end = DateTime(anchor.year, anchor.month + 1)
        .subtract(const Duration(milliseconds: 1));
    return MetricsPeriod(start: start, end: end, type: MetricsPeriodType.month);
  }

  Map<String, dynamic> toJson() => {
        'start': start.millisecondsSinceEpoch,
        'end': end.millisecondsSinceEpoch,
        'type': type.name,
      };

  factory MetricsPeriod.fromJson(Map<String, dynamic> j) => MetricsPeriod(
        start: DateTime.fromMillisecondsSinceEpoch((j['start'] as num).toInt()),
        end: DateTime.fromMillisecondsSinceEpoch((j['end'] as num).toInt()),
        type: MetricsPeriodType.values.firstWhere(
          (t) => t.name == j['type'],
          orElse: () => MetricsPeriodType.month,
        ),
      );
}

/// Occupancy of a single classroom — a metric, computed once.
class ClassroomOccupancy {
  final String id;
  final String name;
  final int enrolled;
  final int capacity;

  const ClassroomOccupancy({
    required this.id,
    required this.name,
    required this.enrolled,
    required this.capacity,
  });

  double get fillRate =>
      capacity > 0 ? (enrolled / capacity).clamp(0, 1).toDouble() : 0;
  int get free => (capacity - enrolled) < 0 ? 0 : capacity - enrolled;
  int get fillPercent => (fillRate * 100).round();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'enrolled': enrolled,
        'capacity': capacity,
      };

  factory ClassroomOccupancy.fromJson(Map<String, dynamic> j) =>
      ClassroomOccupancy(
        id: (j['id'] ?? '') as String,
        name: (j['name'] ?? '') as String,
        enrolled: (j['enrolled'] as num?)?.toInt() ?? 0,
        capacity: (j['capacity'] as num?)?.toInt() ?? 0,
      );
}

/// THE single source of truth for all owner-facing numbers, for one period.
///
/// 100% RAW. It holds counts, sums, and same-snapshot ratios only — no
/// judgement, no health score, no insights, no goals, and no CROSS-period
/// comparison (growth/trend/retention live in the InsightService). The test:
/// this could feed a completely different dashboard without changing a line.
///
/// Compute two instances (current + previous period) and let the InsightService
/// diff them to derive trends, deltas, and retention.
class OwnerMetrics {
  /// The window this snapshot covers (start, end, granularity).
  final MetricsPeriod period;

  // ── Finance (within the period) ──────────────────────────────────────────
  final double revenue; // billed this period
  final double collected; // received this period
  final double expenses; // expenses this period

  // ── Finance (current accounts-receivable state) ──────────────────────────
  final double outstanding; // unpaid pending + overdue invoices (total)
  final int overdueInvoices;
  final double overdueAmount;
  final int overdue60Families; // distinct children unpaid > 60 days
  final double overdue60Amount;

  // ── Occupancy / growth (raw counts only) ─────────────────────────────────
  final int activeChildren;
  final int totalCapacity;
  final int newEnrollments; // within the period
  final int withdrawnChildren; // within the period
  final int waitingListCount;
  final List<ClassroomOccupancy> classrooms;

  /// Active staff in scope (for the Business Snapshot).
  final int staffCount;

  // ── Teacher activity (raw — for the Branch Health Score) ──────────────────
  /// Active classrooms that posted at least one activity in the last 7 days.
  /// Paired with [classrooms].length it yields the teacher-activity rate.
  final int classroomsWithRecentActivity;

  const OwnerMetrics({
    required this.period,
    this.revenue = 0,
    this.collected = 0,
    this.expenses = 0,
    this.outstanding = 0,
    this.overdueInvoices = 0,
    this.overdueAmount = 0,
    this.overdue60Families = 0,
    this.overdue60Amount = 0,
    this.activeChildren = 0,
    this.totalCapacity = 0,
    this.newEnrollments = 0,
    this.withdrawnChildren = 0,
    this.waitingListCount = 0,
    this.classrooms = const [],
    this.staffCount = 0,
    this.classroomsWithRecentActivity = 0,
  });

  // ── Derived (same-snapshot only) ─────────────────────────────────────────
  double get profit => collected - expenses;

  double get collectionRate =>
      revenue > 0 ? (collected / revenue).clamp(0, 1).toDouble() : 0;

  double get occupancyRate => totalCapacity > 0
      ? (activeChildren / totalCapacity).clamp(0, 1).toDouble()
      : 0;

  int get freeSeats =>
      (totalCapacity - activeChildren) < 0 ? 0 : totalCapacity - activeChildren;

  /// 0..1 share of active classrooms that posted activities in the last 7 days.
  double get teacherActivityRate => classrooms.isEmpty
      ? 0
      : (classroomsWithRecentActivity / classrooms.length).clamp(0, 1).toDouble();

  Map<String, dynamic> toJson() => {
        'period': period.toJson(),
        'revenue': revenue,
        'collected': collected,
        'expenses': expenses,
        'outstanding': outstanding,
        'overdueInvoices': overdueInvoices,
        'overdueAmount': overdueAmount,
        'overdue60Families': overdue60Families,
        'overdue60Amount': overdue60Amount,
        'activeChildren': activeChildren,
        'totalCapacity': totalCapacity,
        'newEnrollments': newEnrollments,
        'withdrawnChildren': withdrawnChildren,
        'waitingListCount': waitingListCount,
        'classrooms': classrooms.map((c) => c.toJson()).toList(),
        'staffCount': staffCount,
        'classroomsWithRecentActivity': classroomsWithRecentActivity,
      };

  factory OwnerMetrics.fromJson(Map<String, dynamic> j) => OwnerMetrics(
        period: MetricsPeriod.fromJson(
          (j['period'] as Map).cast<String, dynamic>(),
        ),
        revenue: (j['revenue'] as num?)?.toDouble() ?? 0,
        collected: (j['collected'] as num?)?.toDouble() ?? 0,
        expenses: (j['expenses'] as num?)?.toDouble() ?? 0,
        outstanding: (j['outstanding'] as num?)?.toDouble() ?? 0,
        overdueInvoices: (j['overdueInvoices'] as num?)?.toInt() ?? 0,
        overdueAmount: (j['overdueAmount'] as num?)?.toDouble() ?? 0,
        overdue60Families: (j['overdue60Families'] as num?)?.toInt() ?? 0,
        overdue60Amount: (j['overdue60Amount'] as num?)?.toDouble() ?? 0,
        activeChildren: (j['activeChildren'] as num?)?.toInt() ?? 0,
        totalCapacity: (j['totalCapacity'] as num?)?.toInt() ?? 0,
        newEnrollments: (j['newEnrollments'] as num?)?.toInt() ?? 0,
        withdrawnChildren: (j['withdrawnChildren'] as num?)?.toInt() ?? 0,
        waitingListCount: (j['waitingListCount'] as num?)?.toInt() ?? 0,
        classrooms: ((j['classrooms'] as List?) ?? const [])
            .map((c) =>
                ClassroomOccupancy.fromJson((c as Map).cast<String, dynamic>()))
            .toList(),
        staffCount: (j['staffCount'] as num?)?.toInt() ?? 0,
        classroomsWithRecentActivity:
            (j['classroomsWithRecentActivity'] as num?)?.toInt() ?? 0,
      );
}
