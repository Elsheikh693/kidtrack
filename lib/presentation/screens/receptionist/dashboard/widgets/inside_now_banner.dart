import '../../../../../index/index_main.dart';
import '../controller.dart';

const _accent = Color(0xFF0891B2);
const _muted = Color(0xFF8A93A4);
const _line = Color(0xFFEEF0F4);

/// Hero "inside the nursery now" banner — today's live movement at a glance.
class InsideNowBanner extends StatelessWidget {
  final ReceptionistDashboardController controller;
  const InsideNowBanner({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) return const _BannerSkeleton();
      return Container(
        padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 13.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(color: _line),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14.r,
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
                  width: 8.w,
                  height: 8.h,
                  decoration: const BoxDecoration(
                    color: _accent,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 7.w),
                Text(
                  'reception_inside_now_title'.tr,
                  style: context.typography.smSemiBold.copyWith(
                    color: _muted,
                    fontSize: 13.5,
                  ),
                ),
                const Spacer(),
                // Count moved to the end of the title line to shave a full row
                // off the banner height.
                Text(
                  '${controller.insideNow.value}',
                  style: context.typography.xxlBold.copyWith(
                    color: _accent,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: -1,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  'reception_inside_now_unit'.tr,
                  style: context.typography.smSemiBold.copyWith(
                    color: _muted,
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: _accent.withValues(alpha: 0.12)),
              ),
              child: Row(
                children: [
                  _MiniStat(
                    value: controller.presentToday.value,
                    label: 'reception_stat_present'.tr,
                  ),
                  _Divider(),
                  _MiniStat(
                    value: controller.checkedOutToday.value,
                    label: 'reception_stat_checkout'.tr,
                  ),
                  _Divider(),
                  _MiniStat(
                    value: controller.absentToday.value,
                    label: 'reception_stat_absent'.tr,
                  ),
                  _Divider(),
                  _MiniStat(
                    value: controller.totalStudents.value,
                    label: 'reception_stat_total'.tr,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _MiniStat extends StatelessWidget {
  final int value;
  final String label;
  const _MiniStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Text(
              '$value',
              style: context.typography.mdBold.copyWith(
                color: _accent,
                fontSize: 19,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.typography.xsMedium.copyWith(
                color: _muted,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 30.h,
        color: const Color(0xFFE5E7EB),
        margin: EdgeInsets.symmetric(horizontal: 8.w),
      );
}

class _BannerSkeleton extends StatelessWidget {
  const _BannerSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.grayLight,
      highlightColor: AppColors.white,
      child: Container(
        height: 140.h,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(22.r),
        ),
      ),
    );
  }
}
