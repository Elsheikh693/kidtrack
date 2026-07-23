import '../../../../../index/index_main.dart';

/// Shows the branch's current Star of the Week at the top of the picker, so the
/// manager can see who's already celebrated this week (and replay the reveal).
class StarCurrentBanner extends StatelessWidget {
  const StarCurrentBanner({
    super.key,
    required this.star,
    required this.onTap,
  });

  final StarOfWeekModel star;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 4.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4527A0), Color(0xFF7E5BEF)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4527A0).withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5C542),
                    shape: BoxShape.circle,
                  ),
                  child: ChildAvatar(
                    name: star.childName,
                    imageUrl: star.childPhotoUrl,
                    size: 56.w,
                  ),
                ),
                Positioned(
                  top: -8.h,
                  child: Icon(Icons.emoji_events_rounded,
                      color: const Color(0xFFF5C542), size: 18.sp),
                ),
              ],
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: 'sotw_reveal_subtitle'.tr,
                    textStyle: context.typography.xsMedium
                        .copyWith(color: const Color(0xFFF5C542)),
                  ),
                  SizedBox(height: 4.h),
                  AppText(
                    text: star.childName,
                    textStyle: context.typography.mdBold
                        .copyWith(color: AppColors.white),
                  ),
                  if (star.caption.trim().isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    AppText(
                      text: star.caption,
                      maxLines: 2,
                      textStyle: context.typography.xsRegular.copyWith(
                        color: AppColors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.play_circle_fill_rounded,
                color: AppColors.white.withValues(alpha: 0.9), size: 30.sp),
          ],
        ),
      ),
    );
  }
}
