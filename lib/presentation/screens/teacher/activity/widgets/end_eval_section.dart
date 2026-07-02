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

  static const _items = [
    (
      EvalLevel.excellent,
      'teacher_end_eval_excellent',
      '🟢',
      AppColors.activityGreen,
    ),
    (
      EvalLevel.needsFollow,
      'teacher_end_eval_follow',
      '🟡',
      AppColors.activityAmber,
    ),
    (
      EvalLevel.needsAttention,
      'teacher_end_eval_support',
      '🔴',
      AppColors.activityRed,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = endCtrl.defaultEval.value;
      return Row(
        children: [
          for (int i = 0; i < _items.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: _DefaultButton(
                level: _items[i].$1,
                labelKey: _items[i].$2,
                emoji: _items[i].$3,
                color: _items[i].$4,
                isSelected: selected == _items[i].$1,
                onTap: () {
                  HapticFeedback.lightImpact();
                  endCtrl.setDefaultEval(_items[i].$1);
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
    required this.level,
    required this.labelKey,
    required this.emoji,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final EvalLevel level;
  final String labelKey;
  final String emoji;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 5),
            Text(
              labelKey.tr,
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
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _SummaryChip(
              emoji: '🟢',
              count: endCtrl.summaryCount(EvalLevel.excellent),
              color: AppColors.activityGreen,
            ),
            Container(width: 1, height: 18, color: Colors.grey.shade200),
            _SummaryChip(
              emoji: '🟡',
              count: endCtrl.summaryCount(EvalLevel.needsFollow),
              color: AppColors.activityAmber,
            ),
            Container(width: 1, height: 18, color: Colors.grey.shade200),
            _SummaryChip(
              emoji: '🔴',
              count: endCtrl.summaryCount(EvalLevel.needsAttention),
              color: AppColors.activityRed,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.emoji,
    required this.count,
    required this.color,
  });

  final String emoji;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 15)),
        const SizedBox(width: 6),
        Text(
          '$count',
          style: context.typography.smSemiBold.copyWith(color: color),
        ),
      ],
    );
  }
}
