import '../../../../../index/index_main.dart';

/// One event row in the staff events list. Shows the cover/category, title,
/// date, and a photo count; tapping opens the event photos screen.
class StaffEventCard extends StatelessWidget {
  const StaffEventCard({super.key, required this.event, required this.onTap});

  final NurseryEventModel event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = event.category.color;
    final count = event.photos.length;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEF0F4)),
        ),
        child: Row(
          children: [
            _thumb(color),
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
                  SizedBox(height: 4.h),
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
            SizedBox(width: 8.w),
            _photoBadge(context, count),
          ],
        ),
      ),
    );
  }

  Widget _thumb(Color color) {
    if (event.coverImage != null && event.coverImage!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AppNetworkImage(
          url: event.coverImage!,
          width: 52.w,
          height: 52.w,
          fit: BoxFit.cover,
        ),
      );
    }
    return Container(
      width: 52.w,
      height: 52.w,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(event.category.icon, color: color, size: 24.sp),
    );
  }

  Widget _photoBadge(BuildContext context, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.photo_library_rounded,
              size: 14.sp, color: AppColors.primary),
          SizedBox(width: 5.w),
          Text(
            '$count',
            style: context.typography.xsMedium
                .copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
