import '../../../../../index/index_main.dart';
import 'quick_homework_sheet_header.dart';
import 'homework_text_field.dart';

class QuickHomeworkSheet extends StatefulWidget {
  const QuickHomeworkSheet({
    super.key,
    this.subjectName,
    required this.onSave,
  });
  final String? subjectName;
  final Future<void> Function(String title, String? description) onSave;

  @override
  State<QuickHomeworkSheet> createState() => _QuickHomeworkSheetState();
}

class _QuickHomeworkSheetState extends State<QuickHomeworkSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _isSaving = false.obs;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    _isSaving.value = true;
    await widget.onSave(
      _titleCtrl.text.trim(),
      _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
    );
    _isSaving.value = false;
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              QuickHomeworkSheetHeader(subjectName: widget.subjectName),
              const SizedBox(height: 18),
              HomeworkTextField(
                controller: _titleCtrl,
                hint: 'teacher_homework_title_hint'.tr,
                autofocus: true,
              ),
              const SizedBox(height: 10),
              HomeworkTextField(
                controller: _descCtrl,
                hint: 'teacher_homework_desc_hint'.tr,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.activityAmberBrand,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _isSaving.value ? null : _save,
                      icon: _isSaving.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.send_rounded, size: 18),
                      label: Text(
                        'teacher_homework_post'.tr,
                        style: context.typography.smSemiBold,
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
