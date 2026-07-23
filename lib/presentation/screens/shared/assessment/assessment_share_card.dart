import '../../../../index/index_main.dart';

/// A beautiful, branded, shareable image of a child's assessment result —
/// nursery logo + name on top, the score front-and-centre, and the KidTrack
/// app wordmark in the footer. Rendered off-screen and captured to a PNG.
class AssessmentShareCard extends StatelessWidget {
  final String childName;
  final String nurseryName;
  final String? nurseryLogo;
  final String title;
  final String? subject;
  final double? percentage;
  final int date;

  const AssessmentShareCard({
    super.key,
    required this.childName,
    required this.nurseryName,
    required this.nurseryLogo,
    required this.title,
    required this.subject,
    required this.percentage,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final pct = percentage;
    final scoreColor = _scoreColor(pct);
    final d = DateTime.fromMillisecondsSinceEpoch(date);
    final dateStr =
        '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF6366F1), Color(0xFF3B82F6)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _nurseryHeader(context),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('assessment_share_headline'.tr,
                    style: context.typography.smMedium
                        .copyWith(color: const Color(0xFF94A3B8))),
                const SizedBox(height: 18),
                _scoreRing(context, pct, scoreColor),
                const SizedBox(height: 18),
                Text(childName,
                    textAlign: TextAlign.center,
                    style: context.typography.lgBold
                        .copyWith(color: const Color(0xFF1E293B))),
                const SizedBox(height: 6),
                Text(
                  [
                    title,
                    if (subject != null && subject!.isNotEmpty) subject!,
                  ].join(' • '),
                  textAlign: TextAlign.center,
                  style: context.typography.smRegular
                      .copyWith(color: const Color(0xFF64748B)),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.event_rounded,
                          size: 13, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 5),
                      Text(dateStr,
                          style: context.typography.xsMedium
                              .copyWith(color: const Color(0xFF64748B))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _appFooter(context),
        ],
      ),
    );
  }

  Widget _nurseryHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: (nurseryLogo != null && nurseryLogo!.isNotEmpty)
              ? AppNetworkImage(
                  url: nurseryLogo,
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  errorWidget: const Icon(Icons.child_care_rounded,
                      color: Color(0xFF6366F1)),
                )
              : const Icon(Icons.child_care_rounded, color: Color(0xFF6366F1)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            nurseryName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.typography.smSemiBold.copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _scoreRing(BuildContext context, double? pct, Color color) {
    return Container(
      width: 148,
      height: 148,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color, width: 5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            pct == null ? '—' : '${pct.round()}%',
            style: context.typography.xxlBold
                .copyWith(color: color, fontSize: 44, height: 1.0),
          ),
          const SizedBox(height: 2),
          Text(_levelLabel(pct),
              style: context.typography.smSemiBold.copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _appFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(7),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset('assets/images/logo.png',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(
                  Icons.child_care_rounded,
                  size: 15,
                  color: Color(0xFF6366F1))),
        ),
        const SizedBox(width: 8),
        Text('assessment_share_via_app'.tr,
            style: context.typography.xsMedium.copyWith(color: Colors.white)),
      ],
    );
  }

  static Color _scoreColor(double? pct) {
    if (pct == null) return const Color(0xFF94A3B8);
    if (pct >= 75) return const Color(0xFF16A34A);
    if (pct >= 50) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }

  static String _levelLabel(double? pct) {
    if (pct == null) return '';
    if (pct >= 90) return 'assessment_level_excellent'.tr;
    if (pct >= 75) return 'assessment_level_great'.tr;
    if (pct >= 50) return 'assessment_level_good'.tr;
    return 'assessment_level_needs'.tr;
  }
}
