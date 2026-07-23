import 'package:flutter/material.dart';
import '../../../../Data/models/nursery_course/nursery_course_model.dart';
import '../../../../index/index_main.dart';
import 'course_lessons_controller.dart';

Future<void> showCreateLessonSheet(
  BuildContext context, {
  required CourseLessonsController controller,
  CourseLesson? editing,
  required HandleKeyboardService keyboardService,
  required List<String> keys,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CreateLessonSheet(
      controller: controller,
      editing: editing,
      keyboardService: keyboardService,
      keys: keys,
    ),
  );
}

class _CreateLessonSheet extends StatefulWidget {
  const _CreateLessonSheet({
    required this.controller,
    this.editing,
    required this.keyboardService,
    required this.keys,
  });

  final CourseLessonsController controller;
  final CourseLesson? editing;
  final HandleKeyboardService keyboardService;
  final List<String> keys;

  @override
  State<_CreateLessonSheet> createState() => _CreateLessonSheetState();
}

class _CreateLessonSheetState extends State<_CreateLessonSheet> {
  final _titleCtrl    = TextEditingController();
  final _descCtrl     = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _urlCtrl      = TextEditingController();
  final _textCtrl     = TextEditingController();
  final _formKey      = GlobalKey<FormState>();

  LessonContentType _contentType = LessonContentType.text;
  bool _saving = false;

