import '../../../../index/index_main.dart';

/// A motivating preview of the branded result image before sharing — the parent
/// sees exactly the beautiful card they're about to post, with an encouraging
/// nudge and a prominent "share now" button.
class AssessmentSharePreviewSheet extends StatelessWidget {
  final Widget card;
  final VoidCallback onShare;

  /// Optional overrides so the same motivating preview can front other branded
  /// shares (e.g. Star of the Week). Fall back to the assessment copy.
  final String? title;
  final String? subtitle;
  final Color accent;

  const AssessmentSharePreviewSheet({
    super.key,
    required this.card,
    required this.onShare,
    this.title,
    this.subtitle,
    this.accent = const Color(0xFF4F46E5),
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(title ?? 'assessment_share_preview_title'.tr,
                textAlign: TextAlign.center,
                style: context.typography.lgBold
                    .copyWith(color: const Color(0xFF1E293B))),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(subtitle ?? 'assessment_share_preview_sub'.tr,
                  textAlign: TextAlign.center,
                  style: context.typography.smRegular
                      .copyWith(color: const Color(0xFF64748B))),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: SizedBox(width: 300, child: card),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onShare,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.ios_share_rounded, size: 19),
                  label: Text('assessment_share_now'.tr,
                      style: context.typography.smSemiBold),
                ),
              ),
            ),
            TextButton(
              onPressed: Get.back,
              child: Text('assessment_share_later'.tr,
                  style: context.typography.smMedium
                      .copyWith(color: const Color(0xFF94A3B8))),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 6),
          ],
        ),
      ),
    );
  }
}
