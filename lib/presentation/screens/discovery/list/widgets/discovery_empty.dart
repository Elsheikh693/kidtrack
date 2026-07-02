import '../../../../../index/index_main.dart';

class DiscoveryEmpty extends StatelessWidget {
  const DiscoveryEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 60.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96.w,
              height: 96.w,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search_off_rounded,
                  size: 44.sp, color: AppColors.primary40),
            ),
            SizedBox(height: 20.h),
            AppText(
              text: 'discovery_empty_title'.tr,
              textStyle: context.typography.mdBold
                  .copyWith(color: AppColors.textDefault),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            AppText(
              text: 'discovery_empty_subtitle'.tr,
              textStyle: context.typography.smRegular.copyWith(
                color: AppColors.textSecondaryParagraph,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
