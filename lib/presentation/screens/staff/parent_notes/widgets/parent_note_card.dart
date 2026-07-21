import '../../../../../index/index_main.dart';

/// A single guardian note the staff reads: which child, which session, and the
/// parent's words.
class ParentNoteCard extends StatelessWidget {
  const ParentNoteCard({
    super.key,
    required this.note,
    required this.classroomLabel,
  });

  final GuardianNoteModel note;
  final String classroomLabel;

  static const _accent = Color(0xFF6C4DDB);

  String get _sessionLine {
    final title = note.activityTitle.trim().isNotEmpty
        ? note.activityTitle
        : note.subjectName;
    final time = _clock(note.activityStartedAt);
    if (title.isEmpty) return time;
    return time.isEmpty ? title : '$title · $time';
  }

  static String _clock(int ms) {
    if (ms <= 0) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderNeutralPrimary.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person_rounded,
                    size: 21, color: _accent),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: note.childName.isNotEmpty
                          ? note.childName
                          : 'parent_notes_child_fallback'.tr,
                      textStyle: context.typography.smSemiBold.copyWith(
                        color: AppColors.textDefault,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      text: classroomLabel,
                      textStyle: context.typography.xsRegular.copyWith(
                        color: AppColors.textSecondaryParagraph,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome_rounded,
                    size: 13, color: _accent),
                const SizedBox(width: 6),
                Flexible(
                  child: AppText(
                    text: _sessionLine,
                    textStyle: context.typography.xsMedium.copyWith(
                      color: _accent,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          AppText(
            text: note.content,
            textStyle: context.typography.mdRegular.copyWith(
              color: AppColors.textDefault,
            ),
          ),
        ],
      ),
    );
  }
}
