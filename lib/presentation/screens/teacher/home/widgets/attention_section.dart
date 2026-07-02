import '../../../../../index/index_main.dart';
import '../child_attention_entry.dart';

class AttentionSection extends StatelessWidget {
  const AttentionSection({super.key, required this.entries});

  final List<ChildAttentionEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(count: entries.length),
          const SizedBox(height: 10),
          ...entries.map((e) => _AttentionCard(entry: e)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.activityRed.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.activityRed,
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'child_state_attention_title'.tr,
            style: context.typography.displaySmBold.copyWith(
              color: AppColors.activityRed,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.activityRed,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: context.typography.mdBold.copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _AttentionCard extends StatelessWidget {
  const _AttentionCard({required this.entry});

  final ChildAttentionEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.activityRed.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.activityRed.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.backgroundWarningLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.activityAmberBrand.withValues(alpha: 0.3),
              ),
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                entry.stateTitle,
                style: context.typography.xsMedium.copyWith(
                  color: AppColors.activityAmberBrand,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              entry.childName,
              style: context.typography.smSemiBold.copyWith(
                color: AppColors.activitySlate,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.activityPurple.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              entry.classroomName,
              style: context.typography.xsRegular.copyWith(
                color: AppColors.activityPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
