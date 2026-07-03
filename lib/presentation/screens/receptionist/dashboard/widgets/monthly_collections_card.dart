import '../../../../../index/index_main.dart';

const _accent = Color(0xFF7C3AED);
const _track = Color(0xFFEDE9FE);

/// Home card summarising this month's parent-fee collection: expected vs
/// collected vs remaining. Tapping "remaining" opens the late-payers list.
class MonthlyCollectionsCard extends StatefulWidget {
  const MonthlyCollectionsCard({super.key});

  @override
  State<MonthlyCollectionsCard> createState() => _MonthlyCollectionsCardState();
}

class _MonthlyCollectionsCardState extends State<MonthlyCollectionsCard> {
  late final CollectionsController controller;

  @override
  void initState() {
    super.initState();
    final alreadyLive = Get.isRegistered<CollectionsController>();
    controller = initController(() => CollectionsController());
    if (alreadyLive) controller.loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) return const _CardSkeleton();

      final expected = controller.expectedTotal.value;
      final collected = controller.collectedTotal.value;
      final remaining = controller.remainingTotal;
      final ratio = expected <= 0 ? 0.0 : (collected / expected).clamp(0.0, 1.0);

      return Container(
        padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(color: const Color(0xFFEEF0F4)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.06),
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
                  width: 34.w,
                  height: 34.h,
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.savings_rounded,
                      color: _accent, size: 19.sp),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'collections_card_title'.tr,
                        style: context.typography.smSemiBold.copyWith(
                          color: const Color(0xFF111827),
                          fontSize: 14.5,
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
                          color: const Color(0xFF8A93A4),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Progress bar collected / expected
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 9.h,
                backgroundColor: _track,
                valueColor: const AlwaysStoppedAnimation(_accent),
              ),
            ),
            SizedBox(height: 14.h),

            Row(
              children: [
                _Stat(
                  label: 'collections_expected'.tr,
                  amount: expected,
                  color: const Color(0xFF111827),
                ),
                _VDivider(),
                _Stat(
                  label: 'collections_collected'.tr,
                  amount: collected,
                  color: const Color(0xFF16A34A),
                ),
                _VDivider(),
                _Stat(
                  label: 'collections_remaining'.tr,
                  amount: remaining,
                  color: _accent,
                  onTap: () => Get.toNamed(latePayersView),
                  showChevron: remaining > 0,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final VoidCallback? onTap;
  final bool showChevron;
  const _Stat({
    required this.label,
    required this.amount,
    required this.color,
    this.onTap,
    this.showChevron = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
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
                ),
                if (showChevron) ...[
                  SizedBox(width: 2.w),
                  Icon(Icons.chevron_right_rounded, size: 16.sp, color: color),
                ],
              ],
            ),
            SizedBox(height: 5.h),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.typography.xsMedium.copyWith(
                color: const Color(0xFF8A93A4),
                fontSize: 11,
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
        color: const Color(0xFFEEF0F4),
        margin: EdgeInsets.symmetric(horizontal: 6.w),
      );
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.grayLight,
      highlightColor: AppColors.white,
      child: Container(
        height: 150.h,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(22.r),
        ),
      ),
    );
  }
}
