/// One month of finance flow — revenue billed, collected, and expenses for that
/// calendar month. A flat data point: the chart, summary, comparison and history
/// read it; none recompute it. Outstanding / profit / collection-rate are simple
/// per-month derivations of the three stored flows.
class MonthlyFinancePoint {
  final int year;
  final int month; // 1-12
  final double revenue; // billed this month
  final double collected;
  final double expenses;

  const MonthlyFinancePoint({
    required this.year,
    required this.month,
    this.revenue = 0,
    this.collected = 0,
    this.expenses = 0,
  });

  double get profit => collected - expenses;

  /// What was billed but not yet collected for this month's invoices.
  double get outstanding {
    final o = revenue - collected;
    return o < 0 ? 0 : o;
  }

  double get collectionRate =>
      revenue > 0 ? (collected / revenue).clamp(0.0, 1.0) : 0.0;

  int get collectionPercent => (collectionRate * 100).round();

  Map<String, dynamic> toJson() => {
        'year': year,
        'month': month,
        'revenue': revenue,
        'collected': collected,
        'expenses': expenses,
      };

  factory MonthlyFinancePoint.fromJson(Map<String, dynamic> j) =>
      MonthlyFinancePoint(
        year: (j['year'] as num?)?.toInt() ?? 0,
        month: (j['month'] as num?)?.toInt() ?? 1,
        revenue: (j['revenue'] as num?)?.toDouble() ?? 0,
        collected: (j['collected'] as num?)?.toDouble() ?? 0,
        expenses: (j['expenses'] as num?)?.toDouble() ?? 0,
      );
}
