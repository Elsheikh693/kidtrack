import '../../../../index/index_main.dart';
import '../../shared/assessment/assessment_result_breakdown.dart';
import 'widgets/retake_banner.dart';

/// Parent's read-only report for one assessment: title/date header, a retake
/// banner when scheduled, and the shared result breakdown.
class ParentAssessmentResultView extends StatelessWidget {
  final ChildAssessmentModel row;
  final AssessmentRunModel run;

  const ParentAssessmentResultView({
    super.key,
    required this.row,
    required this.run,
  });

  static const _accent = Color(0xFF4F46E5);

  @override
  Widget build(BuildContext context) {
    final attempt = row.officialAttempt;
    final retakeDate =
        row.hasPendingRetake ? row.latestAttempt?.scheduledRetakeDate : null;

    return Directionality(
      textDirection: TextDirection.rtl,
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
      ),
    );
  }
}
