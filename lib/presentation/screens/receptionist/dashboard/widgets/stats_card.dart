import '../../../../../index/index_main.dart';

class DashboardStatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const DashboardStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 38.w,
            height: 38.h,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18.sp),
          ),
          SizedBox(height: 6.h),
          Text(
            value.toString(),
            style: context.typography.xlBold.copyWith(
              color: color,
              height: 1,
            ),
          ),
          SizedBox(height: 3.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.typography.xsMedium.copyWith(
                color: AppColors.textSecondaryParagraph,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
