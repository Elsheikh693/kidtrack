import 'package:flutter/material.dart';
import '../../../../design_systems/design_constants/colors/app_colors.dart';

/// What KIND of signal this is. Not everything is a problem — the owner needs
/// problems, opportunities, achievements, trends and recommendations.
/// New kinds (e.g. `prediction`, `forecast`) plug in here without refactor.
enum InsightType { alert, opportunity, achievement, trend, recommendation }

/// Which part of the business an insight is about. Lets the owner filter
/// ("show me Finance only") and lets the UI colour-code by domain.
enum InsightCategory { finance, operations, education, staff, growth }

extension InsightCategoryX on InsightCategory {
  String get labelKey => switch (this) {
        InsightCategory.finance => 'owner_cat_finance',
        InsightCategory.operations => 'owner_cat_operations',
        InsightCategory.education => 'owner_cat_education',
        InsightCategory.staff => 'owner_cat_staff',
        InsightCategory.growth => 'owner_cat_growth',
      };
}

/// Visual urgency. `info` is used for neutral trends.
enum InsightSeverity { critical, warning, positive, info }

extension InsightSeverityX on InsightSeverity {
  /// Lower = shown first.
  int get sortRank => switch (this) {
        InsightSeverity.critical => 0,
        InsightSeverity.warning => 1,
        InsightSeverity.info => 2,
        InsightSeverity.positive => 3,
      };

  Color get color => switch (this) {
        InsightSeverity.critical => AppColors.errorForeground,
        InsightSeverity.warning => AppColors.yellowForeground,
        InsightSeverity.positive => AppColors.successForeground,
        InsightSeverity.info => AppColors.blueForeground,
      };

  Color get bg => switch (this) {
        InsightSeverity.critical => AppColors.errorBackground,
        InsightSeverity.warning => AppColors.yellowBackground,
        InsightSeverity.positive => AppColors.successBackground,
        InsightSeverity.info => AppColors.blueLightBackground,
      };
}

/// Oversight lifecycle — only meaningful for actionable types
/// (alert / opportunity / recommendation). Null for achievement / trend.
enum InsightStatus { open, underReview, resolved }

extension InsightStatusX on InsightStatus {
  String get labelKey => switch (this) {
        InsightStatus.open => 'owner_dash_status_open',
        InsightStatus.underReview => 'owner_dash_status_review',
        InsightStatus.resolved => 'owner_dash_status_resolved',
      };

  Color get color => switch (this) {
        InsightStatus.open => AppColors.errorForeground,
        InsightStatus.underReview => AppColors.blueForeground,
        InsightStatus.resolved => AppColors.successForeground,
      };
}

/// A single decision-oriented signal surfaced to the owner.
///
/// Philosophy: the owner DECIDES, staff EXECUTES. So this carries the problem,
/// its impact, and WHO is responsible — but no execution action. Structure:
/// Problem (title) → Impact → Responsible → Status.
class OwnerInsightItem {
  final String id;
  final InsightType type;
  final InsightSeverity severity;

  /// Which business domain this belongs to.
  final InsightCategory category;

  /// 0–100 ranking score: how loudly this should compete for the owner's
  /// attention. The dashboard sorts by this and shows only the top few. Folds
  /// severity + business impact into one comparable number.
  final int priority;

  /// The headline, e.g. "14 طفل متأخرين أكثر من 60 يوم".
  final String title;

  /// The business impact, e.g. "23,000 ج.م غير محصلة".
  final String impact;

  /// Free-form role token (e.g. 'reception', 'manager', 'accountant').
  /// Kept as a String so new roles need no enum change. Null = informational.
  final String? responsibleRole;

  /// Which branch this insight is about (network-scope only). Null = applies to
  /// the whole network / current branch scope.
  final String? branchName;

  /// Optional route the owner can deep-link into to act on this. Null = none.
  final String? deeplink;

  /// Only set for actionable types; null for achievement / trend.
  final InsightStatus? status;

  final IconData icon;
  final DateTime createdAt;

  OwnerInsightItem({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.impact,
    required this.icon,
    this.category = InsightCategory.operations,
    this.priority = 0,
    this.responsibleRole,
    this.branchName,
    this.deeplink,
    this.status,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isProblem =>
      type == InsightType.alert || type == InsightType.recommendation;
  bool get isWin =>
      type == InsightType.achievement || type == InsightType.trend;
}

/// Maps a free-form role token to its localization key.
/// Unknown tokens fall back to the raw token so the UI still shows something.
String roleLabelKey(String? role) => switch (role) {
      'reception' => 'owner_dash_role_reception',
      'manager' => 'owner_dash_role_manager',
      'accountant' => 'owner_dash_role_accountant',
      _ => 'owner_dash_role_none',
    };

/// Compact `1,250` style money formatting (no decimals, thousands separators).
String formatMoney(num value) {
  final v = value.round();
  final neg = v < 0;
  final s = v.abs().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return '${neg ? '-' : ''}$buf';
}
