import '../../../../../index/index_main.dart';

class AccountMenuSection extends StatelessWidget {
  const AccountMenuSection({
    super.key,
    required this.titleKey,
    required this.items,
  });

  final String titleKey;
  final List<AccountMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.grayLight.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              titleKey.tr,
              style: context.typography.xsMedium.copyWith(
                color: AppColors.textSecondaryParagraph,
              ),
            ),
          ),
          ...items.map((item) => _MenuTile(item: item)),
        ],
      ),
    );
  }
}

class AccountMenuItem {
  final String labelKey;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;
  final bool isDestructive;

  const AccountMenuItem({
    required this.labelKey,
    required this.icon,
    required this.iconColor,
    this.onTap,
    this.isDestructive = false,
  });
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.item});

  final AccountMenuItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: item.isDestructive
                    ? AppColors.errorBackground
                    : item.iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                item.icon,
                color: item.isDestructive
                    ? AppColors.errorForeground
                    : item.iconColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.labelKey.tr,
                style: context.typography.smMedium.copyWith(
                  color: item.isDestructive
                      ? AppColors.errorForeground
                      : AppColors.textDefault,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_outlined,
              size: 14,
              color: AppColors.grayMedium,
            ),
          ],
        ),
      ),
    );
  }
}
