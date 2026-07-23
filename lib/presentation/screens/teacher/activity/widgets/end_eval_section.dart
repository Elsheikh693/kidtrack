import '../../../../../index/index_main.dart';
import '../activity_end_controller.dart';
import 'end_child_tile.dart';

class EndEvalSection extends StatelessWidget {
  const EndEvalSection({super.key, required this.endCtrl});

  final ActivityEndController endCtrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasDefault = endCtrl.defaultEval.value != null;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.activityGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: AppColors.activityGreen,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'teacher_end_eval_title'.tr,
                style: context.typography.displaySmBold.copyWith(
                  color: AppColors.textDisplay,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Default eval label
          Text(
            'teacher_end_default_eval'.tr,
            style: context.typography.xsMedium.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),

          // Default eval picker
          _DefaultEvalPicker(endCtrl: endCtrl),

          // Children section - only after default is selected
          if (hasDefault) ...[
            const SizedBox(height: 14),
            _SummaryBar(endCtrl: endCtrl),
            const SizedBox(height: 10),
            if (endCtrl.children.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    'teacher_end_no_children'.tr,
                    style: context.typography.xsMedium.copyWith(
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              )
            else
              ...endCtrl.children.asMap().entries.map(
                (e) => EndChildTile(
                  child: e.value,
                  endCtrl: endCtrl,
                  index: e.key,
                ),
              ),
          ] else ...[
            const SizedBox(height: 16),
            Center(
              child: Text(
                'teacher_end_default_hint'.tr,
                style: context.typography.xsMedium.copyWith(
                  color: Colors.grey.shade400,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      );
    });
  }
}

// ── Default Eval Picker ───────────────────────────────────────────────────────

class _DefaultEvalPicker extends StatelessWidget {
  const _DefaultEvalPicker({required this.endCtrl});

  final ActivityEndController endCtrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = endCtrl.defaultEval.value;
      final levels = endCtrl.levels;
      if (levels.isEmpty) {
        return const SizedBox.shrink();
      }
      return Row(
        children: [
          for (int i = 0; i < levels.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: _DefaultButton(
                title: levels[i].title,
                icon: EvalLevelIcons.iconFor(levels[i].icon),
                color: Color(levels[i].color),
                isSelected: selected == levels[i].key,
                onTap: () {
                  HapticFeedback.lightImpact();
                  endCtrl.setDefaultEval(levels[i].key ?? '');
                },
              ),
            ),
          ],
        ],
      );
    });
  }
}

class _DefaultButton extends StatelessWidget {
  const _DefaultButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.22)
                    : color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 26,
                color: isSelected ? Colors.white : color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.typography.xsMedium.copyWith(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Summary Bar ───────────────────────────────────────────────────────────────
class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.endCtrl});

  final ActivityEndController endCtrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final levels = endCtrl.levels;
      // Rebuild when evaluations change too.
      endCtrl.childEvals.length;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (int i = 0; i < levels.length; i++) ...[
              if (i > 0)
                Container(width: 1, height: 18, color: Colors.grey.shade200),
              _SummaryChip(
                icon: EvalLevelIcons.iconFor(levels[i].icon),
                count: endCtrl.summaryCount(levels[i].key ?? ''),
                color: Color(levels[i].color),
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.icon,
    required this.count,
    required this.color,
  });

  final IconData icon;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          '$count',
          style: context.typography.smSemiBold.copyWith(color: color),
        ),
      ],
    );
  }
}
