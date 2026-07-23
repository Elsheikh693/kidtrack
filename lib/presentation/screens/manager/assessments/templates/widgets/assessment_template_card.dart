import '../../../../../../index/index_main.dart';

/// One row in the assessment-templates list: title, subject/type meta, item &
/// scale summary, with edit / delete actions.
class AssessmentTemplateCard extends StatelessWidget {
  final AssessmentTemplateModel item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AssessmentTemplateCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  static const _accent = Color(0xFF4F46E5);

  @override
  Widget build(BuildContext context) {
    final scaleLabel = item.scale.isNumeric
        ? '${'assessment_scale_numeric'.tr} (${_fmt(item.scale.numericMax)})'
        : '${item.scale.levels.length} ${'assessment_scale_levels_unit'.tr}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.assignment_rounded,
                    color: _accent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: context.typography.smSemiBold
                          .copyWith(color: const Color(0xFF1E293B)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      [
                        if (item.subject != null && item.subject!.isNotEmpty)
                          item.subject!,
                        '${item.items.length} ${'assessment_items_unit'.tr}',
                        scaleLabel,
                      ].join(' • '),
                      style: context.typography.xsRegular
                          .copyWith(color: const Color(0xFF94A3B8)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Color(0xFFDC2626), size: 20),
                splashRadius: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _fmt(double? v) {
    if (v == null) return '';
    return v == v.roundToDouble() ? v.toInt().toString() : v.toString();
  }
}
