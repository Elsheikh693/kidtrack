import '../../../../index/index_main.dart';

/// Status of a financial obligation, derived from [dueDate] and paid state.
enum ObligationStatus { overdue, upcoming, paid }

/// A single expense / obligation toward a vendor, course, rent, etc.
/// View model mapped from [ExpenseModel] for the الماليات screen.
class Obligation {
  final String id;
  final String party; // الجهة / المستفيد (e.g. "فان داي")
  final String? item; // اسم البند (optional)
  final String categoryId;
  final String categoryName;
  final double amount;
  final DateTime dueDate;
  final ObligationStatus status;

  const Obligation({
    required this.id,
    required this.party,
    this.item,
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.dueDate,
    required this.status,
  });

  /// Whole days from now until [dueDate] (negative => overdue).
  int get daysUntilDue {
    final now = DateTime.now();
    final d0 = DateTime(now.year, now.month, now.day);
    final d1 = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return d1.difference(d0).inDays;
  }
}

/// A payment category (مصاريف / كورسات / إيجارات ...).
class ObligationCategory {
  final String id;
  final String name;
  final int colorValue;

  const ObligationCategory({
    required this.id,
    required this.name,
    required this.colorValue,
  });
}