  bool get isEditing => widget.editing != null;
  Color get _accentColor => widget.controller.course.category.color;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    if (e != null) {
      _titleCtrl.text    = e.title;
      _descCtrl.text     = e.description ?? '';
      _durationCtrl.text = e.durationMinutes == 0 ? '' : e.durationMinutes.toString();
      _contentType       = e.contentType;
      _urlCtrl.text      = e.contentUrl ?? '';
      _textCtrl.text     = e.textContent ?? '';
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _durationCtrl.dispose();
    _urlCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    final duration = int.tryParse(_durationCtrl.text.trim()) ?? 0;
    final contentUrl = _urlCtrl.text.trim().isEmpty ? null : _urlCtrl.text.trim();
    final textContent = _textCtrl.text.trim().isEmpty ? null : _textCtrl.text.trim();

    bool ok;
    if (isEditing) {
      ok = await widget.controller.updateLesson(
        lesson: widget.editing!,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        durationMinutes: duration,
        contentType: _contentType,
        contentUrl: contentUrl,
        textContent: textContent,
      );
    } else {
      ok = await widget.controller.createLesson(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        durationMinutes: duration,
        contentType: _contentType,
        contentUrl: contentUrl,
        textContent: textContent,
      );
    }

    setState(() => _saving = false);
    if (ok && context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Handle ──────────────────────────────────────────────
                Center(
                  child: Container(
                    width: 40.w, height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // ── Header ───────────────────────────────────────────────
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: _accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(Icons.menu_book_rounded, color: _accentColor, size: 20.sp),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      isEditing ? 'coursesown13_edit_lesson'.tr : 'coursesown13_new_lesson'.tr,
                      style: context.typography.mdBold.copyWith(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),

                // ── Title ────────────────────────────────────────────────
                _Field(
                  controller: _titleCtrl,
                  label: 'coursesown13_lesson_title_label'.tr,
                  hint: 'coursesown13_lesson_title_hint'.tr,
                  accentColor: _accentColor,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'coursesown13_required'.tr : null,
                  focusNode: widget.keyboardService.getFocusNode(widget.keys[0]),
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => FocusScope.of(context).requestFocus(
                    widget.keyboardService.getFocusNode(widget.keys[1]),
                  ),
                ),
                SizedBox(height: 12.h),

                // ── Description + duration ────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _Field(
                        controller: _descCtrl,
                        label: 'coursesown13_short_desc_label'.tr,
                        hint: 'coursesown13_lesson_desc_hint'.tr,
                        accentColor: _accentColor,
                        focusNode: widget.keyboardService.getFocusNode(widget.keys[1]),
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => FocusScope.of(context).requestFocus(
                          widget.keyboardService.getFocusNode(widget.keys[2]),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _Field(
                        controller: _durationCtrl,
                        label: 'coursesown13_duration_label'.tr,
                        hint: '20',
                        keyboardType: TextInputType.number,
                        accentColor: _accentColor,
                        focusNode: widget.keyboardService.getFocusNode(widget.keys[2]),
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => FocusScope.of(context).requestFocus(
                          widget.keyboardService.getFocusNode(widget.keys[3]),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // ── Content type picker ───────────────────────────────────
                Text('coursesown13_content_type'.tr, style: context.typography.smSemiBold.copyWith(fontSize: 13)),
                SizedBox(height: 8.h),
                _ContentTypePicker(
                  selected: _contentType,
                  onSelect: (t) => setState(() => _contentType = t),
                ),
                SizedBox(height: 16.h),

                // ── Content input (dynamic) ───────────────────────────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _contentType == LessonContentType.text
                      ? _Field(
                          key: const ValueKey('text'),
                          controller: _textCtrl,
                          label: 'coursesown13_lesson_content_text_label'.tr,
                          hint: 'coursesown13_lesson_content_text_hint'.tr,
                          maxLines: 6,
                          accentColor: _accentColor,
                          focusNode: widget.keyboardService.getFocusNode(widget.keys[3]),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => FocusScope.of(context).unfocus(),
                        )
                      : _Field(
                          key: const ValueKey('url'),
                          controller: _urlCtrl,
                          label: _urlLabel,
                          hint: _urlHint,
                          accentColor: _accentColor,
                          keyboardType: TextInputType.url,
                          focusNode: widget.keyboardService.getFocusNode(widget.keys[4]),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => FocusScope.of(context).unfocus(),
                        ),
                ),
                SizedBox(height: 24.h),

                // ── Submit ───────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: FilledButton(
                    onPressed: _saving ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: _accentColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    ),
                    child: _saving
                        ? SizedBox(
                            width: 20.w, height: 20.h,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            isEditing ? 'coursesown13_save_changes'.tr : 'coursesown13_add_lesson'.tr,
                            style: context.typography.displaySmBold.copyWith(fontSize: 15),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get _urlLabel => switch (_contentType) {
    LessonContentType.video => 'coursesown13_video_url_label'.tr,
    LessonContentType.pdf   => 'coursesown13_pdf_url_label'.tr,
    LessonContentType.image => 'coursesown13_image_url_label'.tr,
    _                       => 'coursesown13_url_label'.tr,
  };

  String get _urlHint => switch (_contentType) {
    LessonContentType.video => 'https://youtube.com/...',
    LessonContentType.pdf   => 'https://example.com/file.pdf',
    LessonContentType.image => 'https://example.com/image.jpg',
    _                       => 'https://',
  };
}

// ─── Content type picker ──────────────────────────────────────────────────────

class _ContentTypePicker extends StatelessWidget {
  const _ContentTypePicker({required this.selected, required this.onSelect});

  final LessonContentType selected;
  final ValueChanged<LessonContentType> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: LessonContentType.values.map((t) {
        final isSelected = selected == t;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 6.w),
            child: GestureDetector(
              onTap: () => onSelect(t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? t.color : t.color.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isSelected ? t.color : t.color.withOpacity(0.2),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(t.icon, size: 18.sp, color: isSelected ? Colors.white : t.color),
                    SizedBox(height: 4.h),
                    Text(
                      t.label,
                      style: context.typography.smSemiBold.copyWith(
                        fontSize: 10,
                        color: isSelected ? Colors.white : t.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Text field ───────────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  const _Field({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.accentColor,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final Color accentColor;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.typography.smSemiBold.copyWith(fontSize: 13)),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          focusNode: focusNode,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: context.typography.xsRegular.copyWith(color: Colors.grey.shade400, fontSize: 13),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: accentColor),
            ),
          ),
        ),
      ],
    );
  }
}
