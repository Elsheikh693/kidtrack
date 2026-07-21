import '../../../../../index/index_main.dart';
import 'change_classroom_sheet.dart';
import 'change_package_sheet.dart';
import 'change_branch_sheet.dart';

/// Enrollment-management card on the child profile: change classroom, change
/// fee package, or move to another branch. Visible only to enrollment-managing
/// roles (reception / manager / owner / super-admin).
class ChildManageSection extends StatelessWidget {
  const ChildManageSection({super.key, required this.controller});

  final ChildProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.child.value == null) return const SizedBox.shrink();
      if (!controller.canManage) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grayLight),
        ),
        child: Column(
          children: [
            _ManageRow(
              icon: Icons.class_rounded,
              label: 'child_manage_classroom'.tr,
              onTap: () => showChangeClassroomSheet(controller),
            ),
            _ManageRow(
              icon: Icons.sell_rounded,
              label: 'child_manage_package'.tr,
              onTap: () => showChangePackageSheet(controller),
            ),
            _ManageRow(
              icon: Icons.apartment_rounded,
              label: 'child_manage_branch'.tr,
              onTap: () => showChangeBranchSheet(controller),
              isLast: true,
            ),
          ],
        ),
      );
    });
  }
}

class _ManageRow extends StatelessWidget {
  const _ManageRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: AppColors.grayLight.withValues(alpha: 0.6),
                  ),
                ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: context.typography.smSemiBold
                    .copyWith(color: AppColors.textDefault),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondaryParagraph,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
