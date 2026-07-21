import '../../../../../index/index_main.dart';

/// Raw finance data snapshot behind the owner's finance-detail reports
/// (collection-rate, revenue-by-method, revenue-by-category, payment-behavior,
/// forecast). Loaded ONCE and shared, mirroring [OwnerAnalyticsService]'s
/// compute-once philosophy — those reports need row-level invoices/transactions
/// the executive bundle doesn't surface, so they read here instead of
/// re-fetching per report.
class OwnerFinanceData {
  final List<InvoiceModel> invoices;
  final List<FinancialTransactionModel> txns;
  final List<ChildModel> children;
  final List<PackageModel> packages;
  const OwnerFinanceData({
    required this.invoices,
    required this.txns,
    required this.children,
    required this.packages,
  });
}

class OwnerFinanceDataService extends GetxService {
  final Rxn<OwnerFinanceData> data = Rxn<OwnerFinanceData>();
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
        _fetch<InvoiceModel>('invoices'),
        _fetch<FinancialTransactionModel>('financialTransactions'),
        _fetch<ChildModel>('children'),
        _fetch<PackageModel>('packages'),
      ]);
      data.value = OwnerFinanceData(
        invoices: r[0].whereType<InvoiceModel>().toList(),
        txns: r[1].whereType<FinancialTransactionModel>().toList(),
        children: r[2].whereType<ChildModel>().toList(),
        packages: r[3].whereType<PackageModel>().toList(),
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

  /// childId → branchId (invoices/transactions carry no branchId of their own).
  Map<String, String> get _childBranch {
    final d = data.value;
    if (d == null) return const {};
    return {
      for (final ch in d.children)
        if (ch.key != null) ch.key!: ch.branchId,
    };
  }

  /// Invoices belonging to [scope] (branch resolved via the child).
  List<InvoiceModel> invoicesFor(OwnerScope scope) {
    final d = data.value;
    if (d == null) return const [];
    if (scope.isNetwork) return d.invoices;
    final map = _childBranch;
    return d.invoices.where((i) => map[i.childId] == scope.branchId).toList();
  }

  /// Collection transactions for [scope].
  List<FinancialTransactionModel> collectionsFor(OwnerScope scope) {
    final d = data.value;
    if (d == null) return const [];
    return d.txns
        .where((t) =>
            t.type == TransactionType.collection &&
            (scope.isNetwork || t.branchId == scope.branchId))
        .toList();
  }

  /// Active children in [scope].
  List<ChildModel> activeChildrenFor(OwnerScope scope) {
    final d = data.value;
    if (d == null) return const [];
    return d.children
        .where((c) =>
            c.status == 'active' &&
            (scope.isNetwork || c.branchId == scope.branchId))
        .toList();
  }

  Map<String, PackageModel> get packagesById {
    final d = data.value;
    if (d == null) return const {};
    return {
      for (final p in d.packages)
        if (p.key != null) p.key!: p,
    };
  }

  // ── Shared date helpers ─────────────────────────────────────────────────────

  static bool inMonth(int? ms, DateTime month) {
    if (ms == null) return false;
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return d.year == month.year && d.month == month.month;
  }
}
