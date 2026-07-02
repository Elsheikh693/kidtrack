import '../../../../../index/index_main.dart';

/// The single global level switch, rendered as a tappable pill in the owner
/// AppBar: «All Branches ▼» / «Tanta Branch ▼». Tapping opens a sheet to pick a
/// branch or go back to the whole network. Hides itself entirely for a
/// single-branch owner (nothing to switch between).
class OwnerScopeSwitcher extends StatelessWidget {
  const OwnerScopeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Get.find<OwnerScopeService>();

    return Obx(() {
      if (!service.isMultiBranch) {
        // Single-branch owner — just show a static title, no switch affordance.
        return AppText(
          text: 'owner_exec_title'.tr,
          textStyle: context.typography.lgBold.copyWith(
            color: AppColors.backgroundBlack,
          ),
        );
      }

      final isNetwork = service.scope.value.isNetwork;
      return InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openPicker(context, service),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isNetwork ? Icons.apartment_rounded : Icons.store_mall_directory_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  service.currentLabel,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.lgBold.copyWith(
                    color: AppColors.backgroundBlack,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 22),
            ],
          ),
        ),
      );
    });
  }

  void _openPicker(BuildContext context, OwnerScopeService service) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.borderNeutralPrimary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Text(
                  'owner_scope_pick_title'.tr,
                  style: TextStyle(
                    color: AppColors.textDefault,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Obx(() {
                final scope = service.scope.value;
                return Column(
                  children: [
                    _ScopeTile(
                      icon: Icons.apartment_rounded,
                      label: 'owner_scope_all_branches'.tr,
                      subtitle: 'owner_scope_all_branches_sub'
                          .trParams({'count': '${service.branches.length}'}),
                      selected: scope.isNetwork,
                      onTap: () {
                        service.selectNetwork();
                        Get.back();
                      },
                    ),
                    const Divider(height: 18),
                    ...service.branches.map(
                      (b) => _ScopeTile(
                        icon: Icons.store_mall_directory_rounded,
                        label: b.name,
                        subtitle: b.address,
                        selected: scope.branchId == b.key,
                        onTap: () {
                          service.selectBranch(b);
                          Get.back();
                        },
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class _ScopeTile extends StatelessWidget {
  const _ScopeTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.35)
                : AppColors.borderNeutralPrimary.withValues(alpha: 0.4),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (selected ? AppColors.primary : AppColors.textSecondaryParagraph)
                    .withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                icon,
                size: 20,
                color: selected ? AppColors.primary : AppColors.textSecondaryParagraph,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: AppColors.textDefault,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondaryParagraph,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }
}
