import '../../../../../index/index_main.dart';

/// A single tappable grid cell inside a More-tab section card: a rounded
/// colored icon with its label underneath. Compact enough to fit three across.
class ManagerGridTile extends StatelessWidget {
  const ManagerGridTile({
    super.key,
    required this.icon,
    required this.color,
    required this.labelKey,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final Color color;
  final String labelKey;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 52.w,
                  height: 52.w,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(icon, color: color, size: 24.sp),
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -4.h,
                    right: -4.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 1.h,
                      ),
                      constraints: BoxConstraints(minWidth: 18.w),
                      decoration: BoxDecoration(
                        color: AppColors.activityRed,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: AppColors.white, width: 1.5),
                      ),
                      child: Text(
                        '$badgeCount',
                        textAlign: TextAlign.center,
                        style: context.typography.xsMedium
                            .copyWith(color: AppColors.white),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              labelKey.tr,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.typography.xsMedium
                  .copyWith(color: AppColors.textDefault, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }
}
