import '../../../../../index/index_main.dart';

/// One row in the parent "محتاج انتباهك" screen: a coloured status bar, an icon
/// chip, a title, an optional subtitle, and a chevron. Tapping runs [onTap].
class AttentionCard extends StatelessWidget {
  const AttentionCard({
    super.key,
    required this.color,
    required this.icon,
    required this.title,
    this.subtitle,
    this.subIsAlert = false,
    this.onTap,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool subIsAlert;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFEEF0F4)),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 5.w,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius:
                      BorderRadius.horizontal(right: Radius.circular(16.r)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Row(
                    children: [
                      Container(
                        width: 38.w,
                        height: 38.h,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(11.r),
                        ),
                        child: Icon(icon, color: color, size: 19.sp),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: context.typography.smSemiBold
                                  .copyWith(color: AppColors.textDefault),
                            ),
                            if (subtitle != null &&
                                subtitle!.isNotEmpty) ...[
                              SizedBox(height: 5.h),
                              Text(
                                subtitle!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: context.typography.xsRegular.copyWith(
                                  color: subIsAlert
                                      ? AppColors.errorForeground
                                      : AppColors.grayMedium,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.chevron_right_rounded,
                          color: AppColors.grayMedium, size: 22.sp),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
