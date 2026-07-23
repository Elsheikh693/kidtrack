import '../../../../../../index/index_main.dart';

/// Segmented view of a child's attempts (after a retake): tap to inspect each,
/// with an "official" badge and a button to mark the viewed one as official.
class AttemptSwitcher extends StatelessWidget {
  final List<AssessmentAttempt> attempts;
  final int viewedNo;
  final int officialNo;
  final ValueChanged<int> onSelect;
  final ValueChanged<int> onMakeOfficial;

  const AttemptSwitcher({
    super.key,
    required this.attempts,
    required this.viewedNo,
    required this.officialNo,
    required this.onSelect,
    required this.onMakeOfficial,
  });

  static const _accent = Color(0xFF4F46E5);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final a in attempts) _chip(context, a)],
          ),
          if (viewedNo != officialNo) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => onMakeOfficial(viewedNo),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _accent,
                  side: const BorderSide(color: _accent),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.verified_rounded, size: 18),
                label: Text('assessment_make_official'.tr,
                    style:
                        context.typography.smSemiBold.copyWith(color: _accent)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, AssessmentAttempt a) {
    final selected = a.attemptNo == viewedNo;
    final isOfficial = a.attemptNo == officialNo;
    final pct = a.percentage;
    return GestureDetector(
      onTap: () => onSelect(a.attemptNo),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _accent.withValues(alpha: 0.10) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? _accent : const Color(0xFFE2E8F0),
              width: selected ? 1.4 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'assessment_attempt_n'.trParams({'n': '${a.attemptNo}'}),
              style: context.typography.xsMedium.copyWith(
                  color: selected ? _accent : const Color(0xFF475569)),
            ),
            if (pct != null) ...[
              const SizedBox(width: 6),
              Text('${pct.round()}%',
                  style: context.typography.smSemiBold.copyWith(
                      color: selected ? _accent : const Color(0xFF1E293B))),
            ],
            if (isOfficial) ...[
              const SizedBox(width: 6),
              const Icon(Icons.verified_rounded,
                  size: 14, color: Color(0xFF16A34A)),
            ],
          ],
        ),
      ),
    );
  }
}
