import '../../../../../index/index_main.dart';

/// Add/edit a timetable slot. The manager picks subject + teacher + time and may
/// optionally pre-fill the lesson topic; if she leaves it blank the teacher
/// types it when she starts the session.
class ManagerSlotSheet extends StatefulWidget {
  const ManagerSlotSheet({
    super.key,
    required this.controller,
    this.existing,
  });

  final ManagerScheduleController controller;
  final ScheduleModel? existing;

  @override
  State<ManagerSlotSheet> createState() => _ManagerSlotSheetState();
}

class _ManagerSlotSheetState extends State<ManagerSlotSheet> {
  late String _day;
  String? _subjectId;
  String? _teacherId;
  late final TextEditingController _startCtrl;
  late final TextEditingController _endCtrl;
  late final TextEditingController _topicCtrl;

  ManagerScheduleController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    final ex = widget.existing;
    _day = ex?.day ?? c.selectedDay.value;
    _subjectId = ex?.subjectId;
    _teacherId = ex?.teacherId ?? c.selectedClassroom.value?.teacherId;
    _startCtrl = TextEditingController(text: ex?.startTime ?? '08:00');
    _endCtrl = TextEditingController(text: ex?.endTime ?? '09:00');
    _topicCtrl = TextEditingController(text: ex?.topic ?? '');
  }

  @override
  void dispose() {
    _startCtrl.dispose();
    _endCtrl.dispose();
    _topicCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime(TextEditingController ctrl) async {
    final parts = ctrl.text.split(':');
    final picked = await showAppTimePicker(
      context,
      initialTime: TimeOfDay(
        hour: int.tryParse(parts.first) ?? 8,
        minute: int.tryParse(parts.last) ?? 0,
      ),
    );
    if (picked != null) {
      ctrl.text =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {});
    }
  }

  Future<void> _save() async {
    final classroom = c.selectedClassroom.value;
    if (classroom == null) return;
    final base = widget.existing;
    final slot = ScheduleModel(
      key: base?.key,
      nurseryId: c.nurseryId,
      classroomId: classroom.key ?? '',
      day: _day,
      startTime: _startCtrl.text.trim(),
      endTime: _endCtrl.text.trim(),
      activityType: base?.activityType ?? 'lesson',
      subjectId: (_subjectId?.isEmpty ?? true) ? null : _subjectId,
      teacherId: (_teacherId?.isEmpty ?? true) ? null : _teacherId,
      topic: _topicCtrl.text.trim().isEmpty ? null : _topicCtrl.text.trim(),
      createdAt: base?.createdAt,
    );
    Get.back();
    await c.saveSlot(slot);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing?.key != null;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(
          20.w, 14.h, 20.w, MediaQuery.of(context).viewInsets.bottom + 24.h),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.borderNeutralPrimary,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(isEdit ? 'schedule_update'.tr : 'schedule_add'.tr,
                style: context.typography.lgBold
                    .copyWith(color: AppColors.textDefault)),
            SizedBox(height: 18.h),

            _label(context, 'schedule_day'.tr),
            _dropdown<String>(
              context,
              value: _day,
              items: ManagerScheduleController.days
                  .map((d) => DropdownMenuItem(
                      value: d, child: Text('schedule_day_$d'.tr)))
                  .toList(),
              onChanged: (v) => setState(() => _day = v ?? _day),
            ),
            SizedBox(height: 14.h),

            _label(context, 'schedule_subject'.tr),
            _dropdown<String?>(
              context,
              value: _subjectId,
              items: [
                DropdownMenuItem(value: null, child: Text('schedule_none'.tr)),
                ...c.subjects.map((s) =>
                    DropdownMenuItem(value: s.key, child: Text(s.name))),
              ],
              onChanged: (v) => setState(() => _subjectId = v),
            ),
            SizedBox(height: 14.h),

            _label(context, 'schedule_teacher'.tr),
            _dropdown<String?>(
              context,
              value: _teacherId,
              items: [
                DropdownMenuItem(value: null, child: Text('schedule_none'.tr)),
                ...c.teachers.map((t) =>
                    DropdownMenuItem(value: t.uid, child: Text(t.name))),
              ],
              onChanged: (v) => setState(() => _teacherId = v),
            ),
            SizedBox(height: 14.h),

            Row(
              children: [
                Expanded(
                    child: _timeField(context, 'schedule_start_time'.tr,
                        _startCtrl, () => _pickTime(_startCtrl))),
                SizedBox(width: 12.w),
                Expanded(
                    child: _timeField(context, 'schedule_end_time'.tr,
                        _endCtrl, () => _pickTime(_endCtrl))),
              ],
            ),
            SizedBox(height: 14.h),

            _label(context, 'schedule_topic_optional'.tr),
            AppTextField(
              controller: _topicCtrl,
              hintText: 'schedule_topic_hint'.tr,
            ),
            SizedBox(height: 24.h),

            SizedBox(
              width: double.infinity,
              child: PrimaryTextButton(
                label: AppText(
                  text: isEdit ? 'schedule_update'.tr : 'schedule_save'.tr,
                  textStyle: context.typography.smSemiBold
                      .copyWith(color: AppColors.white),
                ),
                onTap: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String text) => Padding(
        padding: EdgeInsets.only(bottom: 6.h),
        child: Text(text,
            style: context.typography.mdMedium
                .copyWith(color: AppColors.textSecondaryParagraph)),
      );

  Widget _dropdown<T>(
    BuildContext context, {
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) =>
      Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: AppColors.backgroundNeutralDefault,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.borderNeutralPrimary),
        ),
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          underline: const SizedBox(),
          style: context.typography.mdMedium
              .copyWith(color: AppColors.textDefault),
          dropdownColor: AppColors.white,
        ),
      );

  Widget _timeField(
    BuildContext context,
    String label,
    TextEditingController ctrl,
    VoidCallback onTap,
  ) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(context, label),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: AppColors.backgroundNeutralDefault,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.borderNeutralPrimary),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time_rounded,
                      size: 16.sp, color: AppColors.activityMuted),
                  SizedBox(width: 8.w),
                  Text(ctrl.text,
                      style: context.typography.mdMedium
                          .copyWith(color: AppColors.textDefault)),
                ],
              ),
            ),
          ),
        ],
      );
}
