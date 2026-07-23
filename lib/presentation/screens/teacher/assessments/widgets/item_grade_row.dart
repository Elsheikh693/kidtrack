import '../../../../../index/index_main.dart';

/// Grades a single item: the item's title/description, a scale selector
/// (rating chips or a numeric field), and an optional per-item note.
class ItemGradeRow extends StatelessWidget {
  final AssessmentItem item;
  final int index;
  final AssessmentScale scale;
  final String? value;
  final TextEditingController noteController;
  final ValueChanged<String?> onValueChanged;

  const ItemGradeRow({
    super.key,
    required this.item,
    required this.index,
    required this.scale,
    required this.value,
    required this.noteController,
    required this.onValueChanged,
  });

  static const _accent = Color(0xFF4F46E5);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: _accent.withValues(alpha: 0.12),
                child: Text('${index + 1}',
                    style: context.typography.smSemiBold.copyWith(color: _accent)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        style: context.typography.smSemiBold
                            .copyWith(color: const Color(0xFF1E293B))),
                    if (item.description != null &&
                        item.description!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(item.description!,
                          style: context.typography.xsRegular
                              .copyWith(color: const Color(0xFF94A3B8))),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (scale.isNumeric)
            _numericSelector(context)
          else
            _ratingSelector(context),
          const SizedBox(height: 10),
          _noteField(context),
        ],
      ),
    );
  }

  Widget _ratingSelector(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final level in scale.levels) _levelChip(context, level),
      ],
    );
  }

  Widget _levelChip(BuildContext context, AssessmentScaleLevel level) {
    final selected = value == level.key;
    final c = level.color != null ? Color(level.color!) : _accent;
    return GestureDetector(
      onTap: () => onValueChanged(selected ? null : level.key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? c : c.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? c : const Color(0xFFE2E8F0)),
        ),
        child: Text(
          level.label,
          style: context.typography.smMedium
              .copyWith(color: selected ? Colors.white : c),
        ),
      ),
    );
  }

  Widget _numericSelector(BuildContext context) {
    final max = (scale.numericMax ?? 10).round();
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (int n = 0; n <= max; n++) _numberChip(context, n),
      ],
    );
  }

  Widget _numberChip(BuildContext context, int n) {
    final selected = value == '$n';
    return GestureDetector(
      onTap: () => onValueChanged(selected ? null : '$n'),
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? _accent : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: selected ? _accent : const Color(0xFFE2E8F0)),
        ),
        child: Text('$n',
            style: context.typography.smSemiBold.copyWith(
                color: selected ? Colors.white : const Color(0xFF475569))),
      ),
    );
  }

  Widget _noteField(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: noteController,
        style: context.typography.xsRegular
            .copyWith(color: const Color(0xFF475569)),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: 'assessment_item_note_hint'.tr,
          hintStyle: context.typography.xsRegular
              .copyWith(color: const Color(0xFFCBD5E1)),
        ),
      ),
    );
  }
}
