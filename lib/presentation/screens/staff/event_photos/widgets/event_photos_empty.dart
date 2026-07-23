import '../../../../../index/index_main.dart';

/// Empty state shown when an event has no photos yet.
class EventPhotosEmpty extends StatelessWidget {
  const EventPhotosEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add_a_photo_rounded,
                size: 40.sp, color: AppColors.primary),
          ),
          SizedBox(height: 16.h),
          Text(
            'event_photos_empty'.tr,
            style: context.typography.smSemiBold
                .copyWith(color: AppColors.textDefault),
          ),
          SizedBox(height: 6.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              'event_photos_empty_sub'.tr,
              textAlign: TextAlign.center,
              style: context.typography.xsRegular
                  .copyWith(color: AppColors.grayMedium, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
