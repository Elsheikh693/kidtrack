import '../../../../../index/index_main.dart';

class ReportStatsGrid extends StatelessWidget {
  const ReportStatsGrid({
    super.key,
    required this.totalActivities,
    required this.totalEvaluations,
    required this.participatingStudents,
    required this.averageRating,
  });

  final int totalActivities;
  final int totalEvaluations;
  final int participatingStudents;
  final double averageRating;

  static const _green = Color(0xFF16A34A);
  static const _amber = Color(0xFFD97706);
  static const _blue = Color(0xFF2563EB);
  static const _purple = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.55,
      children: [
        _StatCard(
          label: 'teacher_report_stat_activities'.tr,
          value: '$totalActivities',
          icon: Icons.play_circle_rounded,
          color: _green,
        ),
        _StatCard(
          label: 'teacher_report_stat_evaluations'.tr,
          value: '$totalEvaluations',
          icon: Icons.star_rounded,
          color: _amber,
        ),
        _StatCard(
          label: 'teacher_report_stat_students'.tr,
          value: '$participatingStudents',
          icon: Icons.people_rounded,
          color: _blue,
        ),
        _StatCard(
          label: 'teacher_report_stat_avg'.tr,
          value: averageRating == 0
              ? '—'
              : '${averageRating.toStringAsFixed(1)}/5',
          icon: Icons.bar_chart_rounded,
          color: _purple,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
