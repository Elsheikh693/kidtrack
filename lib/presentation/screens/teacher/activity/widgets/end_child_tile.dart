import '../../../../../index/index_main.dart';
import '../activity_end_controller.dart';
import 'end_comment_sheet.dart';

class EndChildTile extends StatelessWidget {
  const EndChildTile({
    super.key,
    required this.child,
    required this.endCtrl,
    required this.index,
  });

  final ChildModel child;
  final ActivityEndController endCtrl;
  final int index;

  static const _avatarColors = [
    Color(0xFF7C3AED),
    Color(0xFF0891B2),
    Color(0xFF16A34A),
    Color(0xFFDC2626),
    Color(0xFFD97706),
    Color(0xFF0D9488),
  ];

  Color get _avatarColor => _avatarColors[index % _avatarColors.length];

  void _openComment(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Directionality(
        textDirection: appTextDirection,
        child: EndCommentSheet(child: child, endCtrl: endCtrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final childId = child.key ?? '';
    return Obx(() {
      final currentKey = endCtrl.childEvals[childId];
      final levels = endCtrl.levels;
      final selColor = (currentKey != null && currentKey.isNotEmpty)
          ? EvalLevelsRegistry.instance.colorFor(currentKey)
          : null;
      final reasonCount = endCtrl.reasonCount(childId);

      final bgColor =
          selColor == null ? Colors.white : selColor.withValues(alpha: 0.08);
      final borderColor = selColor == null
          ? Colors.grey.shade100
          : selColor.withValues(alpha: 0.18);

      return AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: avatar + name + comment button
            Row(
              children: [
                ChildAvatar(
                  name: child.fullName,
                  imageUrl: child.profileImage,
                  size: 30,
                  color: _avatarColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    child.fullName,
                    style: context.typography.smMedium
                        .copyWith(color: AppColors.textDisplay),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _openComment(context),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 5),
                    decoration: BoxDecoration(
                      color: reasonCount > 0
                          ? AppColors.activityPurple.withValues(alpha: 0.08)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: reasonCount > 0
                            ? AppColors.activityPurple.withValues(alpha: 0.3)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.label_rounded,
                          size: 14,
                          color: reasonCount > 0
                              ? AppColors.activityPurple
                              : Colors.grey.shade400,
                        ),
                        if (reasonCount > 0) ...[
                          const SizedBox(width: 3),
                          Text(
                            '$reasonCount',
                            style: context.typography.xsMedium.copyWith(
                              color: AppColors.activityPurple,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Row 2: dynamic eval-level pills (scrolls if many)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < levels.length; i++) ...[
                    if (i > 0) const SizedBox(width: 4),
                    _EvalMiniPill(
                      icon: EvalLevelIcons.iconFor(levels[i].icon),
                      color: Color(levels[i].color),
                      isSelected: currentKey == levels[i].key,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        endCtrl.setChildEval(childId, levels[i].key ?? '');
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _EvalMiniPill extends StatelessWidget {
  const _EvalMiniPill({
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 38,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Icon(
          icon,
          size: 19,
          color: isSelected ? color : Colors.grey.shade400,
        ),
      ),
    );
  }
}
