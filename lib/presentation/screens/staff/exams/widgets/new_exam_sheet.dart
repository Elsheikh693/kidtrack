import '../../../../../index/index_main.dart';

/// Bottom sheet to create a new class exam: required subject, optional friendly
/// title, and the exam date. Calls [onSubmit] with the collected values.
class NewExamSheet extends StatefulWidget {
  const NewExamSheet({
    super.key,
    required this.classroomName,
    required this.onSubmit,
  });

  final String classroomName;
  final void Function(String subject, String title, DateTime date) onSubmit;

  @override
  State<NewExamSheet> createState() => _NewExamSheetState();
}

class _NewExamSheetState extends State<NewExamSheet> {
  final _title = TextEditingController();
  DateTime _date = DateTime.now();
  bool _subjectError = false;

  // Subject is picked from the nursery's existing subjects.
  List<String> _subjects = const [];
  String? _selectedSubject;

  @override
  void initState() {
    super.initState();
    Get.find<SubjectParentService>().getAll(callBack: (list) {
      if (!mounted) return;
      setState(() {
        _subjects = list
            .whereType<SubjectModel>()
            .map((s) => s.name)
            .where((n) => n.isNotEmpty)
            .toList()
          ..sort();
      });
    });
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showAppDatePicker(context, initialDate: _date);
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    if (_selectedSubject == null || _selectedSubject!.isEmpty) {
      setState(() => _subjectError = true);
      return;
    }
    Get.back();
    widget.onSubmit(_selectedSubject!, _title.text, _date);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
          ),
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 22.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondaryParagraph.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              AppText(
                text: 'exam_new_title'.tr,
                textStyle: context.typography.mdBold
                    .copyWith(color: AppColors.textPrimaryParagraph),
              ),
              SizedBox(height: 16.h),
              _subjectDropdown(context),
              SizedBox(height: 12.h),
              AppTextField(
                controller: _title,
                labelText: 'exam_name_label'.tr,
                hintText: 'exam_name_hint'.tr,
              ),
              SizedBox(height: 12.h),
              _dateRow(context),
              SizedBox(height: 20.h),
              PrimaryTextButton(
                label: AppText(
                  text: 'exam_create'.tr,
                  textStyle: context.typography.smSemiBold
                      .copyWith(color: AppColors.white),
                ),
                appButtonSize: AppButtonSize.large,
                onTap: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _subjectDropdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: 'exam_subject_label'.tr,
          textStyle: context.typography.xsMedium
              .copyWith(color: AppColors.textSecondaryParagraph),
        ),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: _subjectError
                  ? const Color(0xFFDC2626)
                  : Colors.transparent,
            ),
          ),
          child: _subjects.isEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: AppText(
                    text: 'exam_subject_no_subjects'.tr,
                    textStyle: context.typography.smRegular
                        .copyWith(color: AppColors.textSecondaryParagraph),
                  ),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _subjects.contains(_selectedSubject)
                        ? _selectedSubject
                        : null,
                    borderRadius: BorderRadius.circular(14.r),
                    icon: Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textSecondaryParagraph),
                    hint: AppText(
                      text: 'exam_subject_hint'.tr,
                      textStyle: context.typography.smRegular
                          .copyWith(color: AppColors.textSecondaryParagraph),
                    ),
                    style: context.typography.smMedium
                        .copyWith(color: AppColors.textPrimaryParagraph),
                    items: [
                      for (final s in _subjects)
                        DropdownMenuItem(value: s, child: Text(s)),
                    ],
                    onChanged: (v) => setState(() {
                      _selectedSubject = v;
                      _subjectError = false;
                    }),
                  ),
                ),
        ),
        if (_subjectError) ...[
          SizedBox(height: 4.h),
          AppText(
            text: 'exam_subject_required'.tr,
            textStyle: context.typography.xsRegular
                .copyWith(color: const Color(0xFFDC2626)),
          ),
        ],
      ],
    );
  }

  Widget _dateRow(BuildContext context) {
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Icon(Icons.event_rounded, size: 20.r, color: AppColors.primary),
            SizedBox(width: 10.w),
            AppText(
              text: 'exam_date_label'.tr,
              textStyle: context.typography.smMedium
                  .copyWith(color: AppColors.textSecondaryParagraph),
            ),
            const Spacer(),
            AppText(
              text:
                  '${_date.year}/${_date.month.toString().padLeft(2, '0')}/${_date.day.toString().padLeft(2, '0')}',
              textStyle: context.typography.smSemiBold
                  .copyWith(color: AppColors.textPrimaryParagraph),
            ),
          ],
        ),
      ),
    );
  }
}
