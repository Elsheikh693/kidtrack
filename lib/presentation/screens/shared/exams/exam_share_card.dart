import '../../../../index/index_main.dart';
import 'exam_grade_meta.dart';

/// A branded, shareable image of a child's written-exam result — nursery logo +
/// name on top, the verbal grade front-and-centre in its colour, the paper
/// photo, and the KidTrack wordmark in the footer. Rendered off-screen and
/// captured to a PNG by `captureAndShareAssessment`.
class ExamShareCard extends StatelessWidget {
  final String childName;
  final String nurseryName;
  final String? nurseryLogo;
  final ExamGrade grade;
  final String subject;
  final String title;
  final int date;
  final String? paperUrl;

  const ExamShareCard({
    super.key,
    required this.childName,
    required this.nurseryName,
    required this.nurseryLogo,
    required this.grade,
    required this.subject,
    required this.title,
    required this.date,
    required this.paperUrl,
  });

  @override
  Widget build(BuildContext context) {
    final meta = ExamGradeMeta.of(grade);
    final deep = Color.lerp(meta.color, Colors.black, 0.28) ?? meta.color;
    final d = DateTime.fromMillisecondsSinceEpoch(date);
    final dateStr =
        '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
    final headline = title.trim().isNotEmpty ? title : subject;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [meta.color, deep],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(30)),
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
                Text('exam_share_headline'.tr,
                    style: context.typography.smMedium
                        .copyWith(color: const Color(0xFF94A3B8))),
                const SizedBox(height: 16),
                _gradeBadge(context, meta),
                const SizedBox(height: 16),
                Text(childName,
                    textAlign: TextAlign.center,
                    style: context.typography.lgBold
                        .copyWith(color: const Color(0xFF1E293B))),
                const SizedBox(height: 6),
                Text(
                  headline == subject ? subject : '$headline • $subject',
                  textAlign: TextAlign.center,
                  style: context.typography.smRegular
                      .copyWith(color: const Color(0xFF64748B)),
                ),
                if (paperUrl != null && paperUrl!.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AppNetworkImage(
                      url: paperUrl,
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                _datePill(context, dateStr),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _appFooter(context),
        ],
      ),
    );
  }

  Widget _gradeBadge(BuildContext context, ExamGradeMeta meta) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 96,
          height: 96,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: meta.color.withValues(alpha: 0.10),
            border: Border.all(color: meta.color, width: 4),
          ),
          child: Text(meta.emoji, style: const TextStyle(fontSize: 44)),
        ),
        const SizedBox(height: 12),
        Text(meta.label,
            style: context.typography.xxlBold
                .copyWith(color: meta.color, fontSize: 30, height: 1.0)),
      ],
    );
  }

  Widget _datePill(BuildContext context, String dateStr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.event_rounded, size: 13, color: Color(0xFF94A3B8)),
          const SizedBox(width: 5),
          Text(dateStr,
              style: context.typography.xsMedium
                  .copyWith(color: const Color(0xFF64748B))),
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
              errorBuilder: (_, _, _) => const Icon(Icons.child_care_rounded,
                  size: 15, color: Color(0xFF6366F1))),
        ),
        const SizedBox(width: 8),
        Text('assessment_share_via_app'.tr,
            style: context.typography.xsMedium.copyWith(color: Colors.white)),
      ],
    );
  }
}
