import 'owner_insight_item.dart';
import 'branch_health.dart';
import 'monthly_finance_point.dart';

/// Money view for the dashboard's Financial Overview card. Every field is a
/// straight read from [OwnerMetrics] — no recomputation, just a UI-shaped slice.
class FinanceSnapshot {
  final double expectedRevenue;
  final double collected;
  final double outstanding;
  final double expenses;
  final double profit;
  final double collectionRate;
  final double overdueAmount;
  final int overdueInvoices;

  /// Network overhead (expenses with no branch) — shown only at network scope;
  /// 0 when scoped to a single branch.
  final double overhead;

  const FinanceSnapshot({
    this.expectedRevenue = 0,
    this.collected = 0,
    this.outstanding = 0,
    this.expenses = 0,
    this.profit = 0,
    this.collectionRate = 0,
    this.overdueAmount = 0,
    this.overdueInvoices = 0,
    this.overhead = 0,
  });

  int get collectionPercent => (collectionRate * 100).round();

  static const empty = FinanceSnapshot();
}

/// The "how's the business?" headline card. One scope's vital signs at a glance:
/// branches · children · staff · occupancy · revenue · collection rate.
class BusinessSnapshot {
  final int branches;
  final int children;
  final int staff;
  final double occupancyRate;
  final double revenue;
  final double collectionRate;

  const BusinessSnapshot({
    this.branches = 0,
    this.children = 0,
    this.staff = 0,
    this.occupancyRate = 0,
    this.revenue = 0,
    this.collectionRate = 0,
  });

  int get occupancyPercent => (occupancyRate * 100).round();
  int get collectionPercent => (collectionRate * 100).round();

  static const empty = BusinessSnapshot();
}

/// Occupancy + growth view for the Growth Snapshot card.
/// No retention yet — its business definition isn't locked, so V1 shows raw
/// movement (new vs left) instead of a derived rate.
class GrowthSnapshot {
  final int activeChildren;
  final int totalCapacity;
  final int newThisMonth;
  final int leftThisMonth;
  final int waitingList;
  final double occupancyRate;
  final List<ClassroomOccupancyView> classrooms;

  const GrowthSnapshot({
    this.activeChildren = 0,
    this.totalCapacity = 0,
    this.newThisMonth = 0,
    this.leftThisMonth = 0,
    this.waitingList = 0,
    this.occupancyRate = 0,
    this.classrooms = const [],
  });

  int get freeSeats =>
      (totalCapacity - activeChildren) < 0 ? 0 : totalCapacity - activeChildren;
  int get occupancyPercent => (occupancyRate * 100).round();
  int get netGrowth => newThisMonth - leftThisMonth;

  static const empty = GrowthSnapshot();
}

/// A UI-shaped copy of one classroom's occupancy (decoupled from the metrics
/// model so the snapshot layer carries no service dependency).
class ClassroomOccupancyView {
  final String id;
  final String name;
  final int enrolled;
  final int capacity;
  final int fillPercent;

  const ClassroomOccupancyView({
    required this.id,
    required this.name,
    required this.enrolled,
    required this.capacity,
    required this.fillPercent,
  });
}

/// The "good morning" briefing at the very top of the dashboard: a one-line
/// human summary, the few things that need the owner's attention, and the
/// wins worth celebrating. Both lists are subsets of the full insight feed.
class ExecutiveBrief {
  final String summary;
  final List<OwnerInsightItem> priorities;
  final List<OwnerInsightItem> wins;

  const ExecutiveBrief({
    this.summary = '',
    this.priorities = const [],
    this.wins = const [],
  });

  static const empty = ExecutiveBrief();
}

/// THE object the dashboard renders. Assembled once by the OwnerInsightService
/// from a pair of [OwnerMetrics] (current + previous). The UI is a pure
/// function of this — it computes nothing.
///
/// V1 deliberately omits Health Score and Goals — those are opinionated
/// aggregations we add once real usage tells us what owners actually weigh.
class OwnerDashboardData {
  final ExecutiveBrief brief;
  final FinanceSnapshot finance;
  final GrowthSnapshot growth;

  /// Vital signs for the Business Snapshot card.
  final BusinessSnapshot business;

  final List<OwnerInsightItem> insights;

  /// Branches ranked by Branch Health Score (best → worst). Populated at network
  /// scope; a single entry (or empty) when scoped to one branch.
  final List<BranchHealthScore> branchRanking;

  /// True when the dashboard is showing the whole network vs a single branch.
  final bool isNetwork;

  /// Human label for the current scope ("All Branches" / a branch name).
  final String scopeLabel;

  /// Last few months of collected vs expenses (oldest → newest). Feeds the
  /// finance tab's trend chart and monthly history list.
  final List<MonthlyFinancePoint> financeTrend;

  const OwnerDashboardData({
    required this.brief,
    required this.finance,
    required this.growth,
    required this.insights,
    this.business = BusinessSnapshot.empty,
    this.branchRanking = const [],
    this.isNetwork = true,
    this.scopeLabel = '',
    this.financeTrend = const [],
  });

  factory OwnerDashboardData.empty() => const OwnerDashboardData(
        brief: ExecutiveBrief.empty,
        finance: FinanceSnapshot.empty,
        growth: GrowthSnapshot.empty,
        business: BusinessSnapshot.empty,
        insights: [],
        branchRanking: [],
        financeTrend: [],
      );

  /// Problems only (alerts + recommendations), already severity-sorted upstream.
  List<OwnerInsightItem> get problems =>
      insights.where((i) => i.isProblem).toList();

  /// Wins only (achievements + trends).
  List<OwnerInsightItem> get wins => insights.where((i) => i.isWin).toList();

  /// Open actionable items the owner still needs to delegate/track.
  List<OwnerInsightItem> get openInsights =>
      insights.where((i) => i.status == InsightStatus.open).toList();

  int get criticalCount =>
      insights.where((i) => i.severity == InsightSeverity.critical).length;
}
