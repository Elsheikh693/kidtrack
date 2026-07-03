import 'package:intl/intl.dart' hide TextDirection;
import '../../../index/index_main.dart';
import 'expenses/expense_form_sheet.dart';
import 'expenses/all_expenses_screen.dart';
import 'collections/all_collections_screen.dart';

const _accent = Color(0xFF7C3AED);
const _revenue = Color(0xFF16A34A);
const _expense = Color(0xFFDC2626);
const _profit = Color(0xFF2563EB);
const _ink = Color(0xFF1E293B);
const _muted = Color(0xFF94A3B8);
const _line = Color(0xFFEEF0F4);

/// The shared owner/manager finance dashboard content (no app chrome — each role
/// wraps it with its own AppBar/header). Reads a [FinanceDashboardController]
/// resolved by [tag], so owner and manager keep separate scoped instances.
class FinanceDashboardBody extends StatelessWidget {
  final String tag;
  const FinanceDashboardBody({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FinanceDashboardController>(tag: tag);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: _accent));
        }
        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 120.h),
          children: [
            _MonthBar(controller: controller),
            SizedBox(height: 16.h),
            _KpiTrio(summary: controller.summary.value),
            SizedBox(height: 22.h),
            _RevenueSplit(categories: controller.categories),
            SizedBox(height: 22.h),
            _RecentCollections(controller: controller, tag: tag),
            SizedBox(height: 22.h),
            _RecentExpenses(controller: controller, tag: tag),
          ],
        );
      }),
    );
  }
}

// ── Month bar ─────────────────────────────────────────────────────────────────

