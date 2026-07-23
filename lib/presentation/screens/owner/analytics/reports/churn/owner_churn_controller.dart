import '../../../../../../index/index_main.dart';

/// One withdrawal reason grouped with its count — a tiny value type so the view
/// can render a ranked reason breakdown without re-grouping.
class ChurnReasonCount {
  final String label;
  final int count;
  const ChurnReasonCount(this.label, this.count);
}

/// Withdrawals & Churn report — this month's departures for the current scope,
/// grouped by exit reason, plus the surviving withdrawal log entries. Reads the
/// shared service's reactive withdrawal list (loaded once); nothing re-fetches.
class OwnerChurnController extends GetxController {
  late final OwnerAnalyticsService _analytics;
  late final OwnerScopeService _scope;

  @override
  void onInit() {
    super.onInit();
    _analytics = Get.find<OwnerAnalyticsService>();
    _scope = Get.find<OwnerScopeService>();
    _analytics.ensureLoaded();
  }

  RxBool get firstLoading => _analytics.isFirstLoading;
  Future<void> reload() => _analytics.refresh();

  List<WithdrawalLogModel> get withdrawals =>
      _analytics.withdrawalsFor(_scope.scope.value);

  int get total => withdrawals.length;

  /// Reasons ranked by frequency; blank reasons fold into an "unspecified" row.
  List<ChurnReasonCount> get reasons {
    final counts = <String, int>{};
    for (final w in withdrawals) {
      final label = w.hasReason ? w.reasonLabel : 'owner_report_churn_unknown'.tr;
      counts[label] = (counts[label] ?? 0) + 1;
    }
    final list = counts.entries
        .map((e) => ChurnReasonCount(e.key, e.value))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    return list;
  }
}
