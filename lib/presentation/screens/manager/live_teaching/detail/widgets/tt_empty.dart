import '../../../../../../index/index_main.dart';

/// Shown when the teacher has no activities matching the current filters today.
class TtEmpty extends StatelessWidget {
  const TtEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 60.h, horizontal: 24.w),
      child: Column(
        children: [
          Icon(
            Icons.event_note_rounded,
            size: 44.sp,
            color: AppColors.textSecondaryParagraph,
          ),
          SizedBox(height: 14.h),
          Text(
            'live_teaching_detail_empty'.tr,
            textAlign: TextAlign.center,
            style: context.typography.smSemiBold
                .copyWith(color: AppColors.textDefault),
          ),
        ],
      ),
    );
  }
}
