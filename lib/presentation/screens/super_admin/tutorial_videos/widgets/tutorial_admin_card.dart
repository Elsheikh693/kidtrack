import '../../../../../index/index_main.dart';
import 'tutorial_roles.dart';

/// SuperAdmin list row for one tutorial video: thumbnail, title, targeted-role
/// chips, active flag, plus edit/delete actions.
class TutorialAdminCard extends StatelessWidget {
  final TutorialVideoModel video;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TutorialAdminCard({
    super.key,
    required this.video,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: SizedBox(
                  width: 72.w,
                  height: 54.w,
                  child: video.hasThumbnail
                      ? AppNetworkImage(
                          url: video.thumbnailUrl, fit: BoxFit.cover)
                      : ColoredBox(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          child: Icon(Icons.ondemand_video_rounded,
                              color: AppColors.primary, size: 26.sp),
                        ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppText(
                            text: video.title,
                            textStyle: context.typography.smSemiBold
                                .copyWith(color: AppColors.textDefault),
                            maxLines: 1,
                          ),
                        ),
                        if (!video.isActive)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: AppColors.grayLight,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: AppText(
                              text: 'tutorial_admin_hidden'.tr,
                              textStyle: context.typography.xsRegular
                                  .copyWith(color: AppColors.grayMedium),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 6.h,
                      children: video.audience
                          .map((r) => _RoleChip(label: tutorialRoleLabel(r)))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(height: 20.h, color: AppColors.grayLight),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _Action(
                icon: Icons.edit_rounded,
                color: AppColors.primary,
                label: 'tutorial_admin_edit'.tr,
                onTap: onEdit,
              ),
              SizedBox(width: 16.w),
              _Action(
                icon: Icons.delete_outline_rounded,
                color: AppColors.errorForeground,
                label: 'tutorial_admin_delete'.tr,
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  const _RoleChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: AppText(
        text: label,
        textStyle:
            context.typography.xsRegular.copyWith(color: AppColors.primary),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _Action({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
        child: Row(
          children: [
            Icon(icon, size: 18.sp, color: color),
            SizedBox(width: 4.w),
            AppText(
              text: label,
              textStyle: context.typography.xsMedium.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
