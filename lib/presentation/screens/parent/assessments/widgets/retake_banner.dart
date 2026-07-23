import '../../../../../index/index_main.dart';

/// Amber banner telling the parent a re-assessment is scheduled for their child.
class RetakeBanner extends StatelessWidget {
  final int date;

  const RetakeBanner({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final d = DateTime.fromMillisecondsSinceEpoch(date);
    final formatted =
        '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFCD34D)),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_repeat_rounded,
              color: Color(0xFFB45309), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'assessment_retake_scheduled'.trParams({'date': formatted}),
              style: context.typography.xsMedium
                  .copyWith(color: const Color(0xFF92400E)),
            ),
          ),
        ],
      ),
    );
  }
}
