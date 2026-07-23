import '../../../../../index/index_main.dart';

/// Compact classroom card sized for a horizontal rail on the teacher home.
/// Kept intentionally light: name, child count, today's attendance ring, and a
/// details affordance — no activities count.
class ClassCard extends StatelessWidget {
  const ClassCard({
    super.key,
    required this.classroom,
    required this.childCount,
    required this.presentCount,
    required this.programName,
    required this.onTap,
  });

  final ClassroomModel classroom;
  final int childCount;
  final int presentCount;
  final String programName;
  final VoidCallback onTap;

  static const List<Color> _accents = [
    AppColors.activityPurple,
    AppColors.activityBlue,
    AppColors.activityOrange,
    AppColors.activityGreen,
    Color(0xFF4F46E5), // indigo
    AppColors.activityAmberBrand,
  ];

  Color get _accent =>
      _accents[classroom.name.hashCode.abs() % _accents.length];

  @override
  Widget build(BuildContext context) {
    final accent = _accent;
    final pct = childCount == 0 ? 0 : (presentCount * 100 / childCount).round();

    return SizedBox(
      width: 244,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: accent.withValues(alpha: .14)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .04),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: .10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Icon(Icons.menu_book_rounded,
                          size: 24, color: accent),
                    ),
                    const Spacer(),
                    if (programName.isNotEmpty)
                      Flexible(
                        child: _StageBadge(label: programName, accent: accent),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  classroom.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.smSemiBold
                      .copyWith(color: AppColors.activitySlate),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.groups_rounded,
                        size: 14, color: AppColors.activityMuted),
                    const SizedBox(width: 5),
                    Text(
                      '$childCount ${'teacher_home_children_unit'.tr}',
                      style: context.typography.xsRegular
                          .copyWith(color: AppColors.activityMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _AttendanceBlock(
                  present: presentCount,
                  total: childCount,
                  pct: pct,
                  accent: accent,
                ),
                const SizedBox(height: 12),
                _DetailsButton(accent: accent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Stage badge ───────────────────────────────────────────────────────────────

class _StageBadge extends StatelessWidget {
  const _StageBadge({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.typography.xsMedium.copyWith(color: accent),
      ),
    );
  }
}

// ── Attendance: label + count on one side, a progress ring on the other ───────

class _AttendanceBlock extends StatelessWidget {
  const _AttendanceBlock({
    required this.present,
    required this.total,
    required this.pct,
    required this.accent,
  });

  final int present;
  final int total;
  final int pct;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'teacher_home_attendance_today'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.xsRegular
                      .copyWith(color: AppColors.activityMuted),
                ),
                const SizedBox(height: 3),
                Text(
                  '$present ${'teacher_home_of'.tr} $total',
                  style: context.typography.smSemiBold
                      .copyWith(color: AppColors.activitySlate),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 42,
            height: 42,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 42,
                  height: 42,
                  child: CircularProgressIndicator(
                    value: total == 0 ? 0 : present / total,
                    strokeWidth: 4,
                    strokeCap: StrokeCap.round,
                    backgroundColor: accent.withValues(alpha: .15),
                    valueColor: AlwaysStoppedAnimation(accent),
                  ),
                ),
                Text(
                  '$pct%',
                  style: context.typography.xsMedium.copyWith(color: accent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Footer: full-width details button ─────────────────────────────────────────

class _DetailsButton extends StatelessWidget {
  const _DetailsButton({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'teacher_home_class_details'.tr,
            style: context.typography.xsMedium.copyWith(color: accent),
          ),
          const SizedBox(width: 2),
          Icon(Icons.chevron_right_rounded, size: 16, color: accent),
        ],
      ),
    );
  }
}
