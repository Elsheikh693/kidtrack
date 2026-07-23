import '../../../../../index/index_main.dart';

/// Lets the teacher pick the subset of children joining a focused "activity"
/// (vs. a whole-class session). Selection state is owned by the host sheet;
/// this widget only renders and reports taps.
class ActivityChildrenPicker extends StatelessWidget {
  const ActivityChildrenPicker({
    super.key,
    required this.children,
    required this.selected,
    required this.onToggle,
    required this.onSelectAll,
    required this.onClearAll,
  });

  final List<ChildModel> children;
  final Set<String> selected;
  final void Function(String childId) onToggle;
  final VoidCallback onSelectAll;
  final VoidCallback onClearAll;

  bool get _allSelected =>
      children.isNotEmpty && selected.length >= children.length;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'teacher_activity_pick_children'.tr,
              style: context.typography.smMedium
                  .copyWith(color: AppColors.textPrimaryParagraph),
            ),
            const SizedBox(width: 8),
            _CountBadge(count: selected.length, total: children.length),
            const Spacer(),
            if (children.isNotEmpty)
              GestureDetector(
                onTap: _allSelected ? onClearAll : onSelectAll,
                child: Text(
                  (_allSelected
                          ? 'teacher_activity_clear_all'
                          : 'teacher_activity_select_all')
                      .tr,
                  style: context.typography.xsMedium
                      .copyWith(color: AppColors.activityGreen),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'teacher_activity_pick_hint'.tr,
          style: context.typography.xsRegular
              .copyWith(color: Colors.grey.shade500),
        ),
        const SizedBox(height: 12),
        if (children.isEmpty)
          _empty(context)
        else
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 10.0;
              final tileWidth = (constraints.maxWidth - spacing) / 2;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: children
                    .map((c) => SizedBox(
                          width: tileWidth,
                          child: _tile(context, c),
                        ))
                    .toList(growable: false),
              );
            },
          ),
      ],
    );
  }

  Widget _tile(BuildContext context, ChildModel child) {
    final id = child.key ?? '';
    final isSelected = selected.contains(id);
    return GestureDetector(
      onTap: () => onToggle(id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.activityGreen.withValues(alpha: 0.06)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.activityGreen.withValues(alpha: 0.6)
                : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            ChildAvatar(
              name: child.fullName,
              imageUrl: child.profileImage,
              size: 38,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                child.fullName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.typography.xsMedium.copyWith(
                  height: 1.2,
                  color: isSelected
                      ? AppColors.activityGreenDark
                      : AppColors.textPrimaryParagraph,
                ),
              ),
            ),
            const SizedBox(width: 4),
            _checkDot(isSelected),
          ],
        ),
      ),
    );
  }

  Widget _checkDot(bool on) => Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: on ? AppColors.activityGreen : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: on ? AppColors.activityGreen : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: on
            ? const Icon(Icons.check, color: Colors.white, size: 13)
            : null,
      );

  Widget _empty(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        alignment: Alignment.center,
        child: Text(
          'teacher_activity_no_present'.tr,
          style: context.typography.smRegular
              .copyWith(color: Colors.grey.shade500),
        ),
      );
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count, required this.total});
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.activityGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$count/$total',
        style: context.typography.xsMedium
            .copyWith(color: AppColors.activityGreen),
      ),
    );
  }
}
