import 'package:intl/intl.dart';
import 'package:get/get.dart';

/// Month helpers shared by the platform-billing screens. Months are stored as
/// a single sortable int `YYYYMM` (e.g. July 2026 → 202607).
class BillingMonth {
  BillingMonth._();

  static int current() {
    final now = DateTime.now();
    return now.year * 100 + now.month;
  }

  static DateTime toDate(int ym) => DateTime(ym ~/ 100, ym % 100);

  static int fromDate(DateTime d) => d.year * 100 + d.month;

  /// The last [count] months (including the current one), newest first.
  static List<int> recent({int count = 12}) {
    final now = DateTime.now();
    return List.generate(count, (i) {
      final d = DateTime(now.year, now.month - i);
      return fromDate(d);
    });
  }

  /// Localized "MMMM yyyy" label, e.g. «يوليو 2026» / «July 2026».
  static String label(int ym) {
    final locale = Get.locale?.languageCode == 'en' ? 'en' : 'ar';
    return DateFormat('MMMM yyyy', locale).format(toDate(ym));
  }
}
