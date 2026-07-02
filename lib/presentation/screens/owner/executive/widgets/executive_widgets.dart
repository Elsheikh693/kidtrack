import '../../../../../index/index_main.dart';
import '../models/owner_insight_item.dart';
import '../models/owner_dashboard_data.dart';

// ── Section label ─────────────────────────────────────────────────────────────

class ExecSectionLabel extends StatelessWidget {
  const ExecSectionLabel({
    super.key,
    required this.titleKey,
    required this.icon,
    required this.color,
    this.trailing,
  });

  final String titleKey;
  final IconData icon;
  final Color color;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 22.h, 4.w, 12.h),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: color),
          SizedBox(width: 8.w),
          Text(
            titleKey.tr,
            style: context.typography.mdBold.copyWith(
              color: AppColors.textDefault,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          if (trailing != null)
            Text(
              trailing!,
              style: context.typography.xsMedium.copyWith(
                color: AppColors.textSecondaryParagraph,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Insight card (display only — the owner decides, never executes) ───────────

class InsightCard extends StatelessWidget {
  const InsightCard({super.key, required this.item});

  final OwnerInsightItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: item.severity.color.withValues(alpha: 0.16),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: item.severity.bg,
              borderRadius: BorderRadius.circular(13.r),
            ),
            child: Icon(item.icon, color: item.severity.color, size: 22.sp),
          ),
          SizedBox(width: 13.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: context.typography.displaySmBold.copyWith(
                    color: AppColors.textDefault,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  item.impact,
                  style: context.typography.xsMedium.copyWith(
                    color: AppColors.textSecondaryParagraph,
                    height: 1.35,
                  ),
                ),
                if (item.responsibleRole != null || item.status != null) ...[
                  SizedBox(height: 9.h),
                  Wrap(
                    spacing: 7.w,
                    runSpacing: 6.h,
                    children: [
                      if (item.responsibleRole != null)
                        _Chip(
                          icon: Icons.person_outline_rounded,
                          label: roleLabelKey(item.responsibleRole).tr,
                          color: AppColors.textSecondaryParagraph,
                          bg: AppColors.backgroundNeutral100,
                        ),
                      if (item.status != null)
                        _Chip(
                          icon: Icons.flag_outlined,
                          label: item.status!.labelKey.tr,
                          color: item.status!.color,
                          bg: item.status!.color.withValues(alpha: 0.10),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: color),
          SizedBox(width: 5.w),
          Text(
            label,
            style: context.typography.xsMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── "All clear" card when nothing needs attention ─────────────────────────────

class AllClearCard extends StatelessWidget {
  const AllClearCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.successBackground,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: AppColors.successForeground.withValues(alpha: 0.20),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded,
              color: AppColors.successForeground, size: 26.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'owner_exec_all_clear'.tr,
              style: context.typography.displaySmBold.copyWith(
                color: AppColors.successForeground.darken(0.10),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Finance snapshot ──────────────────────────────────────────────────────────

class FinanceSnapshotCard extends StatelessWidget {
  const FinanceSnapshotCard({super.key, required this.finance});

  final FinanceSnapshot finance;

  @override
  Widget build(BuildContext context) {
    return _SnapshotShell(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  labelKey: 'owner_fin_revenue',
                  value: finance.expectedRevenue,
                  color: AppColors.blueForeground,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _MetricTile(
                  labelKey: 'owner_fin_collected',
                  value: finance.collected,
                  color: AppColors.successForeground,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  labelKey: 'owner_fin_outstanding',
                  value: finance.outstanding,
                  color: AppColors.yellowForeground,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _MetricTile(
                  labelKey: 'owner_fin_profit',
                  value: finance.profit,
                  color: finance.profit < 0
                      ? AppColors.errorForeground
                      : AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _ProgressLine(
            labelKey: 'owner_fin_collection_rate',
            percent: finance.collectionPercent,
            color: AppColors.successForeground,
          ),
        ],
      ),
    );
  }
}

// ── Shared pieces ─────────────────────────────────────────────────────────────

class _SnapshotShell extends StatelessWidget {
  const _SnapshotShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.labelKey,
    required this.value,
    required this.color,
  });

  final String labelKey;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 13.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelKey.tr,
            style: context.typography.xsMedium.copyWith(
              color: AppColors.textSecondaryParagraph,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  formatMoney(value),
                  style: context.typography.lgBold.copyWith(
                    color: color.darken(0.08),
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  'owner_currency'.tr,
                  style: context.typography.xsMedium.copyWith(
                    color: color.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Count tile that mirrors [_MetricTile]'s look (label on top, big value below,
/// tinted background) but renders a plain integer instead of money.
class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.labelKey,
    required this.value,
    required this.color,
  });

  final String labelKey;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 13.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelKey.tr,
            style: context.typography.xsMedium.copyWith(
              color: AppColors.textSecondaryParagraph,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            '$value',
            style: context.typography.lgBold.copyWith(
              color: color.darken(0.08),
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({
    required this.labelKey,
    required this.percent,
    required this.color,
  });

  final String labelKey;
  final int percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final clamped = (percent / 100).clamp(0.0, 1.0);
    return Column(
      children: [
        Row(
          children: [
            Text(
              labelKey.tr,
              style: context.typography.xsRegular.copyWith(
                color: AppColors.textDefault,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              '$percent%',
              style: context.typography.xsRegular.copyWith(
                color: color.darken(0.08),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: LinearProgressIndicator(
            value: clamped,
            minHeight: 8.h,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

// ── Business snapshot (vital signs at a glance) ───────────────────────────────

class BusinessSnapshotCard extends StatelessWidget {
  const BusinessSnapshotCard({
    super.key,
    required this.business,
    required this.growth,
    required this.isNetwork,
  });

  final BusinessSnapshot business;
  final GrowthSnapshot growth;
  final bool isNetwork;

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      if (isNetwork)
        _StatTile(
          labelKey: 'owner_biz_branches',
          value: business.branches,
          color: AppColors.primary,
        ),
      _StatTile(
        labelKey: 'owner_biz_children',
        value: business.children,
        color: AppColors.blueForeground,
      ),
      _StatTile(
        labelKey: 'owner_biz_staff',
        value: business.staff,
        color: AppColors.yellowForeground,
      ),
      _StatTile(
        labelKey: 'owner_growth_new',
        value: growth.newThisMonth,
        color: AppColors.successForeground,
      ),
    ];

    return _SnapshotShell(
      child: Column(
        children: [
          for (int i = 0; i < tiles.length; i += 2) ...[
            if (i > 0) SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(child: tiles[i]),
                SizedBox(width: 10.w),
                Expanded(
                  child:
                      i + 1 < tiles.length ? tiles[i + 1] : const SizedBox(),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
