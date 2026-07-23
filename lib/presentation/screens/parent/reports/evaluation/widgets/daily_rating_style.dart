import '../../../../../../index/index_main.dart';

/// Colors, labels and icons for an [EvalLevel] across the evaluation report.
/// Mirrors the language parents already see in the Daily Journal (3-level
/// teacher scale, softened tone).
class DailyRatingStyle {
  DailyRatingStyle._();

  static const excellent = Color(0xFF059669);
  static const needsFollow = Color(0xFF2563EB);
  static const needsAttention = Color(0xFFD97706);

  static Color color(EvalLevel r) {
    switch (r) {
      case EvalLevel.excellent:
        return excellent;
      case EvalLevel.needsFollow:
        return needsFollow;
      case EvalLevel.needsAttention:
        return needsAttention;
    }
  }

  static String labelKey(EvalLevel r) {
    switch (r) {
      case EvalLevel.excellent:
        return 'report_rating_excellent';
      case EvalLevel.needsFollow:
        return 'report_rating_very_good';
      case EvalLevel.needsAttention:
        return 'report_rating_needs_support';
    }
  }

  static IconData icon(EvalLevel r) {
    switch (r) {
      case EvalLevel.excellent:
        return Icons.star_rounded;
      case EvalLevel.needsFollow:
        return Icons.thumb_up_rounded;
      case EvalLevel.needsAttention:
        return Icons.error_rounded;
    }
  }
}
