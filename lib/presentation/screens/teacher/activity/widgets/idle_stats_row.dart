import '../../../../../index/index_main.dart';

class IdleStatsRow extends StatelessWidget {
  const IdleStatsRow({
    super.key,
    required this.activitiesCount,
    required this.evaluationsCount,
    required this.studentsCount,
  });

  final int activitiesCount;
  final int evaluationsCount;
  final int studentsCount;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _StatItem(
              value: '$activitiesCount',
              label: 'teacheract33_stat_activities_today'.tr,
              icon: Icons.play_circle_outline_rounded,
              color: const Color(0xFF16A34A),
            ),
            _VertDivider(),
            _StatItem(
              value: '$evaluationsCount',
              label: 'teacheract33_stat_evaluations'.tr,
              icon: Icons.star_outline_rounded,
              color: const Color(0xFFD97706),
            ),
            _VertDivider(),
            _StatItem(
              value: '$studentsCount',
              label: 'teacheract33_stat_students'.tr,
              icon: Icons.group_rounded,
              color: const Color(0xFF0891B2),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: context.typography.xlBold.copyWith(color: const Color(0xFF1F2937)),
          ),
          Text(
            label,
            style: context.typography.xsMedium.copyWith(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 50, color: Colors.grey.shade100);
}
