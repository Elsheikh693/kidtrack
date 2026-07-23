import '../../../../../index/index_main.dart';
import 'delete_child_sheet.dart';

/// Danger-zone row on the child profile: permanently delete the child record
/// (for entries created by mistake). Distinct from withdrawal — it leaves no
/// departure log. Visible only to leadership (manager / owner / super admin);
/// reception can withdraw but not hard-delete.
class DeleteChildSection extends StatelessWidget {
  const DeleteChildSection({super.key, required this.controller});

  final ChildProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.child.value == null) return const SizedBox.shrink();
      if (!controller.canDelete) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: GestureDetector(
          onTap: () => showDeleteChildSheet(controller),
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
                Icon(Icons.delete_forever_rounded,
                    color: AppColors.activityRed, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'child_delete_action'.tr,
                    style: context.typography.smSemiBold
                        .copyWith(color: AppColors.activityRed),
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
