import '../../../../../index/index_main.dart';
import '../models/owner_metrics.dart';
import '../models/branch_metrics.dart';
import '../models/branch_health.dart';
import '../models/owner_insight_item.dart';
import '../models/owner_dashboard_data.dart';
import 'owner_metrics_service.dart';

/// Pure rules engine: turns a raw [OwnerMetricsBundle] + the current scope +
/// per-branch targets into the display-ready [OwnerDashboardData]. No Firebase,
/// no widgets, no state — same input always gives the same output.
///
/// This is the keystone of the Owner App: dashboards and reports are just Views
/// over the insights and scores this produces.
class OwnerInsightService {
  /// [isNetwork] true = aggregate all branches; otherwise [branchId] selects one.
  /// [targets] maps branchId → its goals/weights (missing → sensible defaults).
  OwnerDashboardData build(
    OwnerMetricsBundle bundle, {
    required bool isNetwork,
    String? branchId,
    required String scopeLabel,
    required Map<String, BranchTargetModel> targets,
  }) {
    // ── Health scores for every branch (always computed; used by ranking) ────
    final healthScores = bundle.branches
        .map((e) => _health(e, targets[e.branchId]))
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    // ── Resolve the active scope's metrics pair ──────────────────────────────
    final BranchMetricsEntry? branchEntry = isNetwork
        ? null
        : bundle.branches.firstWhereOrNull((e) => e.branchId == branchId);
    final cur = branchEntry?.current ?? bundle.network.current;
    final prev = branchEntry?.previous ?? bundle.network.previous;
    final trend = isNetwork
        ? bundle.network.trend
        : (branchEntry != null ? branchEntry.trend : bundle.network.trend);

    // ── Insights ─────────────────────────────────────────────────────────────
    final insights = <OwnerInsightItem>[];
    insights.addAll(_scopeInsights(cur, prev));
    if (isNetwork) {
      insights.addAll(_branchInsights(bundle, healthScores, targets));
    }
    insights.sort((a, b) {
      final r = b.priority.compareTo(a.priority);
      if (r != 0) return r;
      final s = a.severity.sortRank.compareTo(b.severity.sortRank);
      return s != 0 ? s : b.createdAt.compareTo(a.createdAt);
    });

    final ranking = isNetwork
        ? healthScores
        : healthScores.where((h) => h.branchId == branchId).toList();

    final brief = _brief(cur, insights, isNetwork, healthScores);

    return OwnerDashboardData(
      brief: brief,
      finance: _finance(cur, isNetwork ? bundle.overheadCurrent : 0),
      growth: _growth(cur),
      business: _business(bundle, cur, isNetwork),
      insights: insights,
      branchRanking: ranking,
      isNetwork: isNetwork,
      scopeLabel: scopeLabel,
      financeTrend: trend,
    );
  }

  // ── Branch Health Score (explainable) ───────────────────────────────────────
  BranchHealthScore _health(BranchMetricsEntry e, BranchTargetModel? target) {
    final t = target ?? BranchTargetModel.defaults(nurseryId: '', branchId: e.branchId);
    final w = t.weights;
    final m = e.current;

    double comp(double rate, double targetPct, double weight) {
      final tgt = (targetPct / 100).clamp(0.0001, 1.0);
      final ratio = (rate / tgt).clamp(0.0, 1.0);
      return ratio * weight;
    }

    final occ = comp(m.occupancyRate, t.occupancyTarget, w.occupancy);
    final col = comp(m.collectionRate, t.collectionTarget, w.collections);
    final tea = comp(m.teacherActivityRate, t.teacherActivityTarget, w.teacherActivity);

    // Pending-tasks proxy: overdue invoices relative to active children (fewer
    // overdue → more points). Honest stand-in until a real task system exists.
    final pendingRatio = m.activeChildren > 0
        ? (m.overdueInvoices / m.activeChildren).clamp(0.0, 1.0)
        : (m.overdueInvoices > 0 ? 1.0 : 0.0);
    final pen = (1 - pendingRatio) * w.pendingTasks;

    final breakdown = HealthScoreBreakdown(
      occupancy: HealthComponent(
          labelKey: 'owner_health_occupancy', earned: occ, max: w.occupancy),
      collections: HealthComponent(
          labelKey: 'owner_health_collections', earned: col, max: w.collections),
      teacherActivity: HealthComponent(
          labelKey: 'owner_health_teacher', earned: tea, max: w.teacherActivity),
      pendingTasks: HealthComponent(
          labelKey: 'owner_health_pending', earned: pen, max: w.pendingTasks),
    );

    // A branch with no children, no money and no activity isn't "at risk" —
    // there's nothing to measure. Mark it so it's excluded from alerts/summary.
    final hasData =
        m.activeChildren > 0 || m.revenue > 0 || m.collected > 0;

    final score =
        breakdown.max <= 0 ? 0.0 : (breakdown.earned / breakdown.max) * 100;
    return BranchHealthScore(
      branchId: e.branchId,
      branchName: e.branchName,
      score: hasData ? score.toDouble() : 0.0,
      breakdown: breakdown,
      hasData: hasData,
    );
  }

