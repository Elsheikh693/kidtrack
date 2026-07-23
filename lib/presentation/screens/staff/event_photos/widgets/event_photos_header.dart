import '../../../../../index/index_main.dart';

/// Compact event summary banner at the top of the staff photos screen.
class EventPhotosHeader extends StatelessWidget {
  const EventPhotosHeader({super.key, required this.event});

  final NurseryEventModel event;

  @override
  Widget build(BuildContext context) {
    final color = event.category.color;
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 6.h),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDEFF3)),
      ),
      child: Row(
        children: [
          Container(
            width: 46.w,
            height: 46.h,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13.r),
            ),
            child: Icon(event.category.icon, color: color, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: context.typography.smSemiBold
                      .copyWith(color: AppColors.textDefault),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3.h),
                Text(
                  [event.category.labelKey.tr, event.formattedDate]
                      .join('  ·  '),
                  style: context.typography.xsRegular
                      .copyWith(color: AppColors.grayMedium),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
