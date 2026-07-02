import '../../../../../index/index_main.dart';

const _insideStatuses = {
  'checked_in',
  'in_activity',
  'having_meal',
  'sleeping',
};

class AccountChildCard extends StatefulWidget {
  const AccountChildCard({super.key});

  @override
  State<AccountChildCard> createState() => _AccountChildCardState();
}

class _AccountChildCardState extends State<AccountChildCard> {
  final _service = Get.find<ActiveChildService>();

  @override
  void initState() {
    super.initState();
    if (_service.children.isEmpty) _service.loadFromFirebase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Icon(Icons.child_care_rounded,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'parent_account_children_section'.tr,
                style: context.typography.smSemiBold.copyWith(
                  color: AppColors.textDefault,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            final kids = _service.children;
            if (kids.isEmpty) {
              return Text(
                'parent_account_children_empty'.tr,
                style: context.typography.xsRegular.copyWith(
                  color: AppColors.textSecondaryParagraph,
                ),
              );
            }
            return Column(
              children: [
                for (var i = 0; i < kids.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  _ChildRow(
                    name: kids[i].name,
                    imageUrl: kids[i].image,
                    isInside: kids[i].id == _service.childId.value &&
                        _insideStatuses.contains(_service.childStatus.value),
                  ),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _ChildRow extends StatelessWidget {
  const _ChildRow({
    required this.name,
    required this.isInside,
    this.imageUrl,
  });

  final String name;
  final bool isInside;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primaryFaint,
            shape: BoxShape.circle,
            image: hasImage
                ? DecorationImage(
                    image: appCachedImageProvider(imageUrl),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: hasImage
              ? null
              : Center(
                  child: Text(
                    name.isNotEmpty ? name[0] : '?',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            style: context.typography.smMedium.copyWith(
              color: AppColors.textDefault,
            ),
          ),
        ),
        if (isInside)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.successBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'parent_child_status_inside'.tr,
              style: const TextStyle(
                color: AppColors.successForeground,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
