import '../../../../../index/index_main.dart';
import 'widgets/assessment_scale_editor.dart';
import 'widgets/assessment_items_editor.dart';

/// Full-screen editor for an assessment template (add / edit): title, subject,
/// instructions, the single grading scale, and the list of items.
class AssessmentTemplateEditView extends StatefulWidget {
  final AssessmentTemplateModel? existing;
  const AssessmentTemplateEditView({super.key, this.existing});

  @override
  State<AssessmentTemplateEditView> createState() =>
      _AssessmentTemplateEditViewState();
}

class _AssessmentTemplateEditViewState
    extends State<AssessmentTemplateEditView> {
  late final AssessmentTemplatesController controller;

  final _titleCtrl = TextEditingController();
  final _instructionsCtrl = TextEditingController();

  String? _subject;
  AssessmentScale _scale = const AssessmentScale();
  List<AssessmentItem> _items = const [];

  static const _accent = Color(0xFF4F46E5);

  @override
  void initState() {
    super.initState();
    controller = Get.find<AssessmentTemplatesController>();
    final e = widget.existing;
    _titleCtrl.text = e?.title ?? '';
    _subject = e?.subject;
    _instructionsCtrl.text = e?.instructions ?? '';
    _scale = e?.scale ?? const AssessmentScale();
    _items = e?.items ?? const [];
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _instructionsCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      Loader.showError('assessment_template_need_title'.tr);
      return;
    }
    if (_items.isEmpty) {
      Loader.showError('assessment_template_need_items'.tr);
      return;
    }
    final validScale = _scale.isNumeric
        ? (_scale.numericMax ?? 0) > 0
        : _scale.levels.length >= 2;
    if (!validScale) {
      Loader.showError('assessment_template_need_scale'.tr);
      return;
    }

    final isNew = widget.existing == null;
    final key = widget.existing?.key ??
        'tpl_${DateTime.now().millisecondsSinceEpoch}';
    final instructions = _instructionsCtrl.text.trim();

    final model = AssessmentTemplateModel(
      key: key,
      nurseryId: controller.nurseryId,
      title: title,
      subject: (_subject == null || _subject!.isEmpty) ? null : _subject,
      instructions: instructions.isEmpty ? null : instructions,
      type: widget.existing?.type,
      scale: _scale,
      items: _items,
      isActive: widget.existing?.isActive ?? true,
      createdBy: widget.existing?.createdBy ?? controller.currentUid,
      createdAt: widget.existing?.createdAt,
    );

    controller.save(model, isNew: isNew);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: HomeAppBar(
          title: widget.existing == null
              ? 'assessment_template_add'.tr
              : 'assessment_template_edit'.tr,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _field(context, 'assessment_template_title_label'.tr,
                  _titleCtrl, 'assessment_template_title_hint'.tr),
              const SizedBox(height: 16),
              _subjectDropdown(context),
              const SizedBox(height: 16),
              _field(context, 'assessment_template_instructions_label'.tr,
                  _instructionsCtrl, 'assessment_template_instructions_hint'.tr,
                  maxLines: 3),
              const SizedBox(height: 22),
              _sectionTitle(context, 'assessment_scale_section'.tr),
              const SizedBox(height: 10),
              AssessmentScaleEditor(
                initial: _scale,
                onChanged: (s) => _scale = s,
              ),
              const SizedBox(height: 22),
              _sectionTitle(context, 'assessment_items_section'.tr),
              const SizedBox(height: 10),
              AssessmentItemsEditor(
                initial: _items,
                onChanged: (list) => _items = list,
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  widget.existing == null
                      ? 'assessment_template_save'.tr
                      : 'assessment_template_update'.tr,
                  style: context.typography.smSemiBold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) => Text(
        text,
        style: context.typography.mdBold.copyWith(color: const Color(0xFF1E293B)),
      );

  Widget _field(BuildContext context, String label,
      TextEditingController ctrl, String hint,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: context.typography.xsMedium
                .copyWith(color: const Color(0xFF374151))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: ctrl,
            maxLines: maxLines,
            style: context.typography.smRegular,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: hint,
              hintStyle: context.typography.smRegular
                  .copyWith(color: const Color(0xFFCBD5E1)),
            ),
          ),
        ),
      ],
    );
  }

  /// Subject picker sourced from the nursery's existing subjects.
  Widget _subjectDropdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('assessment_template_subject_label'.tr,
            style: context.typography.xsMedium
                .copyWith(color: const Color(0xFF374151))),
        const SizedBox(height: 8),
        Obx(() {
          final names = controller.subjectNames;
          if (names.isEmpty) {
            return Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text('assessment_template_no_subjects'.tr,
                  style: context.typography.smRegular
                      .copyWith(color: const Color(0xFFCBD5E1))),
            );
          }
          final value = names.contains(_subject) ? _subject : null;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: value,
                borderRadius: BorderRadius.circular(12),
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF94A3B8)),
                hint: Text('assessment_template_subject_hint'.tr,
                    style: context.typography.smRegular
                        .copyWith(color: const Color(0xFFCBD5E1))),
                style: context.typography.smRegular
                    .copyWith(color: const Color(0xFF1E293B)),
                items: [
                  for (final n in names)
                    DropdownMenuItem(value: n, child: Text(n)),
                ],
                onChanged: (v) => setState(() => _subject = v),
              ),
            ),
          );
        }),
      ],
    );
  }
}
