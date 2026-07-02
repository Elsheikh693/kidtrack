import 'package:flutter/material.dart';
import '../../../../design_systems/design_constants/colors/app_colors.dart';

/// One component of a Branch Health Score, kept EXPLAINABLE: it carries the
/// points earned and the maximum (the weight), so the owner can always see WHY
/// a branch scored what it did — e.g. occupancy 22/30.
class HealthComponent {
  /// Localization key for the component name.
  final String labelKey;

  /// Points earned, 0..[max].
  final double earned;

  /// The component's weight (its maximum possible points).
  final double max;

  const HealthComponent({
    required this.labelKey,
    required this.earned,
    required this.max,
  });

  /// 0..1 fill within this component.
  double get fill => max <= 0 ? 0 : (earned / max).clamp(0, 1).toDouble();

  Map<String, dynamic> toJson() =>
      {'labelKey': labelKey, 'earned': earned, 'max': max};

  factory HealthComponent.fromJson(Map<String, dynamic> j) => HealthComponent(
        labelKey: (j['labelKey'] ?? '') as String,
        earned: (j['earned'] as num?)?.toDouble() ?? 0,
        max: (j['max'] as num?)?.toDouble() ?? 0,
      );
}

/// The breakdown behind a Branch Health Score — the four weighted components.
/// Stored even when not shown, so the moment the owner asks "why is Mahalla 72?"
/// we can answer from data, not hand-waving. Parent Satisfaction is absent until
/// a data source exists (v2).
class HealthScoreBreakdown {
  final HealthComponent occupancy;
  final HealthComponent collections;
  final HealthComponent teacherActivity;
  final HealthComponent pendingTasks;

  const HealthScoreBreakdown({
    required this.occupancy,
    required this.collections,
    required this.teacherActivity,
    required this.pendingTasks,
  });

  List<HealthComponent> get components =>
      [occupancy, collections, teacherActivity, pendingTasks];

  double get earned =>
      components.fold(0.0, (s, c) => s + c.earned);
  double get max => components.fold(0.0, (s, c) => s + c.max);

  Map<String, dynamic> toJson() => {
        'occupancy': occupancy.toJson(),
        'collections': collections.toJson(),
        'teacherActivity': teacherActivity.toJson(),
        'pendingTasks': pendingTasks.toJson(),
      };

  factory HealthScoreBreakdown.fromJson(Map<String, dynamic> j) =>
      HealthScoreBreakdown(
        occupancy:
            HealthComponent.fromJson((j['occupancy'] as Map).cast<String, dynamic>()),
        collections: HealthComponent.fromJson(
            (j['collections'] as Map).cast<String, dynamic>()),
        teacherActivity: HealthComponent.fromJson(
            (j['teacherActivity'] as Map).cast<String, dynamic>()),
        pendingTasks: HealthComponent.fromJson(
            (j['pendingTasks'] as Map).cast<String, dynamic>()),
      );
}

/// A branch's overall health on a 0–100 scale, with the breakdown that explains
/// it. This — NOT revenue — is how the Branch Health Ranking sorts: the
/// highest-revenue branch can still be failing (overdue piling up, teachers not
/// posting, occupancy sliding), and health tells the truer story.
class BranchHealthScore {
  final String branchId;
  final String branchName;

  /// 0..100.
  final double score;
  final HealthScoreBreakdown breakdown;

  /// False when the branch has nothing real to measure yet (no children, no
  /// money, no activity). Such a branch must NOT be scored "at risk" or raise
  /// alerts — there's simply no data, not a problem.
  final bool hasData;

  const BranchHealthScore({
    required this.branchId,
    required this.branchName,
    required this.score,
    required this.breakdown,
    this.hasData = true,
  });

  int get scoreRounded => score.round();

  /// Health band → colour. ≥80 healthy, ≥60 watch, else at-risk.
  Color get color => score >= 80
      ? AppColors.successForeground
      : score >= 60
          ? AppColors.yellowForeground
          : AppColors.errorForeground;

  String get bandKey => score >= 80
      ? 'owner_health_band_good'
      : score >= 60
          ? 'owner_health_band_watch'
          : 'owner_health_band_risk';
}
