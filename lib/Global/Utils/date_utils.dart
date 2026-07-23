import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DatesUtilis {
  static DateTime? parseDate(String date) {
    try {
      return DateFormat('dd/MM/yyyy').parse(date);
    } catch (e) {
      return null;
    }
  }

  static String formatDateTime(String? date) {
    if (date == null || date.isEmpty) {
      return "-";
    }

    try {
      final parsedDate = DateTime.parse(date);

      return DateFormat('dd-MM-yyyy • hh:mm a').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  static T convertTimestamp<T>(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

    // ✅ لو النوع String
    if (T == String) {
      return DateFormat('dd/MM/yyyy').format(dateTime) as T;
    }

    // ✅ لو النوع DateTime
    if (T == DateTime) {
      return dateTime as T;
    }

    // ✅ لو النوع dynamic أو مش متحدد
    if (T == dynamic) {
      // الافتراضي String (أكتر استخدام في UI)
      return DateFormat('dd/MM/yyyy').format(dateTime) as T;
    }

    // ❌ أي نوع تاني
    throw UnsupportedError("convertTimestamp does not support type $T");
  }

  static String todayAsString() {
    return DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  static String humanizeTimestamp(int? timestamp) {
    if (timestamp == null) return 'datamodels5_unknown'.tr;

    final now = DateTime.now();
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'datamodels5_moments_ago'.tr;
    if (diff.inMinutes < 60) {
      return 'datamodels5_minutes_ago'
          .trParams({'count': '${diff.inMinutes}'});
    }
    if (diff.inHours < 24) {
      return 'datamodels5_hours_ago'.trParams({'count': '${diff.inHours}'});
    }
    if (diff.inDays < 30) {
      return 'datamodels5_days_ago'.trParams({'count': '${diff.inDays}'});
    }
    if (diff.inDays < 365) {
      return 'datamodels5_months_ago'
          .trParams({'count': '${diff.inDays ~/ 30}'});
    }

    return 'datamodels5_years_ago'.trParams({'count': '${diff.inDays ~/ 365}'});
  }

  static void checkDateEndBiggerThanStart({
    required String startDateText,
    required String endDateText,
    required Function(bool isError, String? errorMessage) onValidationResult,
  }) {
    if (startDateText.isNotEmpty && endDateText.isNotEmpty) {
      final DateTime? startDate = parseDate(startDateText);
      final DateTime? endDate = parseDate(endDateText);

      if (startDate != null && endDate != null) {
        if (endDate.isBefore(startDate)) {
          // End date is before start date
          onValidationResult(
            true,
            'datamodels5_end_after_start'.tr,
          );
        } else {
          // Calculate the duration between the two dates
          final Duration duration = endDate.difference(startDate);

          if (duration.inDays < 30) {
            // Duration is less than 30 days
            onValidationResult(true, 'datamodels5_duration_min_30'.tr);
          } else if (duration.inDays > 365) {
            // Duration is more than 1 year
            onValidationResult(true, 'datamodels5_duration_max_year'.tr);
          } else {
            // Dates and duration are valid
            onValidationResult(false, null); // No error
          }
        }
      } else {
        // One or both dates could not be parsed
        onValidationResult(true, 'datamodels5_invalid_dates'.tr);
      }
    }
  }

  /// Check if `third` is between `first` and `second`
  static bool isDateBetween({
    required DateTime first,
    required DateTime second,
    required DateTime third,
  }) {
    return third.isAfter(first) && third.isBefore(second) ||
        third.isAtSameMomentAs(first) ||
        third.isAtSameMomentAs(second);
  }
}
