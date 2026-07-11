import '../../../../../index/index_main.dart';
import 'class_stats_row.dart';

class ClassCard extends StatelessWidget {
  const ClassCard({
    super.key,
    required this.classroom,
    required this.childCount,
    required this.presentCount,
    required this.programName,
    required this.activitiesCount,
    required this.onTap,
  });

  final ClassroomModel classroom;
  final int childCount;
  final int presentCount;
  final String programName;
  final int activitiesCount;
  final VoidCallback onTap;

  static const List<Color> _accents = [
    AppColors.activityPurple,
    AppColors.activityBlue,
    AppColors.activityOrange,
    AppColors.activityGreen,
    Color(0xFFEC4899),
    AppColors.activityAmberBrand,
  ];

  Color get _accent =>
      _accents[classroom.name.hashCode.abs() % _accents.length];

  @override
  Widget build(BuildContext context) {
    final accent = _accent;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.borderNeutralPrimary.withValues(alpha: .10),
              ),
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
              children: [
                _CardHeader(
                  name: classroom.name,
                  childCount: childCount,
                  programName: programName,
                  accent: accent,
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                childCount == 0
                    ? _EmptyBody(accent: accent)
                    : ClassStatsRow(
                        presentCount: presentCount,
                        totalCount: childCount,
                        activitiesCount: activitiesCount,
                        accent: accent,
                      ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: _DetailsButton(accent: accent),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Header: icon · name · child count · stage badge ───────────────────────────

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.name,
    required this.childCount,
    required this.programName,
    required this.accent,
  });

  final String name;
  final int childCount;
  final String programName;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.menu_book_rounded, size: 24, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.smSemiBold
                      .copyWith(color: AppColors.activitySlate),
                ),
                const SizedBox(height: 3),
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
              ],
            ),
          ),
          if (programName.isNotEmpty) _StageBadge(label: programName, accent: accent),
        ],
      ),
    );
  }
}

class _StageBadge extends StatelessWidget {
  const _StageBadge({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: context.typography.xsMedium.copyWith(color: accent),
      ),
    );
  }
}

// ── Empty body (no children yet) ──────────────────────────────────────────────

class _EmptyBody extends StatelessWidget {
  const _EmptyBody({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .08),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(Icons.person_add_alt_1_rounded,
                size: 20, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'teacher_home_no_children_yet'.tr,
                  style: context.typography.smSemiBold
                      .copyWith(color: AppColors.activitySlate),
                ),
                const SizedBox(height: 3),
                Text(
                  'teacher_home_no_children_hint'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.xsRegular
                      .copyWith(color: AppColors.activityMuted),
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
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'teacher_home_class_details'.tr,
            style: context.typography.smMedium.copyWith(color: accent),
          ),
          const SizedBox(width: 2),
          Icon(Icons.chevron_right_rounded, size: 18, color: accent),
        ],
      ),
    );
  }
}
