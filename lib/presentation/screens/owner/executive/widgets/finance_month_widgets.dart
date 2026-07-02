import 'package:intl/intl.dart' hide TextDirection;
import '../../../../../index/index_main.dart';
import '../models/monthly_finance_point.dart';
import '../models/owner_insight_item.dart';

/// The PRIMARY filter for the finance tab: a prominent pill showing the selected
/// month. Tapping it opens [showFinanceMonthPicker] so the owner can jump to any
/// of the last 12 months — the whole screen then re-renders for that month.
class FinanceMonthSelector extends StatelessWidget {
  const FinanceMonthSelector({
    super.key,
    required this.point,
    required this.onTap,
  });

  final MonthlyFinancePoint point;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary.darken(0.10), AppColors.primary],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.28),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_month_rounded,
                  color: Colors.white, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'owner_fin_showing_month'.tr,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _monthLabel(point.year, point.month),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded,
                  color: Colors.white, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

String _monthLabel(int year, int month) =>
    DateFormat.yMMMM(Get.locale?.toString()).format(DateTime(year, month));

/// Bottom sheet listing the last N months (newest first). Returns the chosen
/// index into [points], or null if dismissed.
Future<int?> showFinanceMonthPicker({
  required List<MonthlyFinancePoint> points,
  required int selectedIndex,
}) {
  return Get.bottomSheet<int>(
    Container(
      constraints: BoxConstraints(
        maxHeight: Get.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderNeutralPrimary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'owner_fin_pick_month'.tr,
            style: TextStyle(
              color: AppColors.textDefault,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: points.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final idx = points.length - 1 - i; // newest first
                final p = points[idx];
                return _MonthPickerTile(
                  point: p,
                  selected: idx == selectedIndex,
                  onTap: () => Get.back<int>(result: idx),
                );
              },
            ),
          ),
        ],
      ),
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class _MonthPickerTile extends StatelessWidget {
  const _MonthPickerTile({
    required this.point,
    required this.selected,
    required this.onTap,
  });

  final MonthlyFinancePoint point;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final profit = point.profit;
    final profitColor =
        profit < 0 ? const Color(0xFFEF4444) : const Color(0xFF16A34A);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.backgroundNeutral100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.borderNeutralPrimary,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.calendar_today_rounded,
              size: 20,
              color: selected ? AppColors.primary : AppColors.grayMedium,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _monthLabel(point.year, point.month),
                style: TextStyle(
                  color: AppColors.textDefault,
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                ),
              ),
            ),
            Text(
              formatMoney(profit),
              style: TextStyle(
                color: profitColor.darken(0.05),
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The selected month's vital finance signs — the six numbers the owner scans:
/// Revenue · Collected · Outstanding · Collection Rate · Expenses · Direct Profit.
class FinanceMonthSummaryCard extends StatelessWidget {
  const FinanceMonthSummaryCard({super.key, required this.point});

  final MonthlyFinancePoint point;

  @override
  Widget build(BuildContext context) {
    final profitColor = point.profit < 0
        ? AppColors.errorForeground
        : AppColors.primary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryTile(
                  labelKey: 'owner_fin_revenue',
                  value: point.revenue,
                  color: AppColors.blueForeground,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryTile(
                  labelKey: 'owner_fin_collected',
                  value: point.collected,
                  color: AppColors.successForeground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _SummaryTile(
                  labelKey: 'owner_fin_outstanding',
                  value: point.outstanding,
                  color: AppColors.yellowForeground,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryTile(
                  labelKey: 'owner_fin_expenses_section',
                  value: point.expenses,
                  color: AppColors.errorForeground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _SummaryTile(
                  labelKey: 'owner_fin_direct_profit',
                  value: point.profit,
                  color: profitColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryTile(
                  labelKey: 'owner_fin_collection_rate',
                  percent: point.collectionPercent,
                  color: AppColors.teal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.labelKey,
    required this.color,
    this.value,
    this.percent,
  });

  final String labelKey;
  final Color color;
  final double? value;
  final int? percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelKey.tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textSecondaryParagraph,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: percent != null
                ? Text(
                    '$percent%',
                    style: TextStyle(
                      color: color.darken(0.08),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        formatMoney(value ?? 0),
                        style: TextStyle(
                          color: color.darken(0.08),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'owner_currency'.tr,
                        style: TextStyle(
                          color: color.withValues(alpha: 0.7),
                          fontSize: 11,
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

/// "Compared to {previous month}" — the three headline moves the owner cares
/// about, each as a percentage with a good/bad coloured arrow: Revenue,
/// Expenses, Collection Rate. Display-only.
class FinanceMonthComparisonCard extends StatelessWidget {
  const FinanceMonthComparisonCard({
    super.key,
    required this.current,
    required this.previous,
  });

  final MonthlyFinancePoint current;
  final MonthlyFinancePoint previous;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'owner_fin_compared_to'
                .trParams({'month': _monthLabel(previous.year, previous.month)}),
            style: TextStyle(
              color: AppColors.textSecondaryParagraph,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _DeltaTile(
                  labelKey: 'owner_fin_revenue',
                  percent: _relPercent(current.revenue, previous.revenue),
                  upIsGood: true,
                ),
              ),
              const _VDivider(),
              Expanded(
                child: _DeltaTile(
                  labelKey: 'owner_fin_expenses_section',
                  percent: _relPercent(current.expenses, previous.expenses),
                  upIsGood: false,
                ),
              ),
              const _VDivider(),
              Expanded(
                child: _DeltaTile(
                  labelKey: 'owner_fin_collection_rate',
                  percent:
                      current.collectionPercent - previous.collectionPercent,
                  upIsGood: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Relative change as a whole-number percent, or null when there's no base.
  int? _relPercent(double cur, double prev) {
    if (prev <= 0) return null;
    return (((cur - prev) / prev) * 100).round();
  }
}

class _VDivider extends StatelessWidget {
  const _VDivider();

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 52,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        color: const Color(0xFFEEF2F6),
      );
}

class _DeltaTile extends StatelessWidget {
  const _DeltaTile({
    required this.labelKey,
    required this.percent,
    required this.upIsGood,
  });

  final String labelKey;
  final int? percent;
  final bool upIsGood;

  static const _green = Color(0xFF16A34A);
  static const _red = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    final p = percent;
    final flat = p == null || p == 0;
    final up = (p ?? 0) > 0;
    final good = flat ? null : (up == upIsGood);
    final color =
        good == null ? AppColors.textSecondaryParagraph : (good ? _green : _red);

    return Column(
      children: [
        Text(
          labelKey.tr,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondaryParagraph,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        if (p == null)
          Text(
            'owner_fin_compare_na'.tr,
            style: TextStyle(
              color: AppColors.textSecondaryParagraph,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          )
        else if (p == 0)
          Text(
            'owner_fin_compare_flat'.tr,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          )
        else
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  up
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 15,
                  color: color,
                ),
                Text(
                  '${p.abs()}%',
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
