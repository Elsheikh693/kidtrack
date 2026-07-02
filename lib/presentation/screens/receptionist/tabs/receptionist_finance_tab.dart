import 'package:intl/intl.dart';
import '../../../../index/index_main.dart';

const _accent = Color(0xFF7C3AED);
const _track = Color(0xFFEDE9FE);
const _bg = Color(0xFFF6F7FB);
const _ink = Color(0xFF111827);
const _muted = Color(0xFF8A93A4);
const _line = Color(0xFFEEF0F4);
const _green = Color(0xFF16A34A);

/// Receptionist "الماليات" tab — a focused monthly fee-collection screen.
///
/// Uses its own month-aware [CollectionsController] instance (tagged) so
/// browsing past months here never disturbs the home "تحصيل هذا الشهر" card,
/// which keeps the shared current-month instance.
class ReceptionistFinanceTab extends StatefulWidget {
  const ReceptionistFinanceTab({super.key});

  @override
  State<ReceptionistFinanceTab> createState() => _ReceptionistFinanceTabState();
}

class _ReceptionistFinanceTabState extends State<ReceptionistFinanceTab> {
  static const _tag = 'reception_finance';
  late final CollectionsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<CollectionsController>(tag: _tag)
        ? Get.find<CollectionsController>(tag: _tag)
        : Get.put(CollectionsController(), tag: _tag, permanent: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        automaticallyImplyLeading: false,
        title: Text(
          'finance_dashboard_title'.tr,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: _ink,
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => Get.toNamed(paymentCategoriesView),
            child: const Icon(Icons.sell_outlined,
                size: 23, color: Color(0xFF374151)),
          ),
          const SizedBox(width: 14),
          GestureDetector(
            onTap: () => Get.toNamed(notificationsView),
            child: const Icon(Icons.notifications_none_rounded,
                size: 24, color: Color(0xFF374151)),
          ),
          const SizedBox(width: 14),
          GestureDetector(
            onTap: () => Get.toNamed(settingsView),
            child: const Icon(Icons.settings_outlined,
                size: 24, color: Color(0xFF374151)),
          ),
          const SizedBox(width: 18),
        ],
      ),
      body: Stack(
        children: [
          Obx(() {
            if (controller.isLoading.value) return const _LoadingSkeleton();
            return RefreshIndicator(
              color: _accent,
              onRefresh: controller.loadData,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 96.h),
                children: [
                  _MonthBar(controller: controller),
                  SizedBox(height: 16.h),
                  _HeroCard(controller: controller),
                  SizedBox(height: 22.h),
                  _OutstandingSection(controller: controller),
                ],
              ),
            );
          }),
          Positioned(
            bottom: 18.h,
            left: 20.w,
            child: _AddButton(onTap: _openAddSheet),
          ),
        ],
      ),
    );
  }

  // ── Add flow ────────────────────────────────────────────────────────────────

  /// Reception's only finance action is recording a collected cash payment,
  /// so the (+) button opens that sheet directly.
  Future<void> _openAddSheet() async {
    final pc = initController(() => PaymentController());
    final session = SessionService();
    await Get.bottomSheet(
      ReceptionPaymentSheet(
        nurseryId: session.nurseryId ?? '',
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
    );
    pc.loadData();
    controller.loadData();
  }
}

// ── Month selector ────────────────────────────────────────────────────────────

class _MonthBar extends StatelessWidget {
  final CollectionsController controller;
  const _MonthBar({required this.controller});

  Future<void> _pick(BuildContext context) async {
    final picked = await showAppDatePicker(
      context,
      initialDate: controller.selectedMonth.value,
      minimumDate: DateTime(DateTime.now().year - 2),
      maximumDate: DateTime(DateTime.now().year + 1, 12, 31),
    );
    if (picked != null) controller.setMonth(picked);
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';
    return GestureDetector(
      onTap: () => _pick(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: _line),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month_rounded, size: 19.sp, color: _accent),
            SizedBox(width: 10.w),
            Expanded(
              child: Obx(
                () => Text(
                  DateFormat('MMMM yyyy', isAr ? 'ar' : 'en')
                      .format(controller.selectedMonth.value),
                  style: context.typography.smSemiBold.copyWith(
                    color: _ink,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 22.sp, color: _muted),
          ],
        ),
      ),
    );
  }
}

