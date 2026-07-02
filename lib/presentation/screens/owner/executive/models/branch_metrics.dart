import 'owner_metrics.dart';
import 'monthly_finance_point.dart';

/// One branch's metrics: a current + previous [OwnerMetrics] pair plus its own
/// monthly finance trend, carrying the branch identity so the Branch Health
/// Ranking can rank, the scope switcher can drill in, and the finance tab can
/// show per-branch monthly history. `current.expenses` here is the branch's
/// DIRECT cost only (network overhead is held separately on [OwnerMetricsBundle]).
class BranchMetricsEntry {
  final String branchId;
  final String branchName;
  final OwnerMetrics current;
  final OwnerMetrics previous;

  /// This branch's own monthly finance history (oldest → newest).
  final List<MonthlyFinancePoint> trend;

  const BranchMetricsEntry({
    required this.branchId,
    required this.branchName,
    required this.current,
    required this.previous,
    this.trend = const [],
  });

  /// Branch Direct Profit = collected this period − branch-direct expenses.
  double get directProfit => current.collected - current.expenses;

  Map<String, dynamic> toJson() => {
        'branchId': branchId,
        'branchName': branchName,
        'current': current.toJson(),
        'previous': previous.toJson(),
        'trend': trend.map((e) => e.toJson()).toList(),
      };

  factory BranchMetricsEntry.fromJson(Map<String, dynamic> j) =>
      BranchMetricsEntry(
        branchId: (j['branchId'] ?? '') as String,
        branchName: (j['branchName'] ?? '') as String,
        current:
            OwnerMetrics.fromJson((j['current'] as Map).cast<String, dynamic>()),
        previous: OwnerMetrics.fromJson(
            (j['previous'] as Map).cast<String, dynamic>()),
        trend: ((j['trend'] as List?) ?? const [])
            .map((e) =>
                MonthlyFinancePoint.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );
}
