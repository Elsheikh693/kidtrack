import '../../../../../Data/models/classroom_activity/classroom_activity_model.dart';

/// Date span the manager is looking at. `day` = a single picked day (detailed
/// feedback), `week`/`month` = trailing window ending on the anchor day
/// (performance trends).
enum TrRange { day, week, month }

extension TrRangeX on TrRange {
  String get labelKey {
    switch (this) {
      case TrRange.day:
        return 'tr_range_day';
      case TrRange.week:
        return 'tr_range_week';
      case TrRange.month:
        return 'tr_range_month';
    }
  }

  /// Number of days included, ending on (and including) the anchor day.
  int get spanDays {
    switch (this) {
      case TrRange.day:
        return 1;
      case TrRange.week:
        return 7;
      case TrRange.month:
        return 30;
    }
  }
}

/// Aggregated performance for one teacher over the selected span. Built from the
/// completed [ClassroomActivityModel]s that carry this teacher's id.
class TeacherPerformance {
  final String teacherId;
  final String name;
  final String? photo;

  /// Distinct classroom display names the teacher ran activities in.
  final List<String> classroomNames;

  /// All completed activities in span, newest first.
  final List<ClassroomActivityModel> activities;

  /// Activity (session) count = activities.length.
  final int sessionCount;

  /// Sum of (endedAt - startedAt) across activities, in minutes.
  final int workingMinutes;

  /// Distinct calendar days that had at least one activity.
  final int workingDays;

  /// Total per-child evaluations recorded.
  final int evaluationCount;

  /// Total photos attached across activities.
  final int photoCount;

  /// Distinct children reached across activities.
  final int childrenReached;

  /// Day key (yyyy-mm-dd ordinal index within span) → activity count, for the
  /// per-teacher sparkline. Length == span days, oldest → newest.
  final List<int> dailyCounts;

  const TeacherPerformance({
    required this.teacherId,
    required this.name,
    this.photo,
    required this.classroomNames,
    required this.activities,
    required this.sessionCount,
    required this.workingMinutes,
    required this.workingDays,
    required this.evaluationCount,
    required this.photoCount,
    required this.childrenReached,
    required this.dailyCounts,
  });

  bool get hasActivity => sessionCount > 0;

  /// Average sessions per working day (0 when no working days).
  double get avgSessionsPerDay =>
      workingDays == 0 ? 0 : sessionCount / workingDays;

  /// Evaluations as a share of (children reached across activities) — a rough
  /// "did the teacher actually assess the kids" signal, 0–100.
  int get evaluationRate {
    final denom = activities.fold<int>(0, (a, x) => a + x.childIds.length);
    if (denom <= 0) return 0;
    return ((evaluationCount / denom) * 100).round().clamp(0, 100);
  }
}

/// Top-of-screen totals across all teachers in the span.
class TrSummary {
  final int activeTeachers;
  final int totalTeachers;
  final int totalActivities;
  final int totalWorkingMinutes;
  final int totalEvaluations;
  final int totalPhotos;

  const TrSummary({
    required this.activeTeachers,
    required this.totalTeachers,
    required this.totalActivities,
    required this.totalWorkingMinutes,
    required this.totalEvaluations,
    required this.totalPhotos,
  });

  static const empty = TrSummary(
    activeTeachers: 0,
    totalTeachers: 0,
    totalActivities: 0,
    totalWorkingMinutes: 0,
    totalEvaluations: 0,
    totalPhotos: 0,
  );
}
