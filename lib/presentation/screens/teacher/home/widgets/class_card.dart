import '../../../../../index/index_main.dart';
import '../child_preview.dart';

class ClassCard extends StatelessWidget {
  const ClassCard({
    super.key,
    required this.classroom,
    required this.childCount,
    required this.previews,
    required this.subjects,
    required this.attentionCount,
    required this.onTap,
  });

  final ClassroomModel classroom;
  final int childCount;
  final List<ChildPreview> previews;
  final List<SubjectModel> subjects;
  final int attentionCount;
  final VoidCallback onTap;

  static const List<Color> _accents = [
    AppColors.activityBlue,
    AppColors.activityPurple,
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
                // ── Header: icon · name · count pill ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
                        child: Icon(
                          Icons.meeting_room_rounded,
                          size: 24,
                          color: accent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          classroom.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.typography.lgBold.copyWith(
                            color: AppColors.activitySlate,
                          ),
                        ),
                      ),
                      _CountPill(count: childCount, accent: accent),
                    ],
                  ),
                ),

                // ── Avatar stack / empty ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: childCount == 0
                      ? Row(
                          children: [
                            const Icon(
                              Icons.person_add_alt_1_rounded,
                              size: 16,
                              color: AppColors.activityMuted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'لا يوجد أطفال بعد',
                              style: context.typography.xsRegular.copyWith(
                                color: AppColors.activityMuted,
                              ),
                            ),
                          ],
                        )
                      : _AvatarStack(
                          previews: previews,
                          totalCount: childCount,
                          accent: accent,
                        ),
                ),

                // ── Subject chips ──
                if (subjects.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: subjects
                          .map((s) => _SubjectChip(name: s.name))
                          .toList(),
                    ),
                  ),

                // ── Footer ──
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    children: [
                      if (attentionCount > 0) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.activityRed.withValues(alpha: .08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                size: 13,
                                color: AppColors.activityRed,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$attentionCount يحتاج متابعة',
                                style: context.typography.xsMedium.copyWith(
                                  color: AppColors.activityRed,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        'افتح الفصل',
                        style: context.typography.smSemiBold.copyWith(
                          color: accent,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: accent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.count, required this.accent});

  final int count;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.groups_rounded, size: 15, color: accent),
          const SizedBox(width: 5),
          Text(
            '$count طفل',
            style: context.typography.mdRegular.copyWith(color: accent),
          ),
        ],
      ),
    );
  }
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack({
    required this.previews,
    required this.totalCount,
    required this.accent,
  });

  final List<ChildPreview> previews;
  final int totalCount;
  final Color accent;

  // Outer avatar diameter (38 glyph + 2px white ring on each side).
  static const double _size = 42;
  static const double _step = 26;

  @override
  Widget build(BuildContext context) {
    final shown = previews.take(5).toList();
    final remaining = totalCount - shown.length;
    final bubbleCount = remaining > 0 ? 1 : 0;
    final items = shown.length + bubbleCount;
    final width = items == 0 ? 0.0 : _size + (items - 1) * _step;

    return SizedBox(
      height: _size,
      width: width,
      child: Stack(
        children: [
          for (int i = 0; i < shown.length; i++)
            Positioned(
              right: i * _step,
              child: _Avatar(preview: shown[i], accent: accent),
            ),
          if (remaining > 0)
            Positioned(
              right: shown.length * _step,
              child: _MoreBubble(count: remaining),
            ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.preview, required this.accent});

  final ChildPreview preview;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final initial = preview.name.trim().isNotEmpty
        ? preview.name.trim().characters.first
        : '?';
    final fallback = Container(
      width: 38,
      height: 38,
      color: accent.withValues(alpha: .14),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: context.typography.smSemiBold.copyWith(color: accent),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: SizedBox(
          width: 38,
          height: 38,
          child: AppNetworkImage(
            url: preview.image,
            width: 38,
            height: 38,
            errorWidget: fallback,
          ),
        ),
      ),
    );
  }
}

class _MoreBubble extends StatelessWidget {
  const _MoreBubble({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(
          color: Color(0xFFEEF1F6),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          '+$count',
          style: context.typography.xsBold.copyWith(
            color: AppColors.activitySlate,
          ),
        ),
      ),
    );
  }
}

class _SubjectChip extends StatelessWidget {
  const _SubjectChip({required this.name});

  final String name;

  static const List<Color> _colors = [
    AppColors.activityBlue,
    AppColors.activityPurple,
    AppColors.activityAmberBrand,
    AppColors.activityGreen,
    Color(0xFFEC4899),
    AppColors.activityOrange,
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[name.hashCode.abs() % _colors.length];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: .22)),
      ),
      child: Text(
        name,
        style: context.typography.xsMedium.copyWith(color: color),
      ),
    );
  }
}
