/// One child's payment standing for a single month: how much was billed
/// (subscription + any enrollments due that month) and how much of it has been
/// collected. Drives the per-child row in the monthly payments screen.
class MonthlyPaymentRow {
  const MonthlyPaymentRow({
    required this.childId,
    required this.childName,
    required this.parentName,
    required this.billed,
    required this.collected,
    required this.dueDate,
  });

  final String childId;
  final String childName;
  final String parentName;
  final double billed;
  final double collected;

  /// Earliest due date among this child's invoices for the month (ms), if any.
  final int? dueDate;

  double get remaining {
    final r = billed - collected;
    return r < 0 ? 0 : r;
  }

  /// Fully settled for the month (something was billed and nothing remains).
  bool get isPaid => billed > 0 && remaining <= 0;
}
