import '../../../../../index/index_main.dart';
import '../models/owner_metrics.dart';
import '../models/branch_metrics.dart';
import '../models/monthly_finance_point.dart';
import 'owner_metrics_service.dart';

/// Local persistence for the raw [OwnerMetricsBundle]. We cache the SOURCE
/// numbers (not the derived dashboard) so the owner sees last-known figures
/// instantly on open, and so changing an insight rule never serves stale
/// insights — they're recomputed from these raw metrics every time.
class OwnerMetricsCache {
  static const _key = 'owner_metrics_cache_v3';

  final StorageService _storage = StorageService();

  /// Last cached bundle, or null if nothing is stored / it's unreadable.
  OwnerMetricsBundle? read() {
    final raw = _storage.getData(_key);
    if (raw == null) return null;
    try {
      final net = (raw['network'] as Map).cast<String, dynamic>();
      final branchesRaw = (raw['branches'] as List?) ?? const [];
      return (
        network: _pairFromJson(net),
        branches: branchesRaw
            .map((e) =>
                BranchMetricsEntry.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        overheadCurrent: (raw['overheadCurrent'] as num?)?.toDouble() ?? 0,
        overheadPrevious: (raw['overheadPrevious'] as num?)?.toDouble() ?? 0,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> write(OwnerMetricsBundle bundle) => _storage.setData(_key, {
        'cachedAt': DateTime.now().millisecondsSinceEpoch,
        'network': _pairToJson(bundle.network),
        'branches': bundle.branches.map((e) => e.toJson()).toList(),
        'overheadCurrent': bundle.overheadCurrent,
        'overheadPrevious': bundle.overheadPrevious,
      });

  Map<String, dynamic> _pairToJson(OwnerMetricsPair p) => {
        'current': p.current.toJson(),
        'previous': p.previous.toJson(),
        'trend': p.trend.map((e) => e.toJson()).toList(),
      };

  OwnerMetricsPair _pairFromJson(Map<String, dynamic> j) {
    final trendRaw = (j['trend'] as List?) ?? const [];
    return (
      current: OwnerMetrics.fromJson((j['current'] as Map).cast<String, dynamic>()),
      previous: OwnerMetrics.fromJson((j['previous'] as Map).cast<String, dynamic>()),
      trend: trendRaw
          .map((e) =>
              MonthlyFinancePoint.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }
}