class _MonthBar extends StatelessWidget {
  final FinanceDashboardController controller;
  const _MonthBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          // In RTL the first child sits on the right → "previous/older" arrow.
          _StepBtn(icon: Icons.chevron_right_rounded, onTap: controller.previousMonth),
          Expanded(
            child: Text(
              controller.monthLabel,
              textAlign: TextAlign.center,
              style: context.typography.smSemiBold.copyWith(
                color: _ink,
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _StepBtn(
            icon: Icons.chevron_left_rounded,
            enabled: controller.canGoForward,
            onTap: controller.nextMonth,
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _StepBtn({required this.icon, this.enabled = true, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: enabled
              ? _accent.withValues(alpha: 0.10)
              : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(icon,
            size: 22.sp, color: enabled ? _accent : const Color(0xFFCBD5E1)),
      ),
    );
  }
}

// ── KPI trio ──────────────────────────────────────────────────────────────────

class _KpiTrio extends StatelessWidget {
  final FinanceSummary summary;
  const _KpiTrio({required this.summary});

  @override
  Widget build(BuildContext context) {
    // IntrinsicHeight gives the Row a bounded height so CrossAxisAlignment.stretch
    // (equal-height cards) is valid. Without it the Row's height is unbounded
    // inside the ListView, stretch forces an infinite height, and the failed
    // layout leaves dirty parent data that then floods the semantics flush every
    // frame (`!semantics.parentDataDirty`).
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _KpiCard(
              label: 'finance_dash_revenue'.tr,
              amount: summary.revenue,
              color: _revenue,
              icon: Icons.trending_up_rounded,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _KpiCard(
              label: 'finance_dash_expenses'.tr,
              amount: summary.expenses,
              color: _expense,
              icon: Icons.trending_down_rounded,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _KpiCard(
              label: 'finance_dash_net_profit'.tr,
              amount: summary.netProfit,
              color: _profit,
              icon: Icons.account_balance_wallet_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  const _KpiCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: _line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 18.sp, color: color),
          ),
          SizedBox(height: 10.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              formatAmount(amount),
              style: context.typography.mdBold.copyWith(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.typography.xsRegular
                .copyWith(color: _muted, fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}

// ── Revenue split by category ─────────────────────────────────────────────────

class _RevenueSplit extends StatelessWidget {
  final List<CategoryRevenue> categories;
  const _RevenueSplit({required this.categories});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'finance_dash_revenue_split'.tr),
        SizedBox(height: 12.h),
        if (categories.isEmpty)
          _EmptyHint(text: 'finance_dash_no_collections'.tr)
        else
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: categories
                .map((c) => _CategoryCard(data: c))
                .toList(),
          ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryRevenue data;
  const _CategoryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final width = (1.sw - 32.w - 10.w) / 2;
    return Container(
      width: width,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.categoryName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.typography.smSemiBold
                .copyWith(color: _ink, fontSize: 14),
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatAmount(data.total),
                style: context.typography.smSemiBold.copyWith(
                  color: _accent,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(width: 3.w),
              Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: Text(
                  'currency'.tr,
                  style: context.typography.xsRegular
                      .copyWith(color: _accent.withValues(alpha: 0.8), fontSize: 11),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'finance_dash_operations'
                .trParams({'count': '${data.transactionsCount}'}),
            style: context.typography.xsRegular
                .copyWith(color: _muted, fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}

// ── Recent collections ────────────────────────────────────────────────────────

class _RecentCollections extends StatelessWidget {
  final FinanceDashboardController controller;
  final String tag;
  const _RecentCollections({required this.controller, required this.tag});

  @override
  Widget build(BuildContext context) {
    final items = controller.recentCollections;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: 'finance_dash_recent_collections'.tr,
          actionLabel: items.isEmpty ? null : 'finance_dash_view_all'.tr,
          onAction: () => Get.to(() => AllCollectionsScreen(tag: tag)),
        ),
        SizedBox(height: 12.h),
        if (items.isEmpty)
          _EmptyHint(text: 'finance_dash_no_collections'.tr)
        else
          ...items.map((c) => Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: CollectionTile(item: c),
              )),
      ],
    );
  }
}

/// Shared collection row — used by the dashboard and the full list screen.
class CollectionTile extends StatelessWidget {
  final RecentCollection item;
  const CollectionTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _revenue.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Text(
              item.childName.trim().isEmpty
                  ? '؟'
                  : item.childName.trim().characters.first,
              style: context.typography.mdBold
                  .copyWith(color: _revenue, fontSize: 16),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.childName.isEmpty
                      ? 'finance_unknown_child'.tr
                      : item.childName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.smSemiBold
                      .copyWith(color: _ink, fontSize: 14.5),
                ),
                SizedBox(height: 2.h),
                Text(
                  item.categoryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.xsRegular
                      .copyWith(color: _muted, fontSize: 12),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.person_outline_rounded,
                        size: 12.sp, color: _muted),
                    SizedBox(width: 3.w),
                    Flexible(
                      child: Text(
                        '${'finance_dash_collected_by'.tr} ${item.collectedBy.isEmpty ? 'finance_unknown_staff'.tr : item.collectedBy}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.typography.xsRegular
                            .copyWith(color: _muted, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${formatAmount(item.amount)} ${'currency'.tr}',
                style: context.typography.smSemiBold.copyWith(
                  color: _revenue,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                DateFormat('d MMM', isAr ? 'ar' : 'en').format(item.date),
                style: context.typography.xsRegular
                    .copyWith(color: _muted, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Recent expenses ───────────────────────────────────────────────────────────

class _RecentExpenses extends StatelessWidget {
  final FinanceDashboardController controller;
  final String tag;
  const _RecentExpenses({required this.controller, required this.tag});

  @override
  Widget build(BuildContext context) {
    final items = controller.recentExpenses;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: 'finance_dash_recent_expenses'.tr,
          actionLabel: items.isEmpty ? null : 'finance_dash_view_all'.tr,
          onAction: () => Get.to(() => AllExpensesScreen(tag: tag)),
        ),
        SizedBox(height: 12.h),
        _AddExpenseButton(controller: controller),
        SizedBox(height: 12.h),
        if (items.isEmpty)
          _EmptyHint(text: 'finance_dash_no_expenses'.tr)
        else
          ...items.map((e) => Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: ExpenseTile(item: e),
              )),
      ],
    );
  }
}

class _AddExpenseButton extends StatelessWidget {
  final FinanceDashboardController controller;
  const _AddExpenseButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showExpenseFormSheet(controller: controller),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 13.h),
        decoration: BoxDecoration(
          color: _expense.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: _expense.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 20.sp, color: _expense),
            SizedBox(width: 6.w),
            Text(
              'finance_dash_add_expense'.tr,
              style: context.typography.smSemiBold.copyWith(
                color: _expense,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared expense row — used by the dashboard and the full list screen.
class ExpenseTile extends StatelessWidget {
  final RecentExpense item;
  final VoidCallback? onDelete;
  const ExpenseTile({super.key, required this.item, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: _expense.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.receipt_long_rounded,
                size: 20.sp, color: _expense),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.smSemiBold
                      .copyWith(color: _ink, fontSize: 14.5),
                ),
                SizedBox(height: 3.h),
                Text(
                  DateFormat('d MMM yyyy', isAr ? 'ar' : 'en')
                      .format(item.date),
                  style: context.typography.xsRegular
                      .copyWith(color: _muted, fontSize: 12),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            '${formatAmount(item.amount)} ${'currency'.tr}',
            style: context.typography.smSemiBold.copyWith(
              color: _expense,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (onDelete != null) ...[
            SizedBox(width: 6.w),
            GestureDetector(
              onTap: onDelete,
              behavior: HitTestBehavior.opaque,
              child: Icon(Icons.delete_outline_rounded,
                  size: 20.sp, color: _muted),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Shared bits ───────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const _SectionTitle({required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: context.typography.smSemiBold.copyWith(
              color: _ink,
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            behavior: HitTestBehavior.opaque,
            child: Text(
              actionLabel!,
              style: context.typography.xsMedium
                  .copyWith(color: _accent, fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _line),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: context.typography.xsRegular.copyWith(color: _muted, fontSize: 13),
      ),
    );
  }
}
