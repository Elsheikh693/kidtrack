import '../../../../../index/index_main.dart';
import 'widgets/run_classroom_selector.dart';
import 'widgets/run_teacher_selector.dart';

/// Create-a-run form for a chosen template: pick classes, an optional teacher,
/// and the date window. Saving stores a DRAFT (published later from the hub).
class AssessmentRunCreateView extends StatefulWidget {
  final AssessmentTemplateModel template;
  const AssessmentRunCreateView({super.key, required this.template});

  @override
  State<AssessmentRunCreateView> createState() =>
      _AssessmentRunCreateViewState();
}

class _AssessmentRunCreateViewState extends State<AssessmentRunCreateView> {
  late final AssessmentRunsController controller;

  final _selectedClassrooms = <String>[].obs;
  final Rxn<String> _teacherId = Rxn<String>();
  final Rx<DateTime> _start = DateTime.now().obs;
  final Rxn<DateTime> _end = Rxn<DateTime>();

  static const _accent = Color(0xFF4F46E5);

  @override
  void initState() {
    super.initState();
    controller = Get.find<AssessmentRunsController>();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final base = isStart ? _start.value : (_end.value ?? _start.value);
    final picked = await showAppDatePicker(
      context,
      initialDate: base,
      minimumDate: DateTime.now().subtract(const Duration(days: 1)),
      maximumDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    if (isStart) {
      _start.value = picked;
    } else {
      _end.value = picked;
    }
  }

  void _submit() {
    if (_selectedClassrooms.isEmpty) {
      Loader.showError('assessment_run_need_classrooms'.tr);
      return;
    }
    final t = widget.template;
    final run = AssessmentRunModel(
      key: 'run_${DateTime.now().millisecondsSinceEpoch}',
      nurseryId: controller.nurseryId,
      templateId: t.key ?? '',
      title: t.title,
      subject: t.subject,
      instructions: t.instructions,
      type: t.type,
      scale: t.scale,
      items: t.items,
      branchId: controller.branchId,
      classroomIds: _selectedClassrooms.toList(),
      teacherId: _teacherId.value,
      startDate: _start.value.millisecondsSinceEpoch,
      endDate: _end.value?.millisecondsSinceEpoch,
      status: kRunStatusDraft,
      createdBy: controller.currentUid,
    );
    controller.createDraft(run);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: HomeAppBar(
          title: 'assessment_run_create_title'.tr,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _templateBanner(context),
              const SizedBox(height: 22),
              _label(context, 'assessment_run_classrooms_label'.tr),
              const SizedBox(height: 10),
              Obx(() => RunClassroomSelector(
                    classrooms: controller.classrooms.toList(),
                    selectedIds: _selectedClassrooms.toList(),
                    onToggle: (id) {
                      if (_selectedClassrooms.contains(id)) {
                        _selectedClassrooms.remove(id);
                      } else {
                        _selectedClassrooms.add(id);
                      }
                    },
                  )),
              const SizedBox(height: 22),
              _label(context, 'assessment_run_teacher_label'.tr),
              const SizedBox(height: 10),
              Obx(() => RunTeacherSelector(
                    teachers: controller.teachers.toList(),
                    selectedId: _teacherId.value,
                    onSelected: (id) => _teacherId.value = id,
                  )),
              const SizedBox(height: 22),
              _label(context, 'assessment_run_dates_label'.tr),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Obx(() => _dateTile(
                          context,
                          'assessment_run_start'.tr,
                          _start.value,
                          () => _pickDate(isStart: true),
                        )),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => _dateTile(
                          context,
                          'assessment_run_end'.tr,
                          _end.value,
                          () => _pickDate(isStart: false),
                        )),
                  ),
                ],
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
                child: Text('assessment_run_save_draft'.tr,
                    style: context.typography.smSemiBold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _templateBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.assignment_rounded, color: _accent, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.template.title,
                    style: context.typography.smSemiBold
                        .copyWith(color: const Color(0xFF1E293B))),
                const SizedBox(height: 2),
                Text(
                  '${widget.template.items.length} ${'assessment_items_unit'.tr}',
                  style: context.typography.xsRegular
                      .copyWith(color: const Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(BuildContext context, String text) => Text(text,
      style: context.typography.mdBold.copyWith(color: const Color(0xFF1E293B)));

  Widget _dateTile(
      BuildContext context, String label, DateTime? value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: context.typography.xsRegular
                    .copyWith(color: const Color(0xFF94A3B8))),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    size: 14, color: _accent),
                const SizedBox(width: 6),
                Text(
                  value == null
                      ? 'assessment_run_pick_date'.tr
                      : _fmtDate(value),
                  style: context.typography.smMedium
                      .copyWith(color: const Color(0xFF334155)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _fmtDate(DateTime d) =>
      '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
}
