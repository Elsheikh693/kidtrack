import '../../../index/index_main.dart';

/// Drives the shared owner/manager finance dashboard. ONE controller class, two
/// scopes: an owner sees the whole network (and can drill into a branch via
/// [OwnerScopeService]); a manager is pinned to their own branch. The screen is
/// identical — only [scopeBranchId] differs.
///
/// It OWNS the cache. Transactions + expenses are downloaded once into
/// [_txCache] / [_expenseCache]; changing the month or (for the owner) the
/// branch scope only re-runs the pure [FinanceAnalyticsService] over that cache
/// — no repeated Firebase reads. Every transaction is already denormalized
/// (childName/categoryName/collectedByName + branchId) so nothing here joins.
class FinanceDashboardController extends GetxController {
  FinanceDashboardController({required this.isOwner});

  /// true → owner (network-wide cache, scope via [OwnerScopeService]);
  /// false → manager (pinned to their branch).
  final bool isOwner;

  final _analytics = Get.find<FinanceAnalyticsService>();
  final _txService = Get.find<FinancialTransactionParentService>();
  final _expenseService = Get.find<ExpenseParentService>();
  final _session = SessionService();

  // ─── Cache (downloaded once) ────────────────────────────────────────────────
  final _txCache = <FinancialTransactionModel>[];
  final _expenseCache = <ExpenseModel>[];

  // ─── Month state (first day of the month in view) ───────────────────────────
  final Rx<DateTime> anchorMonth =
      DateTime(DateTime.now().year, DateTime.now().month).obs;

  // ─── Reactive report outputs ────────────────────────────────────────────────
  final Rx<FinanceSummary> summary = const FinanceSummary().obs;
  final RxList<CategoryRevenue> categories = <CategoryRevenue>[].obs;
  final RxList<CategoryRevenue> expenseCategories = <CategoryRevenue>[].obs;
  final RxList<RecentCollection> recentCollections = <RecentCollection>[].obs;
  final RxList<RecentExpense> recentExpenses = <RecentExpense>[].obs;

  // ─── "عرض الكل" category filters (null = all). Reset on month/scope change. ──
  final RxnString collectionCategoryFilter = RxnString();
  final RxnString expenseCategoryFilter = RxnString();

  final RxBool isLoading = true.obs;

  /// Bumped on every recompute so pushed full-list screens (which read the cache
  /// directly) can rebuild after a refresh, month/scope change, or expense edit.
  final RxInt revision = 0.obs;

  Worker? _scopeWorker;

  @override
  void onInit() {
    super.onInit();
    if (isOwner) {
      // Owner scope change (network ⇄ branch) re-computes from the SAME cache.
      _scopeWorker = ever(Get.find<OwnerScopeService>().scope, (_) => _recompute());
    }
    reload();
  }

  @override
  void onClose() {
    _scopeWorker?.dispose();
    super.onClose();
  }

  /// The branch the numbers are scoped to. `null` = whole network (owner only).
  String? get scopeBranchId => isOwner
      ? Get.find<OwnerScopeService>().scope.value.branchId
      : _session.branchId;

  // ─── Month window (ms, inclusive start / exclusive end) ─────────────────────
  int get _startMs => anchorMonth.value.millisecondsSinceEpoch;
  int get _endMs =>
      DateTime(anchorMonth.value.year, anchorMonth.value.month + 1, 1)
          .millisecondsSinceEpoch;

  String get monthLabel => arabicMonthYear(anchorMonth.value);

  bool get canGoForward {
    final now = DateTime(DateTime.now().year, DateTime.now().month);
    return anchorMonth.value.isBefore(now);
  }

  void previousMonth() {
    anchorMonth.value =
        DateTime(anchorMonth.value.year, anchorMonth.value.month - 1);
    _recompute();
  }

  void nextMonth() {
    if (!canGoForward) return;
    anchorMonth.value =
        DateTime(anchorMonth.value.year, anchorMonth.value.month + 1);
    _recompute();
  }

  // ─── Load (fetch once) + recompute ──────────────────────────────────────────

  /// Full refresh — refetches the cache, then recomputes. Called on first load,
  /// pull-to-refresh, and after an expense is added/deleted.
  Future<void> reload() async {
    isLoading.value = true;
    await Future.wait([_fetchTransactions(), _fetchExpenses()]);
    _recompute();
    isLoading.value = false;
  }

  Future<void> _fetchTransactions() async {
    _txCache.clear();
    // Owner caches the whole network once (branch scoping is in-memory);
    // manager only ever needs its own branch.
    final branch = isOwner ? null : _session.branchId;
    if (branch == null || branch.isEmpty) {
      await _txService.getAll(
        callBack: (list) => _txCache
            .addAll(list.whereType<FinancialTransactionModel>()),
      );
    } else {
      _txCache.addAll(await _txService.getByBranch(branch));
    }
  }

