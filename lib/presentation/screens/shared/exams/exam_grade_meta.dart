import '../../../../index/index_main.dart';

/// The visual identity of an [ExamGrade] — accent colour, icon, celebratory
/// emoji and localized label. Shared by the staff grading UI, the parent exam
/// list/detail, the reveal animation and the branded share card, so a grade
/// always looks the same everywhere. Kept intentionally warm and encouraging
/// (it is shown to a young child): even the lowest level reads as "keep going".
class ExamGradeMeta {
  final Color color;
  final IconData icon;
  final String emoji;
  final String labelKey;

  const ExamGradeMeta({
    required this.color,
    required this.icon,
    required this.emoji,
    required this.labelKey,
  });

  String get label => labelKey.tr;

  static ExamGradeMeta of(ExamGrade grade) {
    switch (grade) {
      case ExamGrade.excellent:
        return const ExamGradeMeta(
          color: Color(0xFF16A34A),
          icon: Icons.emoji_events_rounded,
          emoji: '🌟',
          labelKey: 'exam_grade_excellent',
        );
      case ExamGrade.veryGood:
        return const ExamGradeMeta(
          color: Color(0xFF0EA5E9),
          icon: Icons.celebration_rounded,
          emoji: '🎉',
          labelKey: 'exam_grade_veryGood',
        );
      case ExamGrade.good:
        return const ExamGradeMeta(
          color: Color(0xFF6366F1),
          icon: Icons.thumb_up_rounded,
          emoji: '👍',
          labelKey: 'exam_grade_good',
        );
      case ExamGrade.acceptable:
        return const ExamGradeMeta(
          color: Color(0xFFD97706),
          icon: Icons.sentiment_satisfied_rounded,
          emoji: '🙂',
          labelKey: 'exam_grade_acceptable',
        );
      case ExamGrade.needsImprovement:
        return const ExamGradeMeta(
          color: Color(0xFFF43F5E),
          icon: Icons.volunteer_activism_rounded,
          emoji: '💪',
          labelKey: 'exam_grade_needsImprovement',
        );
    }
  }
}
