import '../../../../index/index_main.dart';
import '../widgets/manager_tab_header.dart';
import '../finance/models/monthly_payment_row.dart';
import '../finance/widgets/finance_shimmer.dart';

/// Manager Payments screen — one monthly subscription/enrollment ledger.
/// Top: a month stepper (browse past months = "reports") with a collected /
/// remaining summary. Below: every child billed that month, paid or owing.
class ManagerFinanceTab extends StatefulWidget {
  const ManagerFinanceTab({super.key});

  @override
  State<ManagerFinanceTab> createState() => _ManagerFinanceTabState();
}

class _ManagerFinanceTabState extends State<ManagerFinanceTab> {
  static const _accent = AppColors.activityAmberBrand;
  static const _paidColor = AppColors.activityGreen;

  late final ManagerFinanceController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ManagerFinanceController>();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ManagerTabHeader(
          title: 'manager_finance_payments_title'.tr,
          accent: _accent,
          onBack: () => Get.find<MainPageViewModel>().changePage(0),
        ),
        Expanded(
          child: Obx(
            () => controller.isLoading.value
                ? const FinanceShimmer()
                : RefreshIndicator(
                    onRefresh: controller.loadData,
                    color: _accent,
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              _MonthSummaryCard(
                                  controller: controller, accent: _accent),
                              SizedBox(height: 16.h),
                              _FilterRow(controller: controller, accent: _accent),
                              SizedBox(height: 12.h),
                              _SearchField(controller: controller),
                              SizedBox(height: 8.h),
                            ]),
                          ),
                        ),
                        _RowsSliver(
                          controller: controller,
                          accent: _accent,
                          paidColor: _paidColor,
                        ),
                        SliverToBoxAdapter(child: SizedBox(height: 100.h)),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

// ─── Month navigator + collected/remaining summary ─────────────────────────
class _MonthSummaryCard extends StatelessWidget {
  const _MonthSummaryCard({required this.controller, required this.accent});

  final ManagerFinanceController controller;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Month stepper. In RTL the first child sits on the right, so the
          // "previous/older" arrow lands on the right and "next" on the left.
          Row(
            children: [
              _StepButton(
                icon: Icons.chevron_right_rounded,
                accent: accent,
                enabled: true,
                onTap: controller.previousMonth,
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      controller.monthLabel,
                      textAlign: TextAlign.center,
                      style: context.typography.mdBold
                          .copyWith(color: AppColors.textDefault),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'manager_finance_payments_subtitle'.tr,
                      textAlign: TextAlign.center,
                      style: context.typography.xsRegular.copyWith(
                        color: AppColors.textSecondaryParagraph,
                        fontSize: 11.5.sp,
                      ),
                    ),
                  ],
                ),
              ),
              _StepButton(
                icon: Icons.chevron_left_rounded,
                accent: accent,
                enabled: controller.canGoForward,
                onTap: controller.nextMonth,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: 'manager_finance_collected'.tr,
                  amount: controller.monthCollected,
                  color: AppColors.activityGreen,
                ),
              ),
              Container(
                width: 1,
                height: 38.h,
                color: AppColors.dividerAndLines.withValues(alpha: 0.6),
              ),
              Expanded(
                child: _Metric(
                  label: 'manager_finance_remaining'.tr,
                  amount: controller.monthRemaining,
                  color: accent,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          _ProgressBar(rate: controller.monthCollectionRate, accent: accent),
          SizedBox(height: 8.h),
          Text(
            'manager_finance_paid_due_summary'.trParams({
              'paid': '${controller.paidCount}',
              'due': '${controller.dueCount}',
            }),
            style: context.typography.xsRegular.copyWith(
              color: AppColors.textSecondaryParagraph,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.accent,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final Color accent;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 38.w,
        height: 38.w,
        decoration: BoxDecoration(
          color: enabled
              ? accent.withValues(alpha: 0.12)
              : AppColors.grayLight.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          icon,
          size: 22.sp,
          color: enabled ? accent : AppColors.grayMedium,
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.amount, required this.color});

  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: context.typography.xsRegular.copyWith(
            color: AppColors.textSecondaryParagraph,
            fontSize: 12.sp,
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              formatAmount(amount),
              style: context.typography.xsRegular.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 18.sp,
                color: color,
              ),
            ),
            SizedBox(width: 3.w),
            Text(
              'manager_finance_currency'.tr,
              style: context.typography.xsRegular.copyWith(
                color: color.withValues(alpha: 0.8),
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.rate, required this.accent});

  final int rate;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Stack(
        children: [
          Container(height: 8.h, color: AppColors.grayLight.withValues(alpha: 0.5)),
          FractionallySizedBox(
            widthFactor: (rate / 100).clamp(0.0, 1.0),
            child: Container(height: 8.h, color: AppColors.activityGreen),
          ),
        ],
      ),
    );
  }
}