  // ── Scope-level insights (finance / growth, for the active scope) ───────────
  List<OwnerInsightItem> _scopeInsights(OwnerMetrics cur, OwnerMetrics prev) {
    final out = <OwnerInsightItem>[];

    if (cur.overdue60Families > 0) {
      out.add(_item(
        id: 'overdue60',
        type: InsightType.alert,
        severity: InsightSeverity.critical,
        category: InsightCategory.finance,
        priority: 92,
        icon: Icons.warning_amber_rounded,
        role: 'accountant',
        title: 'owner_insight_overdue60_title'
            .trParams({'count': '${cur.overdue60Families}'}),
        impact: 'owner_insight_overdue60_impact'
            .trParams({'amount': formatMoney(cur.overdue60Amount)}),
      ));
    }

    if (cur.overdueInvoices > 0 && cur.overdue60Families == 0) {
      out.add(_item(
        id: 'overdue',
        type: InsightType.alert,
        severity: InsightSeverity.warning,
        category: InsightCategory.finance,
        priority: 64,
        icon: Icons.schedule_rounded,
        role: 'reception',
        title: 'owner_insight_overdue_title'
            .trParams({'count': '${cur.overdueInvoices}'}),
        impact: 'owner_insight_overdue_impact'
            .trParams({'amount': formatMoney(cur.overdueAmount)}),
      ));
    }

    if (cur.profit < 0) {
      out.add(_item(
        id: 'loss',
        type: InsightType.alert,
        severity: InsightSeverity.critical,
        category: InsightCategory.finance,
        priority: 88,
        icon: Icons.trending_down_rounded,
        role: 'manager',
        title: 'owner_insight_loss_title'.tr,
        impact: 'owner_insight_loss_impact'
            .trParams({'amount': formatMoney(cur.profit.abs())}),
      ));
    }

    if (cur.totalCapacity > 0 && cur.occupancyRate > 0.9) {
      out.add(_item(
        id: 'occupancy_high',
        type: InsightType.opportunity,
        severity: InsightSeverity.info,
        category: InsightCategory.growth,
        priority: 46,
        icon: Icons.event_seat_rounded,
        role: 'manager',
        title: 'owner_insight_occupancy_high_title'
            .trParams({'percent': '${(cur.occupancyRate * 100).round()}'}),
        impact: 'owner_insight_occupancy_high_impact'
            .trParams({'seats': '${cur.freeSeats}'}),
      ));
    }

    if (cur.waitingListCount > 0 && cur.freeSeats > 0) {
      out.add(_item(
        id: 'waiting_convert',
        type: InsightType.opportunity,
        severity: InsightSeverity.info,
        category: InsightCategory.growth,
        priority: 50,
        icon: Icons.hourglass_bottom_rounded,
        role: 'reception',
        title: 'owner_insight_waiting_title'
            .trParams({'count': '${cur.waitingListCount}'}),
        impact: 'owner_insight_waiting_impact'
            .trParams({'seats': '${cur.freeSeats}'}),
      ));
    }

    if (cur.newEnrollments > cur.withdrawnChildren) {
      out.add(_item(
        id: 'growth_up',
        type: InsightType.trend,
        severity: InsightSeverity.positive,
        category: InsightCategory.growth,
        priority: 22,
        icon: Icons.trending_up_rounded,
        title: 'owner_insight_growth_title'.trParams({
          'net': '${cur.newEnrollments - cur.withdrawnChildren}',
        }),
        impact: 'owner_insight_growth_impact'.trParams({
          'new': '${cur.newEnrollments}',
          'left': '${cur.withdrawnChildren}',
        }),
      ));
    }

    if (cur.collected > prev.collected && prev.collected > 0) {
      final pct =
          (((cur.collected - prev.collected) / prev.collected) * 100).round();
      out.add(_item(
        id: 'collection_up',
        type: InsightType.trend,
        severity: InsightSeverity.positive,
        category: InsightCategory.finance,
        priority: 20,
        icon: Icons.show_chart_rounded,
        title: 'owner_insight_collection_up_title'.trParams({'percent': '$pct'}),
        impact: 'owner_insight_collection_up_impact'
            .trParams({'amount': formatMoney(cur.collected)}),
      ));
    }

    if (cur.revenue > 0 && cur.collectionRate >= 0.9) {
      out.add(_item(
        id: 'collection_great',
        type: InsightType.achievement,
        severity: InsightSeverity.positive,
        category: InsightCategory.finance,
        priority: 18,
        icon: Icons.verified_rounded,
        title: 'owner_insight_collection_great_title'
            .trParams({'percent': '${(cur.collectionRate * 100).round()}'}),
        impact: 'owner_insight_collection_great_impact'
            .trParams({'amount': formatMoney(cur.collected)}),
      ));
    }

    return out;
  }

