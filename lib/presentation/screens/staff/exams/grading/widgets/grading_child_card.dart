import 'dart:io';

import '../../../../../../index/index_main.dart';
import 'grade_pills.dart';

/// One child's grading card: avatar + name, verbal-grade pills, a photo of the
/// paper (pick from camera/gallery) and an optional note, with an independent
/// save. Prefilled from any existing result.
class GradingChildCard extends StatefulWidget {
  const GradingChildCard({
    super.key,
    required this.child,
    required this.existing,
    required this.onSave,
  });

  final ChildModel child;
  final ExamResultModel? existing;
  final Future<void> Function(
    ExamGrade grade,
    File? paperFile,
    String? existingPaperUrl,
    String note,
  ) onSave;

  @override
  State<GradingChildCard> createState() => _GradingChildCardState();
}

class _GradingChildCardState extends State<GradingChildCard> {
  late final TextEditingController _note;
  ExamGrade? _grade;
  File? _file;
  String? _existingUrl;

  @override
  void initState() {
    super.initState();
    _grade = ExamGrade.fromKey(widget.existing?.grade);
    _note = TextEditingController(text: widget.existing?.note ?? '');
    _existingUrl = widget.existing?.paperUrl;
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    await PickedImage().pickImage(callBack: (file) async {
      if (file != null) setState(() => _file = file);
    });
  }

  Future<void> _save() async {
    final grade = _grade;
    if (grade == null) return;
    await widget.onSave(grade, _file, _existingUrl, _note.text);
  }

  @override
  Widget build(BuildContext context) {
    final saved = widget.existing != null;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: saved
              ? AppColors.activityGreen.withValues(alpha: 0.4)
              : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ChildAvatar(
                name: widget.child.fullName,
                imageUrl: widget.child.profileImage,
                size: 40,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: AppText(
                  text: widget.child.fullName,
                  maxLines: 1,
                  textStyle: context.typography.smSemiBold
                      .copyWith(color: AppColors.textPrimaryParagraph),
                ),
              ),
              if (saved)
                Icon(Icons.check_circle_rounded,
                    color: AppColors.activityGreen, size: 20.r),
            ],
          ),
          SizedBox(height: 12.h),
          GradePills(
            selected: _grade,
            onSelect: (g) => setState(() => _grade = g),
          ),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _photo(context),
              SizedBox(width: 10.w),
              Expanded(
                child: AppTextField(
                  controller: _note,
                  hintText: 'exam_note_hint'.tr,
                  maxLines: 2,
                  showShadow: false,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: PrimaryTextButton(
              label: AppText(
                text: (saved ? 'exam_update' : 'exam_save').tr,
                textStyle: context.typography.smSemiBold.copyWith(
                  color: _grade == null
                      ? AppColors.white.withValues(alpha: 0.7)
                      : AppColors.white,
                ),
              ),
              appButtonSize: AppButtonSize.medium,
              onTap: _grade == null ? null : _save,
            ),
          ),
        ],
      ),
    );
  }

  Widget _photo(BuildContext context) {
    return GestureDetector(
      onTap: _pick,
      child: Container(
        width: 64.w,
        height: 64.w,
        decoration: BoxDecoration(
          color: AppColors.primary10,
          borderRadius: BorderRadius.circular(14.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: _file != null
            ? Image.file(_file!, fit: BoxFit.cover)
            : (_existingUrl != null && _existingUrl!.isNotEmpty)
                ? AppNetworkImage(
                    url: _existingUrl, width: 64.w, height: 64.w)
                : Icon(Icons.add_a_photo_rounded,
                    color: AppColors.primary, size: 24.r),
      ),
    );
  }
}
