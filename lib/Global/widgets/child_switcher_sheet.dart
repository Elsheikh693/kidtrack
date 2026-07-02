import '../../index/index_main.dart';

/// Opens the child switcher for the parent. Lists every child belonging to the
/// logged-in parent and lets them pick the active one. Selecting a child calls
/// [ActiveChildService.setActive], which the parent tab controllers listen to
/// and reload their child-scoped data accordingly.
///
/// No-op when the parent has a single child (nothing to switch between).
Future<void> showChildSwitcher(BuildContext context) async {
  final svc = Get.find<ActiveChildService>();
  if (svc.children.length < 2) return;

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _ChildSwitcherSheet(),
  );
}

class _ChildSwitcherSheet extends StatelessWidget {
  const _ChildSwitcherSheet();

  @override
  Widget build(BuildContext context) {
    final svc = Get.find<ActiveChildService>();
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grayLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'child_switcher_title'.tr,
            style: TextStyle(
              color: AppColors.textDisplay,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'child_switcher_subtitle'.tr,
            style: TextStyle(
              color: AppColors.textSecondaryParagraph,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            final activeId = svc.childId.value;
            return Column(
              children: [
                for (final child in svc.children)
                  _ChildTile(
                    child: child,
                    isActive: child.id == activeId,
                    onTap: () async {
                      if (child.id != svc.childId.value) {
                        await svc.setActive(child);
                      }
                      if (context.mounted) Navigator.of(context).pop();
                    },
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _ChildTile extends StatelessWidget {
  const _ChildTile({
    required this.child,
    required this.isActive,
    required this.onTap,
  });

  final ActiveChildOption child;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initial = child.name.trim().isNotEmpty
        ? child.name.trim().characters.first
        : '?';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.08)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.45)
                : const Color(0xFFE2E8F0),
            width: 1.4,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                child.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textDisplay,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (isActive)
              Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 24)
            else
              Icon(Icons.circle_outlined,
                  color: AppColors.grayLight, size: 24),
          ],
        ),
      ),
    );
  }
}
