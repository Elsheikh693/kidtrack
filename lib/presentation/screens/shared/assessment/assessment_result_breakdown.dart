import '../../../../index/index_main.dart';

/// Read-only breakdown of a graded attempt — the total, each item's chosen
/// level + note, and the overall note. Shared by the manager review screen and
/// the parent report so both read identically.
class AssessmentResultBreakdown extends StatelessWidget {
  final AssessmentAttempt attempt;
  final AssessmentScale scale;
  final List<AssessmentItem> items;
  final Color accent;

  const AssessmentResultBreakdown({
    super.key,
    required this.attempt,
    required this.scale,
    required this.items,
    this.accent = const Color(0xFF4F46E5),
  });

  @override
  Widget build(BuildContext context) {
    final byItem = <String, AssessmentItemResult>{
      for (final r in attempt.results) r.itemId: r,
    };
    final pct = attempt.percentage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _totalBanner(context, pct),
        const SizedBox(height: 16),
        for (int i = 0; i < items.length; i++)
          _itemRow(context, i, items[i], byItem[items[i].id]),
        if (attempt.overallNote != null &&
            attempt.overallNote!.isNotEmpty) ...[
          const SizedBox(height: 8),
          _overallNote(context, attempt.overallNote!),
        ],
      ],
    );
  }

  Widget _totalBanner(BuildContext context, double? pct) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Text('assessment_grade_total'.tr,
              style: context.typography.smMedium
                  .copyWith(color: const Color(0xFF64748B))),
          const Spacer(),
          Text(pct == null ? '—' : '${pct.round()}%',
              style: context.typography.xxlBold.copyWith(color: accent)),
        ],
      ),
    );
  }

  Widget _itemRow(BuildContext context, int index, AssessmentItem item,
      AssessmentItemResult? result) {
    final label = result?.rawValue == null
        ? '—'
        : scale.labelFor(result!.rawValue);
    final frac = result?.fraction;
    final chipColor = _colorForFraction(frac);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
              Expanded(
                child: Text(item.title,
                    style: context.typography.smSemiBold
                        .copyWith(color: const Color(0xFF1E293B))),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: chipColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(label,
                    style: context.typography.smSemiBold
                        .copyWith(color: chipColor)),
              ),
            ],
          ),
          if (result?.note != null && result!.note!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.sticky_note_2_outlined,
                    size: 14, color: Color(0xFF94A3B8)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(result.note!,
                      style: context.typography.xsRegular
                          .copyWith(color: const Color(0xFF64748B))),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _overallNote(BuildContext context, String note) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('assessment_overall_note_label'.tr,
              style: context.typography.xsMedium
                  .copyWith(color: const Color(0xFF94A3B8))),
          const SizedBox(height: 4),
          Text(note,
              style: context.typography.smRegular
                  .copyWith(color: const Color(0xFF334155))),
        ],
      ),
    );
  }

  Color _colorForFraction(double? f) {
    if (f == null) return const Color(0xFF94A3B8);
    if (f >= 0.75) return const Color(0xFF16A34A);
    if (f >= 0.5) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }
}
