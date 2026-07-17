import '../../../../../index/index_main.dart';

/// A tappable tile for picking a media file (video or thumbnail) in the
/// tutorial add/edit sheet. Shows the selected file name (or current-file hint)
/// once chosen.
class MediaPickTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? pickedName;
  final VoidCallback onTap;

  const MediaPickTile({
    super.key,
    required this.label,
    required this.icon,
    required this.pickedName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasPick = pickedName != null && pickedName!.trim().isNotEmpty;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: hasPick ? AppColors.primary : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 22.sp,
                color: hasPick ? AppColors.primary : AppColors.grayMedium),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: label,
                    textStyle: context.typography.smMedium
                        .copyWith(color: AppColors.textDefault),
                  ),
                  if (hasPick) ...[
                    SizedBox(height: 2.h),
                    AppText(
                      text: pickedName!,
                      textStyle: context.typography.xsRegular
                          .copyWith(color: AppColors.primary),
                      maxLines: 1,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              hasPick ? Icons.check_circle_rounded : Icons.upload_rounded,
              size: 20.sp,
              color: hasPick ? AppColors.successForeground : AppColors.grayMedium,
            ),
          ],
        ),
      ),
    );
  }
}
