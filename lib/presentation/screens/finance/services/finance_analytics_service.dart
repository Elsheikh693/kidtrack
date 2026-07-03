import '../../../../index/index_main.dart';

/// Pure analytics layer over already-loaded finance data. It performs NO fetch,
/// holds NO state, and knows NOTHING about the UI (no "current month", no date
/// formatting, no currency, no `.tr`). It is handed the raw transaction/expense
/// lists plus a scope (`branchId`, `startMs`, `endMs`) and returns numbers.
///
/// Split into four independent computations — [getSummary],
/// [getCategorySummaries], [getRecentCollections], [getRecentExpenses] — so a
/// future report screen can reuse one without pulling in the whole dashboard.
///
/// The CACHE lives in the controller, not here: the controller downloads the
/// data once and calls these methods (re-filtering in-memory) whenever the month
/// or branch scope changes — no repeated Firebase reads.
///
/// Because every transaction carries its own snapshots (childName, categoryName,
/// collectedByName) and its own [branchId], these methods never join against
/// children/branches/categories.
class FinanceAnalyticsService extends GetxService {
  /// Revenue + expenses (netProfit is derived on the DTO).
  FinanceSummary getSummary(
    List<FinancialTransactionModel> transactions,
    List<ExpenseModel> expenses, {
    String? branchId,
    required int startMs,
    required int endMs,
  }) {
    final txs = _scopeTx(transactions, branchId, startMs, endMs);
    final exs = _scopeExpenses(expenses, branchId, startMs, endMs);
    return FinanceSummary(
      revenue: txs.fold(0, (t, x) => t + x.amount),
      expenses: exs.fold(0, (t, x) => t + x.amount),
    );
  }

  /// Revenue grouped per fee category, highest-earning first.
  List<CategoryRevenue> getCategorySummaries(
    List<FinancialTransactionModel> transactions, {
    String? branchId,
    required int startMs,
    required int endMs,
  }) {
    final byId = <String, CategoryRevenue>{};
    for (final t in _scopeTx(transactions, branchId, startMs, endMs)) {
      final prev = byId[t.categoryId];
      byId[t.categoryId] = CategoryRevenue(
        categoryId: t.categoryId,
        categoryName: t.categoryName,
        total: (prev?.total ?? 0) + t.amount,
        transactionsCount: (prev?.transactionsCount ?? 0) + 1,
      );
    }
    return byId.values.toList()..sort((a, b) => b.total.compareTo(a.total));
  }

  /// The most recent collections, newest first (snapshots → no join).
  List<RecentCollection> getRecentCollections(
    List<FinancialTransactionModel> transactions, {
    String? branchId,
    required int startMs,
    required int endMs,
    int limit = 10,
  }) {
    final scoped = _scopeTx(transactions, branchId, startMs, endMs)
      ..sort((a, b) => b.date.compareTo(a.date));
    return scoped
        .take(limit)
        .map((t) => RecentCollection(
              childName: t.childName,
              categoryName: t.categoryName,
              amount: t.amount,
              date: DateTime.fromMillisecondsSinceEpoch(t.date),
              collectedBy: t.collectedByName ?? '',
            ))
        .toList();
  }

  /// The most recent expenses, newest first. Pass a large [limit] for the full
  /// "عرض كل المصروفات" screen.
  List<RecentExpense> getRecentExpenses(
    List<ExpenseModel> expenses, {
    String? branchId,
    required int startMs,
    required int endMs,
    int limit = 5,
  }) {
    final scoped = _scopeExpenses(expenses, branchId, startMs, endMs)
      ..sort((a, b) => _expenseDate(b).compareTo(_expenseDate(a)));
    return scoped
        .take(limit)
        .map((e) => RecentExpense(
              expenseId: e.key ?? '',
              title: _expenseTitle(e),
              amount: e.amount,
              date: DateTime.fromMillisecondsSinceEpoch(_expenseDate(e)),
            ))
        .toList();
  }

  // ─── Scoping (pure, in-memory) ──────────────────────────────────────────────

  List<FinancialTransactionModel> _scopeTx(
    List<FinancialTransactionModel> all,
    String? branchId,
    int startMs,
    int endMs,
  ) {
    return all
        .where((t) => t.type == TransactionType.collection)
        .where((t) => branchId == null ||
            branchId.isEmpty ||
            t.branchId == branchId)
        .where((t) => t.date >= startMs && t.date < endMs)
        .toList();
  }

  /// Expense scope rule (mirrors [ExpenseModel] semantics):
  /// - network (branchId null/empty): ALL expenses, incl. branch-null overhead —
  ///   the company's total cost.
  /// - single branch: only that branch's direct costs (overhead is not
  ///   attributable to one branch, so it is excluded).
  List<ExpenseModel> _scopeExpenses(
    List<ExpenseModel> all,
    String? branchId,
    int startMs,
    int endMs,
  ) {
    final network = branchId == null || branchId.isEmpty;
    return all
        .where((e) => network || e.branchId == branchId)
        .where((e) {
          final d = _expenseDate(e);
          return d >= startMs && d < endMs;
        })
        .toList();
  }

  int _expenseDate(ExpenseModel e) => e.paidAt ?? e.createdAt ?? e.dueDate ?? 0;

  String _expenseTitle(ExpenseModel e) {
    if (e.categoryName != null && e.categoryName!.isNotEmpty) {
      return e.categoryName!;
    }
    if (e.item != null && e.item!.trim().isNotEmpty) return e.item!.trim();
    return e.party;
  }
}
