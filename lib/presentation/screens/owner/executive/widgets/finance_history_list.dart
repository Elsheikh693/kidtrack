import 'package:intl/intl.dart' hide TextDirection;
import '../../../../../index/index_main.dart';
import '../models/monthly_finance_point.dart';
import '../models/owner_insight_item.dart';

/// Month-by-month finance history as a clean 4-column table (newest first):
/// month · collected · expenses · net profit, with an up/down marker on profit
/// vs the previous month. Display-only — reads pre-computed points.
class FinanceHistoryList extends StatelessWidget {
  const FinanceHistoryList({
    super.key,
    required this.points,
    this.selectedIndex,
    this.onTapMonth,
  });

  final List<MonthlyFinancePoint> points;

  /// Index into [points] of the currently selected month (highlighted).
  final int? selectedIndex;

  /// Tapping a row selects that month.
  final void Function(int index)? onTapMonth;

  static const _green = Color(0xFF16A34A);
  static const _red = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

    final rows = <Widget>[const _HeaderRow()];
    for (var i = points.length - 1; i >= 0; i--) {
      final prev = i > 0 ? points[i - 1] : null;
      rows.add(_DataRow(
        point: points[i],
        prev: prev,
        green: _green,
        red: _red,
        selected: i == selectedIndex,
        onTap: onTapMonth == null ? null : () => onTapMonth!(i),
      ));
    }

    return Container(
      clipBehavior: Clip.antiAlias,
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
          ...rows,
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                'owner_fin_amounts_note'.tr,
                style: TextStyle(
                  color: AppColors.textSecondaryParagraph.withValues(alpha: 0.8),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          _HCell('owner_fin_col_month', flex: 4, align: TextAlign.start),
          _HCell('owner_fin_collected', flex: 3),
          _HCell('owner_fin_expenses_section', flex: 3),
          _HCell('owner_fin_profit', flex: 3),
        ],
      ),
    );
  }
}

class _HCell extends StatelessWidget {
  const _HCell(this.labelKey, {required this.flex, this.align = TextAlign.end});

  final String labelKey;
  final int flex;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        labelKey.tr,
        textAlign: align,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: AppColors.textSecondaryParagraph,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({
    required this.point,
    required this.green,
    required this.red,
    required this.selected,
    this.prev,
    this.onTap,
  });

  final MonthlyFinancePoint point;
  final MonthlyFinancePoint? prev;
  final Color green;
  final Color red;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final profit = point.profit;
    final profitColor = profit < 0 ? red : green;
    final delta = prev == null ? null : profit - prev!.profit;

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.06) : null,
          border: const Border(top: BorderSide(color: Color(0xFFEEF2F6))),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  if (selected) ...[
                    Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      _monthLabel(point.year, point.month),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textDefault,
                        fontSize: 13,
                        fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _NumCell(value: point.collected, color: green, flex: 3),
            _NumCell(value: point.expenses, color: red, flex: 3),
            _ProfitCell(value: profit, color: profitColor, delta: delta, flex: 3),
          ],
        ),
      ),
    );
  }

  String _monthLabel(int year, int month) =>
      DateFormat.yMMM(Get.locale?.toString()).format(DateTime(year, month));
}

class _NumCell extends StatelessWidget {
  const _NumCell({required this.value, required this.color, required this.flex});

  final double value;
  final Color color;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            formatMoney(value),
            style: TextStyle(
              color: color.darken(0.05),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfitCell extends StatelessWidget {
  const _ProfitCell({
    required this.value,
    required this.color,
    required this.delta,
    required this.flex,
  });

  final double value;
  final Color color;
  final double? delta;
  final int flex;

  @override
  Widget build(BuildContext context) {
    final improved = (delta ?? 0) >= 0;
    return Expanded(
      flex: flex,
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (delta != null && delta != 0) ...[
                Icon(
                  improved
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 13,
                  color: improved ? const Color(0xFF16A34A) : const Color(0xFFEF4444),
                ),
                const SizedBox(width: 1),
              ],
              Text(
                formatMoney(value),
                style: TextStyle(
                  color: color.darken(0.05),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
