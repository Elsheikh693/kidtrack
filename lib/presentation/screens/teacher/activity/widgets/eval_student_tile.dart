import '../../../../../index/index_main.dart';
import 'eval_label.dart';
import 'eval_button.dart';

class EvalStudentTile extends StatelessWidget {
  const EvalStudentTile({
    super.key,
    required this.child,
    required this.currentEval,
    required this.note,
    required this.onEval,
    required this.onAddNote,
    required this.index,
  });

  final ChildModel child;
  final EvalLevel? currentEval;
  final String? note;
  final void Function(EvalLevel) onEval;
  final VoidCallback onAddNote;
  final int index;

  static const _avatarColors = [
    Color(0xFF7C3AED),
    Color(0xFF0891B2),
    Color(0xFF16A34A),
    Color(0xFFDC2626),
    Color(0xFFD97706),
    Color(0xFF0D9488),
    Color(0xFF9333EA),
    Color(0xFF2563EB),
  ];

  Color get _borderColor {
    if (currentEval == null) return Colors.transparent;
    return switch (currentEval!) {
      EvalLevel.excellent => AppColors.activityGreen,
      EvalLevel.needsFollow => AppColors.activityAmber,
      EvalLevel.needsAttention => AppColors.activityRed,
    };
  }

  Color get _bgColor {
    if (currentEval == null) return Colors.white;
    return switch (currentEval!) {
      EvalLevel.excellent => AppColors.activityGreenLight,
      EvalLevel.needsFollow => AppColors.activityAmberLight,
      EvalLevel.needsAttention => AppColors.activityRedLight,
    };
  }

  @override
  Widget build(BuildContext context) {
    final avatarColor = _avatarColors[index % _avatarColors.length];
    final initial = child.firstName.isNotEmpty ? child.firstName[0] : '؟';
    final hasNote = note != null && note!.isNotEmpty;
    final isEvaluated = currentEval != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEvaluated
              ? _borderColor.withValues(alpha: 0.25)
              : Colors.grey.shade100,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 4,
                color: _borderColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: avatarColor.withValues(alpha: 0.15),
                            backgroundImage: child.hasImage
                                ? appCachedImageProvider(child.profileImage)
                                : null,
                            child: child.hasImage
                                ? null
                                : Text(
                                    initial,
                                    style: context.typography.displaySmBold
                                        .copyWith(color: avatarColor),
                                  ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  child.fullName,
                                  style: context.typography.displaySmBold
                                      .copyWith(color: AppColors.textDisplay),
                                ),
                                if (isEvaluated) ...[
                                  const SizedBox(height: 1),
                                  EvalLabel(level: currentEval!),
                                ],
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: onAddNote,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: hasNote
                                    ? AppColors.activityPurple
                                        .withValues(alpha: 0.1)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                hasNote
                                    ? Icons.sticky_note_2_rounded
                                    : Icons.add_comment_outlined,
                                size: 16,
                                color: hasNote
                                    ? AppColors.activityPurple
                                    : Colors.grey.shade400,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          EvalButton(
                            level: EvalLevel.excellent,
                            isSelected: currentEval == EvalLevel.excellent,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              onEval(EvalLevel.excellent);
                            },
                          ),
                          const SizedBox(width: 6),
                          EvalButton(
                            level: EvalLevel.needsFollow,
                            isSelected: currentEval == EvalLevel.needsFollow,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              onEval(EvalLevel.needsFollow);
                            },
                          ),
                          const SizedBox(width: 6),
                          EvalButton(
                            level: EvalLevel.needsAttention,
                            isSelected: currentEval == EvalLevel.needsAttention,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              onEval(EvalLevel.needsAttention);
                            },
                          ),
                        ],
                      ),
                      if (hasNote) ...[
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: onAddNote,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.activityPurple
                                  .withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.format_quote_rounded,
                                    size: 13,
                                    color: AppColors.activityPurple),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    note!,
                                    style: context.typography.xsMedium.copyWith(
                                      color: AppColors.activityPurple,
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
