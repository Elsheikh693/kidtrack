import '../../../../../index/index_main.dart';
import '../receptionist_children_controller.dart';

/// Labeled entry point on the reception Children tab for sending app
/// invitations to guardians — replaces the ambiguous envelope icon that used
/// to sit in the title bar, so the purpose reads at a glance.
class RcInviteParentsCard extends StatelessWidget {
  final ReceptionistChildrenController controller;
  const RcInviteParentsCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 6.h, 18.w, 8.h),
      child: GestureDetector(
        onTap: controller.openInviteParents,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Row(
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.forward_to_inbox_rounded,
                    color: AppColors.primary, size: 18),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'rc_send_guardian_title'.tr,
                      style: context.typography.smSemiBold
                          .copyWith(color: AppColors.textDefault),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'rc_send_guardian_subtitle'.tr,
                      style: context.typography.xsRegular
                          .copyWith(color: AppColors.textSecondaryParagraph),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 6.w),
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.primary, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
