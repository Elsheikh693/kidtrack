import '../../../../../index/index_main.dart';

class ReportInsightsSection extends StatelessWidget {
  const ReportInsightsSection({super.key, required this.insights});

  final List<String> insights;

  static const _green = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _green.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: _green,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'teacher_report_insights'.tr,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...insights.map(
            (insight) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                insight,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF374151),
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
