import '../../../../../../index/index_main.dart';

/// Schedules a retake for one child: a date, WHICH items to redo (defaults to
/// all — pick a subset to retake only the weak ones), an optional teacher, and
/// a notify-parent toggle.
class RetakeScheduleSheet extends StatefulWidget {
  final List<AssessmentItem> items;
  final List<StaffModel> teachers;
  final void Function({
    required int date,
    required List<String> itemIds,
    String? teacherId,
    required bool notifyParent,
  }) onConfirm;

  const RetakeScheduleSheet({
    super.key,
    required this.items,
    required this.teachers,
    required this.onConfirm,
  });

  @override
  State<RetakeScheduleSheet> createState() => _RetakeScheduleSheetState();
}

class _RetakeScheduleSheetState extends State<RetakeScheduleSheet> {
  DateTime? _date;
  late final Set<String> _itemIds;
  String? _teacherId;
  bool _notify = true;

  static const _accent = Color(0xFF4F46E5);

  @override
  void initState() {
    super.initState();
    _itemIds = {for (final i in widget.items) i.id}; // default: all items
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showAppDatePicker(
      context,
      initialDate: _date ?? now.add(const Duration(days: 1)),
      minimumDate: now,
      maximumDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  bool get _valid => _date != null && _itemIds.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _grip(),
                const SizedBox(height: 14),
                Text('assessment_retake_title'.tr,
                    style: context.typography.mdBold
                        .copyWith(color: const Color(0xFF1E293B))),
                const SizedBox(height: 14),
                _dateTile(context),
                const SizedBox(height: 18),
                _sectionLabel(context, 'assessment_retake_items_label'.tr),
                const SizedBox(height: 8),
                _itemsSelector(context),
                if (widget.teachers.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  _sectionLabel(context, 'assessment_run_teacher_label'.tr),
                  const SizedBox(height: 8),
                  _teacherSelector(context),
                ],
                const SizedBox(height: 14),
                _notifyToggle(context),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _valid
                        ? () => widget.onConfirm(
                              date: _date!.millisecondsSinceEpoch,
                              itemIds: _itemIds.toList(),
                              teacherId: _teacherId,
                              notifyParent: _notify,
                            )
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFCBD5E1),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('assessment_retake_confirm'.tr,
                        style: context.typography.smSemiBold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _grip() => Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );

  Widget _sectionLabel(BuildContext context, String text) => Text(text,
      style: context.typography.xsMedium
          .copyWith(color: const Color(0xFF374151)));

  Widget _dateTile(BuildContext context) {
    final label = _date == null
        ? 'assessment_run_pick_date'.tr
        : '${_date!.year}/${_date!.month.toString().padLeft(2, '0')}/${_date!.day.toString().padLeft(2, '0')}';
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.event_rounded, size: 18, color: _accent),
            const SizedBox(width: 8),
            Text(label,
                style: context.typography.smMedium
                    .copyWith(color: const Color(0xFF334155))),
          ],
        ),
      ),
    );
  }

  Widget _itemsSelector(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in widget.items) _itemChip(context, item),
      ],
    );
  }

  Widget _itemChip(BuildContext context, AssessmentItem item) {
    final selected = _itemIds.contains(item.id);
    return GestureDetector(
      onTap: () => setState(() {
        if (selected) {
          _itemIds.remove(item.id);
        } else {
          _itemIds.add(item.id);
        }
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _accent : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? _accent : const Color(0xFFE2E8F0)),
        ),
        child: Text(item.title,
            style: context.typography.smMedium.copyWith(
                color: selected ? Colors.white : const Color(0xFF475569))),
      ),
    );
  }

  Widget _teacherSelector(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final t in widget.teachers)
          GestureDetector(
            onTap: () => setState(
                () => _teacherId = _teacherId == t.uid ? null : t.uid),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _teacherId == t.uid ? _accent : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: _teacherId == t.uid
                        ? _accent
                        : const Color(0xFFE2E8F0)),
              ),
              child: Text(t.name,
                  style: context.typography.smMedium.copyWith(
                      color: _teacherId == t.uid
                          ? Colors.white
                          : const Color(0xFF475569))),
            ),
          ),
      ],
    );
  }

  Widget _notifyToggle(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text('assessment_retake_notify'.tr,
              style: context.typography.smMedium
                  .copyWith(color: const Color(0xFF334155))),
        ),
        Switch(
          value: _notify,
          activeThumbColor: _accent,
          onChanged: (v) => setState(() => _notify = v),
        ),
      ],
    );
  }
}
