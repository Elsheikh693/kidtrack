import '../../../../../index/index_main.dart';

/// Home entry point for the "Star of the Week" feature: a premium gold banner
/// on the manager dashboard that opens the picker.
class StarDashboardCard extends StatelessWidget {
  const StarDashboardCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(starOfWeekView),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF5C542), Color(0xFFE0A100)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE0A100).withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(Icons.emoji_events_rounded,
                  color: Colors.white, size: 26.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: 'sotw_entry_title'.tr,
                    textStyle: context.typography.mdBold
                        .copyWith(color: Colors.white),
                  ),
                  SizedBox(height: 3.h),
                  AppText(
                    text: 'sotw_entry_subtitle'.tr,
                    maxLines: 2,
                    textStyle: context.typography.xsRegular.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white.withValues(alpha: 0.9), size: 16.sp),
          ],
        ),
      ),
    );
  }
}
