import '../../../../../../index/index_main.dart';

/// Colors, labels and emoji for a [DailyRating] across the evaluation report.
class DailyRatingStyle {
  DailyRatingStyle._();

  static const excellent = Color(0xFF16A34A);
  static const veryGood = Color(0xFF0891B2);
  static const good = Color(0xFFD97706);
  static const needsSupport = Color(0xFFDC2626);

  static Color color(DailyRating r) {
    switch (r) {
      case DailyRating.excellent:
        return excellent;
      case DailyRating.veryGood:
        return veryGood;
      case DailyRating.good:
        return good;
      case DailyRating.needsSupport:
        return needsSupport;
    }
  }

  static String labelKey(DailyRating r) {
    switch (r) {
      case DailyRating.excellent:
        return 'report_rating_excellent';
      case DailyRating.veryGood:
        return 'report_rating_very_good';
      case DailyRating.good:
        return 'report_rating_good';
      case DailyRating.needsSupport:
        return 'report_rating_needs_support';
    }
  }

  static String emoji(DailyRating r) => r.emoji;
}
