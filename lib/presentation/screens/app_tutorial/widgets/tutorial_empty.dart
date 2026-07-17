import '../../../../index/index_main.dart';

/// Shown on the "Learn the App" screen when no tutorial videos target the
/// current role yet.
class TutorialEmpty extends StatelessWidget {
  const TutorialEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88.w,
              height: 88.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.ondemand_video_rounded,
                  size: 40.sp, color: AppColors.primary),
            ),
            SizedBox(height: 18.h),
            AppText(
              text: 'tutorial_empty_title'.tr,
              textStyle: context.typography.mdBold
                  .copyWith(color: AppColors.textDefault),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            AppText(
              text: 'tutorial_empty_sub'.tr,
              textStyle: context.typography.smRegular
                  .copyWith(color: AppColors.textSecondaryParagraph),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
