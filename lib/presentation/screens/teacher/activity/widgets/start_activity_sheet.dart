import '../../../../../index/index_main.dart';
import 'subject_picker.dart';

class StartActivitySheet extends StatefulWidget {
  const StartActivitySheet({
    super.key,
    required this.subjects,
    required this.onStart,
    required this.ctrl,
    this.classrooms = const [],
    this.defaultClassroomId,
  });

  final List<SubjectModel> subjects;
  final List<ClassroomModel> classrooms;
  final String? defaultClassroomId;
  final TeacherActivityController ctrl;
  final void Function(
    String title,
    String? subjectId,
    String? subjectName,
    String? classroomId,
  ) onStart;

  @override
  State<StartActivitySheet> createState() => _StartActivitySheetState();
}

class _StartActivitySheetState extends State<StartActivitySheet>
    with KeyboardSheetMixin {
  final _titleCtrl = TextEditingController();
  SubjectModel? _selectedSubject;
  String? _selectedClassroomId;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedClassroomId = widget.defaultClassroomId ??
        (widget.classrooms.isNotEmpty ? widget.classrooms.first.key : null);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  void _onSubjectSelected(SubjectModel? s) {
    setState(() => _selectedSubject = s);
    widget.ctrl.loadPendingHomeworkForSubject(s?.key);
  }

  void _onClassroomSelected(String id) {
    final allowed = widget.ctrl.subjectsForClassroom(id);
    final stillValid =
        allowed.any((s) => s.key == _selectedSubject?.key);
    setState(() {
      _selectedClassroomId = id;
      if (!stillValid) _selectedSubject = null;
    });
    if (!stillValid) widget.ctrl.loadPendingHomeworkForSubject(null);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onStart(
      _titleCtrl.text.trim(),
      _selectedSubject?.key,
      _selectedSubject?.name,
      _selectedClassroomId,
    );
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxH = media.size.height * 0.85 - media.viewInsets.bottom;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxH),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
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
                    const SizedBox(height: 16),
                    // Title row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.activityGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.play_arrow_rounded,
                              color: AppColors.activityGreen, size: 22),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'teacher_activity_new_title'.tr,
                          style: context.typography.lgBold
                              .copyWith(color: AppColors.textDisplay),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Classroom picker (if multiple)
                    if (widget.classrooms.length > 1) ...[
                      Text(
                        'الفصل',
                        style: context.typography.xsMedium
                            .copyWith(color: AppColors.textPrimaryParagraph),
                      ),
                      const SizedBox(height: 8),
                      _ClassroomRow(
                        classrooms: widget.classrooms,
                        selected: _selectedClassroomId,
                        onSelect: _onClassroomSelected,
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Subject picker
                    Text(
                      'teacher_activity_subject_label'.tr,
                      style: context.typography.xsMedium
                          .copyWith(color: AppColors.textPrimaryParagraph),
                    ),
                    const SizedBox(height: 8),
                    SubjectPicker(
                      subjects:
                          widget.ctrl.subjectsForClassroom(_selectedClassroomId),
                      selected: _selectedSubject,
                      onSelect: _onSubjectSelected,
                    ),
                    // Pending homework banner — hidden for now (will be reworked later)
                    const SizedBox(height: 16),
                    // Activity title
                    Text(
                      'teacher_activity_title_label'.tr,
                      style: context.typography.xsMedium
                          .copyWith(color: AppColors.textPrimaryParagraph),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleCtrl,
                      textDirection: TextDirection.rtl,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'teacher_activity_title_hint'.tr,
                        hintTextDirection: TextDirection.rtl,
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.activityGreen, width: 1.5),
                        ),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'teacher_activity_title_required'.tr
                          : null,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.activityGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _submit,
                        icon: const Icon(Icons.play_arrow_rounded, size: 22),
                        label: Text(
                          'teacher_activity_start_btn'.tr,
                          style: context.typography.mdBold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Classroom row ─────────────────────────────────────────────────────────────

class _ClassroomRow extends StatelessWidget {
  const _ClassroomRow({
    required this.classrooms,
    required this.selected,
    required this.onSelect,
  });
  final List<ClassroomModel> classrooms;
  final String? selected;
  final void Function(String) onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: classrooms.map((c) {
          final isActive = selected == c.key;
          return GestureDetector(
            onTap: () => onSelect(c.key ?? ''),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.activityGreen
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                c.name,
                style: context.typography.smMedium.copyWith(
                  color: isActive ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
