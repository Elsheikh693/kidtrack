import '../../../../../index/index_main.dart';

class ProfileLocationCard extends StatelessWidget {
  final String? address;
  final VoidCallback onOpenMaps;
  const ProfileLocationCard({
    super.key,
    required this.address,
    required this.onOpenMaps,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpenMaps,
      child: Container(
        height: 140.h,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on_rounded,
                      size: 40.sp, color: AppColors.primary),
                  SizedBox(height: 6.h),
                  AppText(
                    text: 'discovery_open_in_maps'.tr,
                    textStyle: context.typography.xsMedium
                        .copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
            if ((address ?? '').isNotEmpty)
              Positioned(
                left: 12.w,
                right: 12.w,
                bottom: 12.h,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.place_outlined,
                          size: 15.sp, color: AppColors.primary60),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: AppText(
                          text: address!,
                          textStyle: context.typography.xsRegular.copyWith(
                              color: AppColors.textSecondaryParagraph),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
