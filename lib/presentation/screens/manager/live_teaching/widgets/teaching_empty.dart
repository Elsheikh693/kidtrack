import '../../../../../index/index_main.dart';

/// Shown in place of the donut when no class is currently in session.
class TeachingEmpty extends StatelessWidget {
  const TeachingEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.chartTrack),
      ),
      child: Column(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: AppColors.chartTrack,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.schedule_rounded,
              size: 26.sp,
              color: AppColors.textSecondaryParagraph,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'live_teaching_empty_title'.tr,
            style: context.typography.smSemiBold
                .copyWith(color: AppColors.textDefault),
          ),
          SizedBox(height: 4.h),
          Text(
            'live_teaching_empty_hint'.tr,
            textAlign: TextAlign.center,
            style: context.typography.xsRegular
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
        ],
      ),
    );
  }
}
