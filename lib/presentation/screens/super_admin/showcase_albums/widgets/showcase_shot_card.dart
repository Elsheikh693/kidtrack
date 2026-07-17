import '../../../../../index/index_main.dart';

/// A single showcase screenshot row in the reorderable album list: drag handle,
/// image preview, position badge, show/hide toggle, and delete.
class ShowcaseShotCard extends StatelessWidget {
  final ShowcaseShotModel shot;
  final int position;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;

  const ShowcaseShotCard({
    super.key,
    required this.shot,
    required this.position,
    required this.onDelete,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    final dimmed = !shot.isActive;
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(Icons.drag_indicator_rounded,
              color: AppColors.grayMedium, size: 22.sp),
          SizedBox(width: 8.w),
          Opacity(
            opacity: dimmed ? 0.4 : 1,
            child: AppNetworkImage(
              url: shot.imageUrl,
              width: 54.w,
              height: 72.h,
              borderRadius: BorderRadius.circular(10.r),
              errorWidget: Container(
                width: 54.w,
                height: 72.h,
                color: const Color(0xFFF1F5F9),
                child: Icon(Icons.broken_image_rounded,
                    color: AppColors.grayMedium, size: 20.sp),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: AppText(
              text: '${'showcase_position'.tr} ${position + 1}',
              textStyle: context.typography.smMedium
                  .copyWith(color: AppColors.textDefault),
            ),
          ),
          IconButton(
            onPressed: onToggleActive,
            icon: Icon(
              shot.isActive
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              color: shot.isActive ? AppColors.primary : AppColors.grayMedium,
              size: 22.sp,
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline_rounded,
                color: AppColors.errorForeground, size: 22.sp),
          ),
        ],
      ),
    );
  }
}
