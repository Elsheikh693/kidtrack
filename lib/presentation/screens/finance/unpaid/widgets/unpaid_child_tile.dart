import '../../../../../index/index_main.dart';

/// One row in the unpaid list: the child, the guardians a reminder would reach,
/// and a send button. When no active guardian is linked the button is disabled
/// and a hint replaces the names so staff know why they can't nudge.
class UnpaidChildTile extends StatelessWidget {
  const UnpaidChildTile({
    super.key,
    required this.child,
    required this.guardians,
    required this.hasRecipients,
    required this.onSend,
  });

  final ChildModel child;
  final String guardians;
  final bool hasRecipients;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    const accent = AppColors.activityAmberBrand;
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10.r,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ChildAvatar(
            name: child.fullName,
            imageUrl: child.profileImage,
            size: 42.w,
            color: accent,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.smSemiBold.copyWith(
                    color: AppColors.textDefault,
                  ),
                ),
                SizedBox(height: 3.h),
                Row(
                  children: [
                    Icon(
                      hasRecipients
                          ? Icons.people_outline_rounded
                          : Icons.person_off_outlined,
                      size: 13.sp,
                      color: AppColors.textSecondaryParagraph,
                    ),
                    SizedBox(width: 5.w),
                    Expanded(
                      child: Text(
                        hasRecipients ? guardians : 'unpaid_no_guardian'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.typography.xsRegular.copyWith(
                          color: AppColors.textSecondaryParagraph,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          _SendButton(enabled: hasRecipients, onTap: onSend),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? AppColors.primary : AppColors.textSecondaryParagraph;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_active_outlined, size: 15.sp, color: color),
            SizedBox(width: 5.w),
            Text(
              'unpaid_send'.tr,
              style: context.typography.xsMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
