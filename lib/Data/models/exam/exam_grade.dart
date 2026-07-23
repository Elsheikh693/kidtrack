/// The verbal grade scale for a written exam result.
///
/// v1 is a fixed, localized 5-level scale (kept simplest); it can later become
/// nursery-defined the same way [EvalLevelTemplateModel] made activity levels
/// dynamic. The enum is the single source of truth — persisted by [key],
/// ordered by [score] (used for sort + the celebratory reveal intensity), and
/// rendered by a UI meta helper in the exam widgets layer.
enum ExamGrade {
  excellent,
  veryGood,
  good,
  acceptable,
  needsImprovement;

  /// Stable string persisted on [ExamResultModel.grade].
  String get key => name;

  /// 5 (excellent) … 1 (needs improvement). Drives sorting and how big the
  /// parent-side reveal animation celebrates.
  int get score {
    switch (this) {
      case ExamGrade.excellent:
        return 5;
      case ExamGrade.veryGood:
        return 4;
      case ExamGrade.good:
        return 3;
      case ExamGrade.acceptable:
        return 2;
      case ExamGrade.needsImprovement:
        return 1;
    }
  }

  /// Localization key for the grade label (defined in ar.dart / en.dart).
  String get labelKey => 'exam_grade_$name';

  static ExamGrade? fromKey(String? value) {
    if (value == null) return null;
    for (final g in ExamGrade.values) {
      if (g.name == value) return g;
    }
    return null;
  }
}
