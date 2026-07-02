import '../../../../../index/index_main.dart';

class ScheduleEntrySheet extends StatefulWidget {
  const ScheduleEntrySheet({
    super.key,
    required this.controller,
    this.existing,
  });

  final TeacherWeeklyScheduleController controller;
  final ScheduleModel? existing;

  @override
  State<ScheduleEntrySheet> createState() => _ScheduleEntrySheetState();
}

class _ScheduleEntrySheetState extends State<ScheduleEntrySheet> {
  late String _selectedDay;
  late String _selectedActivityType;
  String? _selectedSubjectId;
  late TextEditingController _startCtrl;
  late TextEditingController _endCtrl;
  late TextEditingController _noteCtrl;
  bool _saving = false;

  static const _activityTypes = [
    'lesson',
    'break',
    'outdoor',
    'lunch',
    'nap',
    'other',
  ];

  TeacherWeeklyScheduleController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    final ex = widget.existing;
    _selectedDay = ex?.day ?? c.selectedDay.value;
    _selectedActivityType = ex?.activityType ?? 'lesson';
    _selectedSubjectId = ex?.subjectId;
    _startCtrl = TextEditingController(text: ex?.startTime ?? '08:00');
    _endCtrl = TextEditingController(text: ex?.endTime ?? '09:00');
    _noteCtrl = TextEditingController(text: ex?.note ?? '');
  }

  @override
  void dispose() {
    _startCtrl.dispose();
    _endCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime(TextEditingController ctrl) async {
    final parts = ctrl.text.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts.first) ?? 8,
      minute: int.tryParse(parts.last) ?? 0,
    );
    final picked = await showAppTimePicker(context, initialTime: initial);
    if (picked != null) {
      setState(() {
        ctrl.text =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final cId = c.selectedClassroom.value?.key ?? '';
    final nurseryId = c.nurseryId;

    final slot = ScheduleModel(
      key: widget.existing?.key,
      nurseryId: nurseryId,
      classroomId: cId,
      day: _selectedDay,
      startTime: _startCtrl.text.trim(),
      endTime: _endCtrl.text.trim(),
      activityType: _selectedActivityType,
      subjectId:
          _selectedSubjectId?.isEmpty ?? true ? null : _selectedSubjectId,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );

    if (widget.existing != null) {
      await c.updateSlot(slot);
    } else {
      await c.addSlot(slot);
    }

    if (mounted) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderNeutralPrimary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isEdit ? 'schedule_update'.tr : 'schedule_add'.tr,
              style: context.typography.mdRegular
                  .copyWith(color: AppColors.activitySlate),
            ),
            const SizedBox(height: 20),

            // Day dropdown
            _Label(text: 'schedule_day'.tr),
            const SizedBox(height: 6),
            _DropdownField(
              value: _selectedDay,
              items: TeacherWeeklyScheduleController.days
                  .map((d) => DropdownMenuItem(
                        value: d,
                        child: Text('schedule_day_$d'.tr),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedDay = v!),
            ),
            const SizedBox(height: 14),

            // Activity type
            _Label(text: 'schedule_activity_type'.tr),
            const SizedBox(height: 6),
            _DropdownField(
              value: _selectedActivityType,
              items: _activityTypes
                  .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text('schedule_activity_$t'.tr),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedActivityType = v!),
            ),
            const SizedBox(height: 14),

            // Subject (optional)
            _Label(text: 'schedule_subject_optional'.tr),
            const SizedBox(height: 6),
            _DropdownField<String?>(
              value: _selectedSubjectId,
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(
                    'schedule_none'.tr,
                    style: const TextStyle(color: AppColors.activityMuted),
                  ),
                ),
                ...c.allSubjects.map((s) => DropdownMenuItem(
                      value: s.key,
                      child: Text(s.name),
                    )),
              ],
              onChanged: (v) => setState(() => _selectedSubjectId = v),
            ),
            const SizedBox(height: 14),

            // Time row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Label(text: 'schedule_start_time'.tr),
                      const SizedBox(height: 6),
                      _TimeField(
                        controller: _startCtrl,
                        onTap: () => _pickTime(_startCtrl),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Label(text: 'schedule_end_time'.tr),
                      const SizedBox(height: 6),
                      _TimeField(
                        controller: _endCtrl,
                        onTap: () => _pickTime(_endCtrl),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Note
            _Label(text: 'schedule_note'.tr),
            const SizedBox(height: 6),
            TextField(
              controller: _noteCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'schedule_note'.tr,
                hintStyle:
                    TextStyle(color: AppColors.activityMuted, fontSize: 13),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.borderNeutralPrimary),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.borderNeutralPrimary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: AppColors.activityGreen, width: 1.5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.activityGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        isEdit ? 'schedule_update'.tr : 'schedule_save'.tr,
                        style: context.typography.mdBold,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.typography.mdRegular
          .copyWith(color: AppColors.activitySlate, letterSpacing: 0.2),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderNeutralPrimary),
      ),
      child: DropdownButton<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        isExpanded: true,
        underline: const SizedBox(),
        style: context.typography.mdMedium.copyWith( color: AppColors.activitySlate,),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({required this.controller, required this.onTap});
  final TextEditingController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderNeutralPrimary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderNeutralPrimary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.activityGreen, width: 1.5),
        ),
        prefixIcon:
            const Icon(Icons.access_time_rounded, size: 16, color: AppColors.activityMuted),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      ),
    );
  }
}
