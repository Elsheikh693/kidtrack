import '../../../../index/index_main.dart';
import '../../shared/assessment/assessment_result_breakdown.dart';
import '../../shared/assessment/assessment_share_card.dart';
import '../../shared/assessment/assessment_share_preview_sheet.dart';
import '../../shared/assessment/assessment_share.dart';
import 'widgets/retake_banner.dart';

/// Parent's read-only report for one assessment: title/date header, a retake
/// banner when scheduled, the shared result breakdown, and a "share" button
/// that exports a branded image (nursery logo + KidTrack) for social media.
class ParentAssessmentResultView extends StatelessWidget {
  final ChildAssessmentModel row;
  final AssessmentRunModel run;
  final String childName;
  final String nurseryName;
  final String? nurseryLogo;

  const ParentAssessmentResultView({
    super.key,
    required this.row,
    required this.run,
    this.childName = '',
    this.nurseryName = '',
    this.nurseryLogo,
  });

  static const _accent = Color(0xFF4F46E5);

  void _share() {
    final attempt = row.officialAttempt;
    if (attempt == null) return;
    final card = AssessmentShareCard(
      childName: childName,
      nurseryName: nurseryName,
      nurseryLogo: nurseryLogo,
      title: run.title,
      subject: run.subject,
      percentage: attempt.percentage,
      date: run.startDate,
    );
    // Show a motivating preview first — seeing the branded image nudges the
    // parent to actually post it.
    Get.bottomSheet(
      AssessmentSharePreviewSheet(
        card: card,
        onShare: () {
          Get.back();
          captureAndShareAssessment(
            card: card,
            shareText: 'assessment_share_text'.trParams({
              'name': childName,
              'title': run.title,
            }),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final attempt = row.officialAttempt;
    final retakeDate =
        row.hasPendingRetake ? row.latestAttempt?.scheduledRetakeDate : null;

    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: HomeAppBar(
          title: run.title,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        body: attempt == null
            ? const SizedBox.shrink()
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                children: [
                  if (run.subject != null && run.subject!.isNotEmpty) ...[
                    Text(run.subject!,
                        style: context.typography.smMedium
                            .copyWith(color: const Color(0xFF64748B))),
                    const SizedBox(height: 12),
                  ],
                  if (retakeDate != null) ...[
                    RetakeBanner(date: retakeDate),
                    const SizedBox(height: 12),
                  ],
                  AssessmentResultBreakdown(
                    attempt: attempt,
                    scale: run.scale,
                    items: run.items,
                    accent: _accent,
                  ),
                ],
              ),
        bottomNavigationBar: attempt == null
            ? null
            : SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _share,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.ios_share_rounded, size: 18),
                      label: Text('assessment_share_button'.tr,
                          style: context.typography.smSemiBold),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
