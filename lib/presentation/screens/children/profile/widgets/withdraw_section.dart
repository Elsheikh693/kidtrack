import '../../../../../index/index_main.dart';
import 'withdraw_child_sheet.dart';

/// Enrollment-status footer on the child profile. Shows a "withdraw from
/// nursery" action for enrollment-managing roles. Withdrawal permanently
/// deletes the child (and any now-childless parent), so there is no
/// "withdrawn" state to display afterwards — the profile simply pops.
class WithdrawSection extends StatelessWidget {
  const WithdrawSection({super.key, required this.controller});

  final ChildProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final child = controller.child.value;
      if (child == null) return const SizedBox.shrink();
      if (!controller.canWithdraw) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: GestureDetector(
          onTap: () => showWithdrawChildSheet(controller),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.activityRed.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: AppColors.activityRed,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'child_withdraw_action'.tr,
                    style: context.typography.smSemiBold.copyWith(
                      color: AppColors.activityRed,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.activityRed.withValues(alpha: 0.6),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