  // ── Branch-level insights (network scope only) ──────────────────────────────
  List<OwnerInsightItem> _branchInsights(
    OwnerMetricsBundle bundle,
    List<BranchHealthScore> health,
    Map<String, BranchTargetModel> targets,
  ) {
    final out = <OwnerInsightItem>[];
    final byId = {for (final e in bundle.branches) e.branchId: e};

    for (final h in health) {
      final e = byId[h.branchId];
      if (e == null) continue;
      final cur = e.current;
      final prev = e.previous;
      final t = targets[h.branchId] ??
          BranchTargetModel.defaults(branchId: h.branchId);

      // 1) Unhealthy branch — surface with its weakest component. Skipped for
      // no-data branches: an empty branch is "waiting for data", not failing.
      if (h.hasData && h.score < 60) {
        final weakest = h.breakdown.components
            .reduce((a, b) => a.fill <= b.fill ? a : b);
        out.add(_item(
          id: 'health_${h.branchId}',
          type: InsightType.alert,
          severity:
              h.score < 45 ? InsightSeverity.critical : InsightSeverity.warning,
          category: InsightCategory.operations,
          priority: (95 - h.score).clamp(50, 95).round(),
          icon: Icons.health_and_safety_rounded,
          role: 'manager',
          branchName: h.branchName,
          title: 'owner_insight_branch_health_title'.trParams({
            'branch': h.branchName,
            'score': '${h.scoreRounded}',
          }),
          impact: 'owner_insight_branch_health_impact'
              .trParams({'area': weakest.labelKey.tr}),
        ));
      }

      // 2) Occupancy dropped vs last month — quantify the revenue at risk.
      final lostSeats = prev.activeChildren - cur.activeChildren;
      if (lostSeats > 0 && prev.activeChildren > 0) {
        final avgFee =
            cur.activeChildren > 0 ? cur.revenue / cur.activeChildren : 0;
        final impact = lostSeats * avgFee;
        if (impact > 0) {
          out.add(_item(
            id: 'occ_drop_${h.branchId}',
            type: InsightType.alert,
            severity: InsightSeverity.warning,
            category: InsightCategory.growth,
            priority: 70,
            icon: Icons.south_east_rounded,
            role: 'manager',
            branchName: h.branchName,
            title: 'owner_insight_occ_drop_title'.trParams({
              'branch': h.branchName,
              'from': '${(prev.occupancyRate * 100).round()}',
              'to': '${(cur.occupancyRate * 100).round()}',
            }),
            impact: 'owner_insight_occ_drop_impact'
                .trParams({'amount': formatMoney(impact)}),
          ));
        }
      }

      // 3) Teachers not posting — education/staff signal.
      if (cur.classrooms.isNotEmpty &&
          cur.teacherActivityRate < (t.teacherActivityTarget / 100) * 0.7) {
        out.add(_item(
          id: 'teacher_idle_${h.branchId}',
          type: InsightType.alert,
          severity: InsightSeverity.warning,
          category: InsightCategory.education,
          priority: 58,
          icon: Icons.menu_book_rounded,
          role: 'manager',
          branchName: h.branchName,
          title: 'owner_insight_teacher_idle_title'
              .trParams({'branch': h.branchName}),
          impact: 'owner_insight_teacher_idle_impact'.trParams({
            'active': '${cur.classroomsWithRecentActivity}',
            'total': '${cur.classrooms.length}',
          }),
        ));
      }
    }
    return out;
  }

