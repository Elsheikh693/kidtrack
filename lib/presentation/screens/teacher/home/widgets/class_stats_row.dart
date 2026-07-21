import '../../../../../index/index_main.dart';

/// The two-up stat strip on a populated class card:
/// attendance ring · activities today.
class ClassStatsRow extends StatelessWidget {
  const ClassStatsRow({
    super.key,
    required this.presentCount,
    required this.totalCount,
    required this.activitiesCount,
    required this.accent,
  });

  final int presentCount;
  final int totalCount;
  final int activitiesCount;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _StatTile(
                label: 'teacher_home_attendance_today'.tr,
                child: _AttendanceRing(
                  present: presentCount,
                  total: totalCount,
                  accent: accent,
                ),
              ),
            ),
            const _StatDivider(),
            Expanded(
              child: _StatTile(
                label: 'teacher_home_activities_today'.tr,
                child: Column(
                  children: [
                    Icon(Icons.assignment_turned_in_rounded,
                        size: 20, color: accent),
                    const SizedBox(height: 6),
                    Text(
                      '$activitiesCount',
                      style: context.typography.displaySmBold
                          .copyWith(color: AppColors.activitySlate),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.typography.xsRegular
              .copyWith(color: AppColors.activityMuted),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: const Color(0xFFF1F5F9),
    );
  }
}

class _AttendanceRing extends StatelessWidget {
  const _AttendanceRing({
    required this.present,
    required this.total,
    required this.accent,
  });

  final int present;
  final int total;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (present / total).clamp(0.0, 1.0) : 0.0;
    return Column(
      children: [
        SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  value: pct,
                  strokeWidth: 4,
                  backgroundColor: accent.withValues(alpha: .12),
                  valueColor: AlwaysStoppedAnimation(accent),
                ),
              ),
              // Scale the label down only when it would overflow the ring
              // (i.e. the 4-glyph "100%"); shorter values keep full size.
              SizedBox(
                width: 34,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${(pct * 100).round()}%',
                    style:
                        context.typography.displaySmBold.copyWith(color: accent),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$present ${'teacher_home_of'.tr} $total',
          style: context.typography.xsRegular
              .copyWith(color: AppColors.activityMuted),
        ),
      ],
    );
  }
}