// ── Loading skeleton ──────────────────────────────────────────────────────────

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE9ECF2),
      highlightColor: const Color(0xFFF7F8FB),
      period: const Duration(milliseconds: 1100),
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
        children: [
          Container(
            height: 48.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            height: 230.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
            ),
          ),
          SizedBox(height: 22.h),
          Container(
            height: 76.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18.r),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero summary card ─────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final CollectionsController controller;
  const _HeroCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final expected = controller.expectedTotal.value;
    final collected = controller.collectedTotal.value;
    final remaining = controller.remainingTotal;
    final ratio = expected <= 0 ? 0.0 : (collected / expected).clamp(0.0, 1.0);
    final currency = 'overdue_currency'.tr;

    return Container(
      padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 18.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: _line),
        boxShadow: [
          BoxShadow(
            color: _accent.withValues(alpha: 0.07),
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Icon(Icons.savings_rounded, color: _accent, size: 20.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'collections_card_title'.tr,
                      style: context.typography.smSemiBold.copyWith(
                        color: _ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'collections_scope'.trParams({
                        'families': '${controller.familiesCount.value}',
                        'children': '${controller.childrenCount.value}',
                      }),
                      style: context.typography.xsRegular.copyWith(
                        color: _muted,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                remaining.toStringAsFixed(0),
                style: context.typography.mdBold.copyWith(
                  color: _accent,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: -1,
                ),
              ),
              SizedBox(width: 6.w),
              Padding(
                padding: EdgeInsets.only(bottom: 5.h),
                child: Text(
                  currency,
                  style: context.typography.smSemiBold.copyWith(
                    color: _accent,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'collections_remaining_hint'.tr,
            style: context.typography.xsMedium.copyWith(
              color: _muted,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 16.h),

          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 9.h,
              backgroundColor: _track,
              valueColor: const AlwaysStoppedAnimation(_accent),
            ),
          ),
          SizedBox(height: 16.h),

          Row(
            children: [
              _MiniStat(
                label: 'collections_collected'.tr,
                amount: collected,
                color: _green,
              ),
              Container(
                width: 1,
                height: 30.h,
                color: _line,
                margin: EdgeInsets.symmetric(horizontal: 6.w),
              ),
              _MiniStat(
                label: 'collections_expected'.tr,
                amount: expected,
                color: _ink,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  const _MiniStat({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            amount.toStringAsFixed(0),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.typography.mdBold.copyWith(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.typography.xsMedium.copyWith(
              color: _muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Outstanding section ───────────────────────────────────────────────────────

class _OutstandingSection extends StatelessWidget {
  final CollectionsController controller;
  const _OutstandingSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final payers = controller.latePayers;
    final expected = controller.expectedTotal.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4.w,
              height: 18.h,
              decoration: BoxDecoration(
                color: _accent,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'collections_outstanding_title'.tr,
              style: context.typography.smSemiBold.copyWith(
                color: _ink,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        if (expected <= 0)
          const _EmptyCard(
            icon: Icons.receipt_long_rounded,
            color: _muted,
            title: 'collections_no_dues',
            hint: 'collections_no_dues_hint',
          )
        else if (payers.isEmpty)
          const _EmptyCard(
            icon: Icons.verified_rounded,
            color: _green,
            title: 'collections_all_collected',
            hint: 'collections_all_collected_hint',
          )
        else
          _LateRow(
            count: payers.length,
            remaining: controller.remainingTotal,
            onTap: () =>
                Get.to(() => LatePayersView(controller: controller)),
          ),
      ],
    );
  }
}

class _LateRow extends StatelessWidget {
  final int count;
  final double remaining;
  final VoidCallback onTap;
  const _LateRow({
    required this.count,
    required this.remaining,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = 'collections_late_row_subtitle'.trParams({
      'count': '$count',
      'amount': '${remaining.toStringAsFixed(0)} ${'overdue_currency'.tr}',
    });
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: _line),
        ),
        child: Row(
          children: [
            Container(
              width: 42.w,
              height: 42.h,
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.warning_amber_rounded,
                  color: const Color(0xFFDC2626), size: 22.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'collections_late_title'.tr,
                    style: context.typography.smSemiBold.copyWith(
                      color: _ink,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.typography.xsRegular.copyWith(
                      color: _muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.chevron_right_rounded, size: 24.sp, color: _muted),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String hint;
  const _EmptyCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: _line),
      ),
      child: Column(
        children: [
          Container(
            width: 64.w,
            height: 64.h,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32.sp, color: color),
          ),
          SizedBox(height: 14.h),
          Text(
            title.tr,
            style: context.typography.smSemiBold.copyWith(
              color: _ink,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            hint.tr,
            textAlign: TextAlign.center,
            style: context.typography.xsRegular.copyWith(
              color: _muted,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Add button ────────────────────────────────────────────────────────────────

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _accent,
      borderRadius: BorderRadius.circular(30.r),
      elevation: 4,
      shadowColor: _accent.withValues(alpha: 0.4),
      child: InkWell(
        borderRadius: BorderRadius.circular(30.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, color: Colors.white, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'collections_add'.tr,
                style: context.typography.smSemiBold
                    .copyWith(color: Colors.white, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

