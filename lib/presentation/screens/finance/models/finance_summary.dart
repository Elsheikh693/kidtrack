// Report DTOs produced by FinanceAnalyticsService. They are plain value types
// (never Maps) so the UI stays clean and a new report screen can reuse a single
// piece — "آخر التحصيلات" or "الإيرادات حسب التصنيف" — without dragging the
// whole dashboard along.
//
// None of these carry UI concerns (no formatted strings, no currency): the
// controller owns formatting. Dates are real DateTimes, amounts are raw.

/// The KPI trio: revenue, expenses, and the profit derived from them.
class FinanceSummary {
  final double revenue;
  final double expenses;

  const FinanceSummary({this.revenue = 0, this.expenses = 0});

  double get netProfit => revenue - expenses;
}

/// One fee category's take for the period — backs the "تقسيم الإيرادات" grid.
class CategoryRevenue {
  final String categoryId;
  final String categoryName;
  final double total;
  final int transactionsCount;

  const CategoryRevenue({
    required this.categoryId,
    required this.categoryName,
    required this.total,
    required this.transactionsCount,
  });
}

/// A single collection row. Every field is a snapshot stored on the transaction
/// (child name, category, who collected) so this needs NO join — the exact
/// promise the denormalized [FinancialTransactionModel] was built to keep.
class RecentCollection {
  final String childName;
  final String categoryName;
  final double amount;
  final DateTime date;
  final String collectedBy;

  const RecentCollection({
    required this.childName,
    required this.categoryName,
    required this.amount,
    required this.date,
    required this.collectedBy,
  });
}

/// A single expense row. [expenseId] is carried so the full list can offer
/// delete; the dashboard row ignores it.
class RecentExpense {
  final String expenseId;
  final String title;
  final double amount;
  final DateTime date;

  const RecentExpense({
    required this.expenseId,
    required this.title,
    required this.amount,
    required this.date,
  });
}
