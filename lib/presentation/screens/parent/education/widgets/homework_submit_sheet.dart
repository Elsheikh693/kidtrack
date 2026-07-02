import '../../../../../index/index_main.dart';
import '../../../../../Data/models/homework_submission/homework_submission_model.dart';

/// Bottom sheet a parent confirms a homework was done at home. Collects who
/// helped (optional) and an optional note, then reports back via [onConfirm].
Future<void> showHomeworkSubmitSheet(
  BuildContext context, {
  required String homeworkTitle,
  required void Function(SubmittedBy by, String? note) onConfirm,
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
  final void Function(SubmittedBy by, String? note) onConfirm;

  @override
  State<_HomeworkSubmitSheet> createState() => _HomeworkSubmitSheetState();
}

class _HomeworkSubmitSheetState extends State<_HomeworkSubmitSheet> {
  final _noteCtrl = TextEditingController();
  SubmittedBy _by = SubmittedBy.self;

  static const _options = <SubmittedBy>[
    SubmittedBy.mother,
    SubmittedBy.father,
    SubmittedBy.self,
  ];

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
                'تأكيد حل الواجب',
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
                'من حلّ الواجب؟',
                style: context.typography.smSemiBold
                    .copyWith(color: AppColors.textDefault),
              ),
              const SizedBox(height: 10),
              Row(
                children: _options.map((o) {
                  final selected = _by == o;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _by = o),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : AppColors.backgroundNeutral100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary.withValues(alpha: 0.5)
                                : AppColors.borderNeutralPrimary
                                    .withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          o.label,
                          style: context.typography.smMedium.copyWith(
                            color: selected
                                ? AppColors.primary
                                : AppColors.textPrimaryParagraph,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text(
                'ملاحظة (اختياري)',
                style: context.typography.smSemiBold
                    .copyWith(color: AppColors.textDefault),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteCtrl,
                maxLines: 2,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: 'مثال: استمتع بحل الواجب 🌟',
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
                    widget.onConfirm(_by, note.isEmpty ? null : note);
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
                    'تم الحل',
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
