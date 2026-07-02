import '../../../../../index/index_main.dart';

enum IdleTimelineTileType { completed, next, upcoming }

class IdleTimelineTile extends StatelessWidget {
  const IdleTimelineTile({
    super.key,
    required this.type,
    required this.title,
    required this.timeLabel,
    this.subtitleLabel,
    this.trailingLabel,
    this.isLast = false,
    this.onStart,
  });

  final IdleTimelineTileType type;
  final String title;
  final String timeLabel;
  final String? subtitleLabel;
  final String? trailingLabel;
  final bool isLast;
  final VoidCallback? onStart;

  static const _orange = Color(0xFFF97316);

  @override
  Widget build(BuildContext context) {
    final isCompleted = type == IdleTimelineTileType.completed;
    final isNext = type == IdleTimelineTileType.next;

    final dotColor = isCompleted
        ? AppColors.activityGreen
        : isNext
            ? _orange
            : AppColors.borderNeutralPrimary;

    final titleColor = isCompleted
        ? AppColors.activityGreenDark
        : isNext
            ? AppColors.textDisplay
            : AppColors.textSecondaryParagraph;

    final timeColor = isCompleted
        ? AppColors.activityGreen
        : isNext
            ? _orange
            : AppColors.textSecondaryParagraph;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Timeline spine ──────────────────────────────────────────────────
        SizedBox(
          width: 22,
          child: Column(
            children: [
              const SizedBox(height: 2),
              _Dot(isCompleted: isCompleted, isNext: isNext, color: dotColor),
              if (!isLast)
                Container(
                  width: 2,
                  height: 44,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    color: dotColor.withValues(alpha: isCompleted ? 0.3 : 0.15),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),

        // ── Content ─────────────────────────────────────────────────────────
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 8 : 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.typography.smSemiBold.copyWith(
                          color: titleColor,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationColor:
                              AppColors.activityGreen.withValues(alpha: 0.6),
                          decorationThickness: 1.5,
                        ),
                      ),
                      if (subtitleLabel != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitleLabel!,
                          style: context.typography.xsMedium.copyWith(
                            color: AppColors.textSecondaryParagraph,
                          ),
                        ),
                      ],
                      if (trailingLabel != null) ...[
                        const SizedBox(height: 5),
                        _StatusBadge(
                          label: trailingLabel!,
                          isCompleted: isCompleted,
                          isNext: isNext,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // ── Right side: time + action ──────────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      timeLabel,
                      style: context.typography.xsMedium.copyWith(
                        color: timeColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (isNext && onStart != null) ...[
                      const SizedBox(height: 6),
                      _StartButton(onStart: onStart!),
                    ] else if (isCompleted) ...[
                      const SizedBox(height: 4),
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.activityGreen,
                        size: 16,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _Dot extends StatelessWidget {
  const _Dot({
    required this.isCompleted,
    required this.isNext,
    required this.color,
  });
  final bool isCompleted;
  final bool isNext;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      return Icon(Icons.check_circle_rounded, color: color, size: 18);
    }
    if (isNext) {
      return Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2.5),
        ),
        child: Center(
          child: Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
      );
    }
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.borderNeutralPrimary,
          width: 2,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.isCompleted,
    required this.isNext,
  });
  final String label;
  final bool isCompleted;
  final bool isNext;

  static const _orange = Color(0xFFF97316);
  static const _orangeLight = Color(0xFFFFF7ED);

  @override
  Widget build(BuildContext context) {
    final bg = isNext
        ? _orangeLight
        : isCompleted
            ? AppColors.activityGreenLight
            : AppColors.backgroundNeutralDefault;
    final fg = isNext
        ? _orange
        : isCompleted
            ? AppColors.activityGreen
            : AppColors.textSecondaryParagraph;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: context.typography.xsMedium.copyWith(color: fg),
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onStart,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.activityGreen,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColors.activityGreen.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          'بدء',
          style: context.typography.xsMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
