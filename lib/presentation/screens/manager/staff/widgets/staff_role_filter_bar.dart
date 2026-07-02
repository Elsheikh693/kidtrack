import '../../../../../index/index_main.dart';

/// Horizontal role filter for the Staff directory. Chips are built from the
/// roles actually present in the branch, plus an "All" reset chip.
class StaffRoleFilterBar extends StatelessWidget {
  const StaffRoleFilterBar({super.key, required this.controller});

  final ManagerStaffController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final options = controller.roleOptions;
      if (options.length < 2) return const SizedBox.shrink();
      final selected = controller.roleFilter.value;
      return SizedBox(
        height: 38,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _Chip(
              label: 'manager_staff_filter_all'.tr,
              active: selected == null,
              onTap: () => controller.onRoleFilter(null),
            ),
            ...options.map((t) => _Chip(
                  label: t.labelKey.tr,
                  active: selected == t,
                  onTap: () => controller.onRoleFilter(t),
                )),
          ],
        ),
      );
    });
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.activityBlue : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.activityBlue : AppColors.grayLight,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: context.typography.xsMedium.copyWith(
            color: active ? AppColors.white : AppColors.textSecondaryParagraph,
          ),
        ),
      ),
    );
  }
}
