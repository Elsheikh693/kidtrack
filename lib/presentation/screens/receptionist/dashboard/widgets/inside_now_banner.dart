import '../../../../../index/index_main.dart';
import '../controller.dart';

const _accent = Color(0xFF0891B2);

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
          gradient: const LinearGradient(
            colors: [Color(0xFF0E7490), _accent],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(22.r),
          boxShadow: [
            BoxShadow(
              color: _accent.withValues(alpha: 0.32),
              blurRadius: 18.r,
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
                  width: 8.w,
                  height: 8.h,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 7.w),
                Text(
                  'reception_inside_now_title'.tr,
                  style: context.typography.smSemiBold.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${controller.insideNow.value}',
                  style: context.typography.xxlBold.copyWith(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: -1,
                  ),
                ),
                SizedBox(width: 7.w),
                Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Text(
                    'reception_inside_now_unit'.tr,
                    style: context.typography.smSemiBold.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14.r),
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
                color: Colors.white,
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
                color: Colors.white.withValues(alpha: 0.78),
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
        color: Colors.white.withValues(alpha: 0.2),
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