  Future<void> _fetchExpenses() async {
    _expenseCache.clear();
    await _expenseService.getAll(
      callBack: (list) =>
          _expenseCache.addAll(list.whereType<ExpenseModel>()),
    );
  }

  /// Recompute all four reports from the cache for the current scope + month.
  /// No Firebase — pure calc via [FinanceAnalyticsService].
  void _recompute() {
    final branchId = scopeBranchId;
    final start = _startMs;
    final end = _endMs;

    summary.value = _analytics.getSummary(
      _txCache,
      _expenseCache,
      branchId: branchId,
      startMs: start,
      endMs: end,
    );
    categories.value = _analytics.getCategorySummaries(
      _txCache,
      branchId: branchId,
      startMs: start,
      endMs: end,
    );
    expenseCategories.value = _analytics.getExpenseCategorySummaries(
      _expenseCache,
      branchId: branchId,
      startMs: start,
      endMs: end,
    );
    // A month/scope change can drop the previously-selected category, so clear
    // both filters to avoid an empty list under a stale selection.
    collectionCategoryFilter.value = null;
    expenseCategoryFilter.value = null;
    recentCollections.value = _analytics.getRecentCollections(
      _txCache,
      branchId: branchId,
      startMs: start,
      endMs: end,
    );
    recentExpenses.value = _analytics.getRecentExpenses(
      _expenseCache,
      branchId: branchId,
      startMs: start,
      endMs: end,
    );
    revision.value++;
  }

  // ─── Expense mutations (owner/manager add + manage) ─────────────────────────

  /// Records a spent expense (status = paid, dated on [dateMs]). [branchId] is
  /// the chosen branch, or `null` for a network-overhead cost. On success only
  /// the expense cache is refetched (transactions are untouched) and reports
  /// recompute.
  Future<bool> saveExpense({
    required String categoryKey,
    required String categoryLabel,
    required double amount,
    required int dateMs,
    String? note,
    required String? branchId,
  }) async {
    if (amount <= 0) {
      Loader.showError('payment_fill_required'.tr);
      return false;
    }
    final expense = ExpenseModel(
      key: const Uuid().v4(),
      nurseryId: _session.nurseryId ?? ApiConstants.nurseryId,
      branchId: (branchId != null && branchId.isNotEmpty) ? branchId : null,
      party: categoryLabel,
      item: (note != null && note.trim().isNotEmpty) ? note.trim() : null,
      categoryId: categoryKey,
      categoryName: categoryLabel,
      amount: amount,
      status: 'paid',
      paidAt: dateMs,
      paidBy: _session.userId,
    );

    Loader.show();
    var ok = false;
    await _expenseService.add(
      item: expense,
      callBack: (status) => ok = status == ResponseStatus.success,
    );
    Loader.dismiss();

    if (ok) {
      Loader.showSuccess('expense_saved'.tr);
      await _fetchExpenses();
      _recompute();
    } else {
      Loader.showError('expense_save_failed'.tr);
    }
    return ok;
  }

  Future<bool> deleteExpense(String id) async {
    if (id.isEmpty) return false;
    Loader.show();
    var ok = false;
    await _expenseService.delete(
      id: id,
      callBack: (status) => ok = status == ResponseStatus.success,
    );
    Loader.dismiss();
    if (ok) {
      Loader.showSuccess('expense_deleted'.tr);
      await _fetchExpenses();
      _recompute();
    } else {
      Loader.showError('expense_save_failed'.tr);
    }
    return ok;
  }

  // ─── Full-list helpers (for "عرض الكل") — read from cache, no refetch ────────

  List<RecentCollection> allCollectionsForPeriod() =>
      _analytics.getRecentCollections(
        _txCache,
        branchId: scopeBranchId,
        categoryId: collectionCategoryFilter.value,
        startMs: _startMs,
        endMs: _endMs,
        limit: 1 << 30,
      );

  List<RecentExpense> allExpensesForPeriod() => _analytics.getRecentExpenses(
        _expenseCache,
        branchId: scopeBranchId,
        categoryId: expenseCategoryFilter.value,
        startMs: _startMs,
        endMs: _endMs,
        limit: 1 << 30,
      );

  void setCollectionCategoryFilter(String? categoryId) {
    collectionCategoryFilter.value = categoryId;
    revision.value++;
  }

  void setExpenseCategoryFilter(String? categoryId) {
    expenseCategoryFilter.value = categoryId;
    revision.value++;
  }
}
