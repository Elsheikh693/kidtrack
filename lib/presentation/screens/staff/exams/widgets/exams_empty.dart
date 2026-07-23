import '../../../../../index/index_main.dart';

/// Empty state for the staff exams list — shown when a classroom has no exams
/// set yet.
class ExamsEmpty extends StatelessWidget {
  const ExamsEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96.w,
            height: 96.w,
            decoration: BoxDecoration(
              color: AppColors.primary10,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.assignment_rounded,
              size: 44.r,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 16.h),
          AppText(
            text: 'exams_empty_title'.tr,
            textStyle: context.typography.mdBold
                .copyWith(color: AppColors.textPrimaryParagraph),
          ),
          SizedBox(height: 6.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: AppText(
              text: 'exams_empty_hint'.tr,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.visible,
              textStyle: context.typography.smRegular
                  .copyWith(color: AppColors.textSecondaryParagraph),
            ),
          ),
        ],
      ),
    );
  }
}
