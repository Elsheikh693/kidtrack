import '../../../../../../index/index_main.dart';

/// Shared colors, icons and labels for an attendance status across the report
/// widgets (calendar, details) and the rate thresholds.
class AttendanceStatus {
  AttendanceStatus._();

  static const present = Color(0xFF16A34A);
  static const late = Color(0xFFD97706);
  static const absent = Color(0xFFDC2626);
  static const excused = Color(0xFF0284C7);
  static const neutral = Color(0xFF94A3B8);

  static Color color(String status) {
    switch (status) {
      case 'present':
        return present;
      case 'late':
        return late;
      case 'absent':
        return absent;
      case 'excused':
        return excused;
      default:
        return neutral;
    }
  }

  static IconData icon(String status) {
    switch (status) {
      case 'present':
        return Icons.check_circle_rounded;
      case 'late':
        return Icons.access_time_rounded;
      case 'absent':
        return Icons.cancel_rounded;
      case 'excused':
        return Icons.event_available_rounded;
      case 'upcoming':
        return Icons.schedule_rounded;
      default:
        return Icons.remove_circle_outline_rounded;
    }
  }

  static String labelKey(String status) {
    switch (status) {
      case 'present':
        return 'report_status_present';
      case 'late':
        return 'report_status_late';
      case 'absent':
        return 'report_status_absent';
      case 'excused':
        return 'report_status_excused';
      case 'upcoming':
        return 'report_status_upcoming';
      default:
        return 'report_status_none';
    }
  }

  /// Header rate color by threshold: 🟢 ≥90 · 🟡 75–89 · 🔴 <75.
  static Color rateColor(int rate) {
    if (rate >= 90) return present;
    if (rate >= 75) return late;
    return absent;
  }

  static String rateLabelKey(int rate) {
    if (rate >= 90) return 'report_rate_excellent';
    if (rate >= 75) return 'report_rate_good';
    return 'report_rate_low';
  }
}
