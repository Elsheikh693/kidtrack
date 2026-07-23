import '../../../../../index/index_main.dart';
import 'subject_picker.dart';
import 'classroom_picker.dart';
import 'activity_children_picker.dart';

class StartActivitySheet extends StatefulWidget {
  const StartActivitySheet({
    super.key,
    required this.subjects,
    required this.onStart,
    required this.ctrl,
    this.classrooms = const [],
    this.defaultClassroomId,
    this.mode = 'class',
  });

  final List<SubjectModel> subjects;
  final List<ClassroomModel> classrooms;
  final String? defaultClassroomId;
  final TeacherActivityController ctrl;

  /// 'class'  → whole-classroom session (no child picker).
  /// 'activity' → teacher first picks a subset of children to include.
  final String mode;

  final void Function(
    String title,
    String? subjectId,
    String? subjectName,
    String? classroomId,
    List<String>? childIds,
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

  // When true the selection mirrors "everyone present" (only after the teacher
  // taps "select all"); the default is an empty, explicit selection.
  bool _autoAll = false;
  final _selectedChildIds = <String>{};

  bool get _isActivity => widget.mode == 'activity';

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

  Set<String> _effectiveSelected(List<ChildModel> present) {
    if (_autoAll) {
      return present
          .map((c) => c.key ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();
    }
    return _selectedChildIds;
  }

  void _onToggleChild(List<ChildModel> present, String id) {
    setState(() {
      if (_autoAll) {
        _selectedChildIds
          ..clear()
          ..addAll(_effectiveSelected(present));
        _autoAll = false;
      }
      if (!_selectedChildIds.remove(id)) _selectedChildIds.add(id);
    });
  }

  void _onSubjectSelected(SubjectModel? s) {
    setState(() => _selectedSubject = s);
    widget.ctrl.loadPendingHomeworkForSubject(s?.key);
  }

  void _onClassroomSelected(String? id) {
    if (id == null) return;
    final allowed = widget.ctrl.subjectsForClassroom(id);
    final stillValid = allowed.any((s) => s.key == _selectedSubject?.key);
    if (_isActivity) widget.ctrl.setActiveClassroom(id);
    setState(() {
      _selectedClassroomId = id;
      if (!stillValid) _selectedSubject = null;
      _autoAll = false;
      _selectedChildIds.clear();
    });
    if (!stillValid) widget.ctrl.loadPendingHomeworkForSubject(null);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    List<String>? childIds;
    if (_isActivity) {
      childIds = _effectiveSelected(widget.ctrl.presentChildren).toList();
      if (childIds.isEmpty) {
        Loader.showError('teacher_activity_pick_required'.tr);
        return;
      }
    }
    widget.onStart(
      _titleCtrl.text.trim(),
      _selectedSubject?.key,
      _selectedSubject?.name,
      _selectedClassroomId,
      childIds,
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
                    _header(context),
                    const SizedBox(height: 20),
                    if (widget.classrooms.length > 1) ...[
                      _label(context, 'teacher_activity_classroom_label'.tr),
                      const SizedBox(height: 8),
                      ClassroomPicker(
                        classrooms: widget.classrooms,
                        selected: _selectedClassroomId,
                        onSelect: _onClassroomSelected,
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_isActivity) ...[
                      Obx(() => ActivityChildrenPicker(
                            children: widget.ctrl.presentChildren,
                            selected: _effectiveSelected(
                                widget.ctrl.presentChildren),
                            onToggle: (id) => _onToggleChild(
                                widget.ctrl.presentChildren, id),
                            onSelectAll: () =>
                                setState(() => _autoAll = true),
                            onClearAll: () => setState(() {
                              _autoAll = false;
                              _selectedChildIds.clear();
                            }),
                          )),
                      const SizedBox(height: 16),
                    ],
                    _label(context, 'teacher_activity_subject_label'.tr),
                    const SizedBox(height: 8),
                    SubjectPicker(
                      subjects:
                          widget.ctrl.subjectsForClassroom(_selectedClassroomId),
                      selected: _selectedSubject,
                      onSelect: _onSubjectSelected,
                    ),
                    const SizedBox(height: 16),
                    _label(context, 'teacher_activity_title_label'.tr),
                    const SizedBox(height: 8),
                    _titleField(context),
                    const SizedBox(height: 20),
                    _startButton(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.activityGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.play_arrow_rounded,
              color: AppColors.activityGreen, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (_isActivity
                        ? 'teacher_activity_new_title'
                        : 'teacher_activity_class_title')
                    .tr,
                style: context.typography.smSemiBold
                    .copyWith(color: AppColors.textDisplay),
              ),
              const SizedBox(height: 2),
              Text(
                (_isActivity
                        ? 'teacher_action_start_activity_sub'
                        : 'teacher_action_start_class_sub')
                    .tr,
                style: context.typography.xsRegular
                    .copyWith(color: AppColors.textSecondaryParagraph),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _label(BuildContext context, String text) => Text(
        text,
        style: context.typography.smMedium
            .copyWith(color: AppColors.textPrimaryParagraph),
      );

  Widget _titleField(BuildContext context) => TextFormField(
        controller: _titleCtrl,
        textDirection: TextDirection.rtl,
        autofocus: !_isActivity,
        decoration: InputDecoration(
          hintText: 'teacher_activity_title_hint'.tr,
          hintTextDirection: TextDirection.rtl,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.activityGreen, width: 1.5),
          ),
        ),
        validator: (v) => v == null || v.trim().isEmpty
            ? 'teacher_activity_title_required'.tr
            : null,
      );

  Widget _startButton(BuildContext context) => SizedBox(
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
            (_isActivity
                    ? 'teacher_activity_start_btn'
                    : 'teacher_activity_start_class_btn')
                .tr,
            style: context.typography.mdBold,
          ),
        ),
      );
}