  // ── Snapshots ───────────────────────────────────────────────────────────────
  FinanceSnapshot _finance(OwnerMetrics m, double overhead) => FinanceSnapshot(
        expectedRevenue: m.revenue,
        collected: m.collected,
        outstanding: m.outstanding,
        expenses: m.expenses,
        profit: m.profit,
        collectionRate: m.collectionRate,
        overdueAmount: m.overdueAmount,
        overdueInvoices: m.overdueInvoices,
        overhead: overhead,
      );

  GrowthSnapshot _growth(OwnerMetrics m) => GrowthSnapshot(
        activeChildren: m.activeChildren,
        totalCapacity: m.totalCapacity,
        newThisMonth: m.newEnrollments,
        leftThisMonth: m.withdrawnChildren,
        waitingList: m.waitingListCount,
        occupancyRate: m.occupancyRate,
        classrooms: m.classrooms
            .map((c) => ClassroomOccupancyView(
                  id: c.id,
                  name: c.name,
                  enrolled: c.enrolled,
                  capacity: c.capacity,
                  fillPercent: c.fillPercent,
                ))
            .toList(),
      );

  BusinessSnapshot _business(
          OwnerMetricsBundle bundle, OwnerMetrics m, bool isNetwork) =>
      BusinessSnapshot(
        branches: isNetwork ? bundle.branches.length : 1,
        children: m.activeChildren,
        staff: m.staffCount,
        occupancyRate: m.occupancyRate,
        revenue: m.revenue,
        collectionRate: m.collectionRate,
      );

  // ── Daily brief (20-second summary) ─────────────────────────────────────────
  ExecutiveBrief _brief(
    OwnerMetrics m,
    List<OwnerInsightItem> insights,
    bool isNetwork,
    List<BranchHealthScore> health,
  ) {
    final priorities = insights.where((i) => i.isProblem).take(3).toList();
    final wins = insights.where((i) => i.isWin).take(2).toList();

    // Only branches with real data count toward the network summary — empty
    // branches are neither "normal" nor "below target", just unmeasured.
    final measured = health.where((h) => h.hasData).toList();

    final String summary;
    if (isNetwork && measured.isNotEmpty) {
      final belowTarget = measured.where((h) => h.score < 60).length;
      final normal = measured.length - belowTarget;
      summary = 'owner_brief_network_summary'.trParams({
        'normal': '$normal',
        'below': '$belowTarget',
        'overdue': formatMoney(m.overdueAmount),
      });
    } else {
      summary = 'owner_brief_summary'.trParams({
        'active': '${m.activeChildren}',
        'collected': formatMoney(m.collected),
        'open': '${priorities.length}',
      });
    }

    return ExecutiveBrief(summary: summary, priorities: priorities, wins: wins);
  }

  // ── Helper ───────────────────────────────────────────────────────────────────
  OwnerInsightItem _item({
    required String id,
    required InsightType type,
    required InsightSeverity severity,
    required String title,
    required String impact,
    required IconData icon,
    InsightCategory category = InsightCategory.operations,
    int priority = 0,
    String? role,
    String? branchName,
  }) {
    final actionable = type == InsightType.alert ||
        type == InsightType.opportunity ||
        type == InsightType.recommendation;
    return OwnerInsightItem(
      id: id,
      type: type,
      severity: severity,
      category: category,
      priority: priority,
      title: title,
      impact: impact,
      icon: icon,
      responsibleRole: role,
      branchName: branchName,
      status: actionable ? InsightStatus.open : null,
    );
  }
}
