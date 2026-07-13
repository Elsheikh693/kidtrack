import '../../../../../index/index_main.dart';

/// A single tappable row inside a More-tab section card: a rounded colored icon
/// chip, the label, an optional count badge, and a trailing chevron. Rendered
/// full-width so sparse sections still read as clean, filled list rows.
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
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: color, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                labelKey.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.typography.smSemiBold
                    .copyWith(color: AppColors.textDefault),
              ),
            ),
            if (badgeCount > 0) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                constraints: BoxConstraints(minWidth: 20.w),
                decoration: BoxDecoration(
                  color: AppColors.activityRed,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '$badgeCount',
                  textAlign: TextAlign.center,
                  style: context.typography.xsMedium
                      .copyWith(color: AppColors.white),
                ),
              ),
              SizedBox(width: 8.w),
            ],
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14.sp, color: AppColors.grayMedium),
          ],
        ),
      ),
    );
  }
}
