import '../../../../../index/index_main.dart';

/// Bottom sheet a parent confirms a homework was done at home. Instead of
/// picking "who did it", the parent answers a few optional yes/no questions
/// describing HOW the child did the homework, then reports back via [onConfirm].
Future<void> showHomeworkSubmitSheet(
  BuildContext context, {
  required String homeworkTitle,
  required void Function(
    bool? neededHelp,
    bool? guidedHand,
    bool? didEasily,
    String? note,
  ) onConfirm,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _HomeworkSubmitSheet(
      homeworkTitle: homeworkTitle,
      onConfirm: onConfirm,
    ),
  );
}

class _HomeworkSubmitSheet extends StatefulWidget {
  const _HomeworkSubmitSheet({
    required this.homeworkTitle,
    required this.onConfirm,
  });
  final String homeworkTitle;
  final void Function(
    bool? neededHelp,
    bool? guidedHand,
    bool? didEasily,
    String? note,
  ) onConfirm;

  @override
  State<_HomeworkSubmitSheet> createState() => _HomeworkSubmitSheetState();
}

class _HomeworkSubmitSheetState extends State<_HomeworkSubmitSheet> {
  final _noteCtrl = TextEditingController();
  bool? _neededHelp;
  bool? _guidedHand;
  bool? _didEasily;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.borderNeutralPrimary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'hw_submit_title'.tr,
                style: context.typography.mdBold
                    .copyWith(color: AppColors.textDefault),
              ),
              const SizedBox(height: 4),
              Text(
                widget.homeworkTitle,
                style: context.typography.smRegular
                    .copyWith(color: AppColors.textSecondaryParagraph),
              ),
              const SizedBox(height: 18),
              Text(
                'hw_submit_how'.tr,
                style: context.typography.smSemiBold
                    .copyWith(color: AppColors.textDefault),
              ),
              const SizedBox(height: 10),
              _QuestionRow(
                label: 'hw_q_needed_help'.tr,
                value: _neededHelp,
                onChanged: (v) => setState(() => _neededHelp = v),
              ),
              const SizedBox(height: 8),
              _QuestionRow(
                label: 'hw_q_guided_hand'.tr,
                value: _guidedHand,
                onChanged: (v) => setState(() => _guidedHand = v),
              ),
              const SizedBox(height: 8),
              _QuestionRow(
                label: 'hw_q_did_easily'.tr,
                value: _didEasily,
                onChanged: (v) => setState(() => _didEasily = v),
              ),
              const SizedBox(height: 16),
              Text(
                'hw_submit_note'.tr,
                style: context.typography.smSemiBold
                    .copyWith(color: AppColors.textDefault),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteCtrl,
                maxLines: 2,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: 'hw_submit_note_hint'.tr,
                  filled: true,
                  fillColor: AppColors.backgroundNeutral100,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final note = _noteCtrl.text.trim();
                    widget.onConfirm(
                      _neededHelp,
                      _guidedHand,
                      _didEasily,
                      note.isEmpty ? null : note,
                    );
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.check_circle_rounded, size: 20),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successForeground,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  label: Text(
                    'hw_submit_done'.tr,
                    style: context.typography.smSemiBold
                        .copyWith(color: Colors.white),
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

// ── One yes/no question row ─────────────────────────────────────────────────────

class _QuestionRow extends StatelessWidget {
  const _QuestionRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool? value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundNeutral100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: context.typography.smMedium
                  .copyWith(color: AppColors.textDefault),
            ),
          ),
          const SizedBox(width: 8),
          _AnswerPill(
            label: 'hw_answer_yes'.tr,
            selected: value == true,
            color: AppColors.successForeground,
            // Tapping the active answer clears it (back to unanswered).
            onTap: () => onChanged(value == true ? null : true),
          ),
          const SizedBox(width: 6),
          _AnswerPill(
            label: 'hw_answer_no'.tr,
            selected: value == false,
            color: AppColors.grayMedium,
            onTap: () => onChanged(value == false ? null : false),
          ),
        ],
      ),
    );
  }
}

class _AnswerPill extends StatelessWidget {
  const _AnswerPill({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.14) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? color.withValues(alpha: 0.6)
                : AppColors.borderNeutralPrimary.withValues(alpha: 0.6),
          ),
        ),
        child: Text(
          label,
          style: context.typography.smMedium.copyWith(
            color: selected ? color : AppColors.textPrimaryParagraph,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
