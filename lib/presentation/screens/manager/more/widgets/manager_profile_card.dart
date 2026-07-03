import '../../../../../index/index_main.dart';

/// Identity header for the More tab — manager name, branch, and avatar.
class ManagerProfileCard extends StatelessWidget {
  const ManagerProfileCard({super.key, required this.controller, this.onTap});

  final ManagerMoreController controller;

  /// When provided, the whole card becomes tappable (e.g. to edit the profile)
  /// and shows a trailing edit affordance.
  final VoidCallback? onTap;

  static const _accent = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.grayLight.withValues(alpha: 0.5),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              _Avatar(controller: controller),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.userName,
                      style: context.typography.mdBold
                          .copyWith(color: AppColors.textDefault),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Obx(
                      () => Row(
                        children: [
                          Icon(Icons.apartment_rounded,
                              size: 14, color: AppColors.grayMedium),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              controller.branchName.value.isEmpty
                                  ? 'manager_more_role'.tr
                                  : controller.branchName.value,
                              style: context.typography.xsRegular.copyWith(
                                color: AppColors.textSecondaryParagraph,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 8),
                Icon(Icons.edit_outlined, size: 18, color: _accent),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.controller});

  final ManagerMoreController controller;

  @override
  Widget build(BuildContext context) {
    final url = controller.userImage;
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: ManagerProfileCard._accent.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: url.isEmpty
          ? const Icon(Icons.person_rounded,
              color: ManagerProfileCard._accent, size: 28)
          : Image(
              image: appCachedImageProvider(url),
              fit: BoxFit.cover,
              errorBuilder: (_, error, stack) => const Icon(
                Icons.person_rounded,
                color: ManagerProfileCard._accent,
                size: 28,
              ),
            ),
    );
  }
}