// ─── Filter chips ──────────────────────────────────────────────────────────
class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.controller, required this.accent});

  final ManagerFinanceController controller;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final active = controller.rowFilter.value;
      return Row(
        children: [
          _Chip(
            label: 'manager_finance_filter_all'.tr,
            selected: active == 'all',
            accent: accent,
            onTap: () => controller.onFilter('all'),
          ),
          SizedBox(width: 8.w),
          _Chip(
            label: 'manager_finance_filter_due'.tr,
            selected: active == 'due',
            accent: accent,
            onTap: () => controller.onFilter('due'),
          ),
          SizedBox(width: 8.w),
          _Chip(
            label: 'manager_finance_filter_paid'.tr,
            selected: active == 'paid',
            accent: AppColors.activityGreen,
            onTap: () => controller.onFilter('paid'),
          ),
        ],
      );
    });
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: selected ? accent : AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected
                ? accent
                : AppColors.dividerAndLines.withValues(alpha: 0.8),
          ),
        ),
        child: Text(
          label,
          style: context.typography.xsRegular.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 13.sp,
            color: selected ? AppColors.white : AppColors.textSecondaryParagraph,
          ),
        ),
      ),
    );
  }
}

// ─── Search ────────────────────────────────────────────────────────────────
class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final ManagerFinanceController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.dividerAndLines.withValues(alpha: 0.8),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 20.sp, color: AppColors.grayMedium),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              onChanged: controller.onSearch,
              style: context.typography.smRegular
                  .copyWith(color: AppColors.textDefault, fontSize: 13.5.sp),
              decoration: InputDecoration(
                hintText: 'manager_finance_search_hint'.tr,
                hintStyle: context.typography.smRegular.copyWith(
                  color: AppColors.fieldTextPlaceholder,
                  fontSize: 13.5.sp,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Per-child rows ────────────────────────────────────────────────────────
class _RowsSliver extends StatelessWidget {
  const _RowsSliver({
    required this.controller,
    required this.accent,
    required this.paidColor,
  });

  final ManagerFinanceController controller;
  final Color accent;
  final Color paidColor;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rows = controller.monthRows;
      if (rows.isEmpty) {
        return SliverToBoxAdapter(child: _Empty(controller: controller));
      }
      return SliverPadding(
        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: _PaymentRow(
                row: rows[i],
                accent: accent,
                paidColor: paidColor,
              ),
            ),
            childCount: rows.length,
          ),
        ),
      );
    });
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({
    required this.row,
    required this.accent,
    required this.paidColor,
  });

  final MonthlyPaymentRow row;
  final Color accent;
  final Color paidColor;

  String get _initial {
    final t = row.childName.trim();
    return t.isEmpty ? '؟' : t.characters.first;
  }

  @override
  Widget build(BuildContext context) {
    final color = row.isPaid ? paidColor : accent;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Text(
              _initial,
              style: context.typography.smSemiBold.copyWith(color: color),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.childName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.smSemiBold
                      .copyWith(color: AppColors.textDefault),
                ),
                SizedBox(height: 2.h),
                Text(
                  row.parentName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.xsRegular.copyWith(
                    color: AppColors.textSecondaryParagraph,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          row.isPaid
              ? _PaidBadge(color: paidColor)
              : _AmountBadge(amount: row.remaining, color: accent),
        ],
      ),
    );
  }
}

class _PaidBadge extends StatelessWidget {
  const _PaidBadge({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, color: color, size: 14.sp),
          SizedBox(width: 4.w),
          Text(
            'manager_finance_status_paid'.tr,
            style: context.typography.xsRegular.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 12.5.sp,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountBadge extends StatelessWidget {
  const _AmountBadge({required this.amount, required this.color});

  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            formatAmount(amount),
            style: context.typography.xsRegular.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 14.sp,
              color: color,
            ),
          ),
          SizedBox(width: 3.w),
          Text(
            'manager_finance_currency'.tr,
            style: context.typography.xsRegular.copyWith(
              color: color.withValues(alpha: 0.8),
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.controller});

  final ManagerFinanceController controller;

  @override
  Widget build(BuildContext context) {
    // Distinguish "no billing this month at all" from "filter hid everything".
    final noneAtAll = controller.monthChildCount == 0;
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 40.h, 24.w, 24.h),
      child: Column(
        children: [
          Icon(
            noneAtAll
                ? Icons.receipt_long_rounded
                : Icons.search_off_rounded,
            size: 56.sp,
            color: AppColors.grayLight,
          ),
          SizedBox(height: 12.h),
          Text(
            noneAtAll
                ? 'manager_finance_month_empty'.tr
                : 'manager_finance_filter_empty'.tr,
            textAlign: TextAlign.center,
            style: context.typography.smMedium
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
        ],
      ),
    );
  }
}
