import '../../../../../index/index_main.dart';

/// One selectable membership (role + nursery) on the role-picker screen.
class MembershipCard extends StatelessWidget {
  final MembershipPickerController controller;
  final MembershipModel membership;

  const MembershipCard({
    super.key,
    required this.controller,
    required this.membership,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => InkWell(
        onTap: controller.isBusy.value
            ? null
            : () => controller.select(membership),
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.dividerAndLines),
          ),
          child: Row(
            children: [
              Container(
                width: 46.w,
                height: 46.h,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  _roleIcon,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: controller.roleLabel(membership),
                      textStyle: context.typography.smSemiBold,
                    ),
                    SizedBox(height: 3.h),
                    AppText(
                      text: controller.nurseryLabel(membership),
                      textStyle: context.typography.xsRegular.copyWith(
                        color: AppColors.textSecondaryParagraph,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondaryParagraph,
                size: 24.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData get _roleIcon {
    switch (membership.userType) {
      case UserType.parent:
        return Icons.family_restroom_rounded;
      case UserType.teacher:
      case UserType.nanny:
        return Icons.school_rounded;
      case UserType.receptionist:
        return Icons.badge_rounded;
      case UserType.branchManager:
      case UserType.owner:
        return Icons.workspace_premium_rounded;
      case UserType.busChaperone:
        return Icons.directions_bus_rounded;
      default:
        return Icons.person_rounded;
    }
  }
}
