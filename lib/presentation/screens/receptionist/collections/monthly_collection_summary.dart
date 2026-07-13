import '../../../../index/index_main.dart';
import 'monthly_payers_view.dart';

const _accent = Color(0xFF7C3AED);
const _green = Color(0xFF16A34A);
const _amber = Color(0xFFD97706);
const _track = Color(0xFFEDE9FE);
const _ink = Color(0xFF111827);
const _muted = Color(0xFF8A93A4);
const _line = Color(0xFFEEF0F4);

/// Finance-tab header summarising this month's subscription collection as
/// **counts** of children: total subscribed, how many paid, how many still owe.
/// Each stat is tappable and opens the matching roster:
///   total → [MonthlyPayersView.all] • paid → [MonthlyPayersView.paid] •
///   remaining → [LatePayersView].
class MonthlyCollectionSummary extends StatefulWidget {
  const MonthlyCollectionSummary({super.key});

  @override
  State<MonthlyCollectionSummary> createState() =>
      _MonthlyCollectionSummaryState();
}

class _MonthlyCollectionSummaryState extends State<MonthlyCollectionSummary> {
  late final CollectionsController controller;

  @override
  void initState() {
    super.initState();
    final alreadyLive = Get.isRegistered<CollectionsController>();
    controller = initController(() => CollectionsController());
    // Refresh when reusing an already-registered instance so the counts reflect
    // any collections recorded since it last loaded.
    if (alreadyLive) controller.loadData();
  }

  void _openTotal() => Get.to(
        () => MonthlyPayersView(
          controller: controller,
          mode: MonthlyPayersMode.all,
        ),
      );

  void _openPaid() => Get.to(
        () => MonthlyPayersView(
          controller: controller,
          mode: MonthlyPayersMode.paid,
        ),
      );

  void _openPartial() => Get.to(
        () => LatePayersView(
          controller: controller,
          mode: LatePayersMode.partial,
        ),
      );

  void _openRemaining() => Get.to(
        () => LatePayersView(
          controller: controller,
          mode: LatePayersMode.unpaid,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) return const _Skeleton();

      final total = controller.totalPayersCount;
      final fullyPaid = controller.fullyPaidCount;
      final partial = controller.partialCount;
      final unpaid = controller.unpaidCount;
      final expected = controller.expectedTotal.value;
      final ratio = expected <= 0
          ? 0.0
          : (controller.collectedTotal.value / expected).clamp(0.0, 1.0);

      return Container(
        margin: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 4.h),
        padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(color: _line),
          boxShadow: [
            BoxShadow(
              color: _accent.withValues(alpha: 0.06),
              blurRadius: 16.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.savings_rounded, color: _accent, size: 18.sp),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'collections_card_title'.tr,
                    style: context.typography.smSemiBold.copyWith(
                      color: _ink,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 8.h,
                backgroundColor: _track,
                valueColor: const AlwaysStoppedAnimation(_green),
              ),
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                _CountStat(
                  label: 'collections_total'.tr,
                  count: total,
                  color: _ink,
                  onTap: _openTotal,
                ),
                _VDivider(),
                _CountStat(
                  label: 'collections_paid_full'.tr,
                  count: fullyPaid,
                  color: _green,
                  onTap: _openPaid,
                ),
                _VDivider(),
                _CountStat(
                  label: 'collections_partial'.tr,
                  count: partial,
                  color: _amber,
                  onTap: _openPartial,
                ),
                _VDivider(),
                _CountStat(
                  label: 'collections_unpaid'.tr,
                  count: unpaid,
                  color: _accent,
                  onTap: _openRemaining,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _CountStat extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final VoidCallback onTap;
  const _CountStat({
    required this.label,
    required this.count,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Text(
              '$count',
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
              textAlign: TextAlign.center,
              style: context.typography.xsMedium.copyWith(
                color: _muted,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 30.h,
        color: _line,
        margin: EdgeInsets.symmetric(horizontal: 3.w),
      );
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.grayLight,
      highlightColor: AppColors.white,
      child: Container(
        height: 140.h,
        margin: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 4.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(22.r),
        ),
      ),
    );
  }
}
