import '../../../../index/index_main.dart';

class NotifToggleTile extends StatelessWidget {
  const NotifToggleTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(13)),
            child: Icon(icon, color: iconColor, size: 22.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.typography.smSemiBold.copyWith(color: AppColors.textDefault),
                ),
                SizedBox(height: 3.h),
                Text(
                  subtitle,
                  style: context.typography.xsRegular.copyWith(
                    color: AppColors.textSecondaryParagraph,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.white,
            activeTrackColor: AppColors.primary,
            inactiveThumbColor: AppColors.grayMedium,
            inactiveTrackColor: AppColors.backgroundNeutral100,
          ),
        ],
      ),
    );
  }
}
