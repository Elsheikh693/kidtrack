import '../../../../../index/index_main.dart';

class ChildLeaveSheet extends StatefulWidget {
  final ChildLeaveRequestModel? initial;
  final RxMap<String, String> childNames;

  const ChildLeaveSheet({super.key, this.initial, required this.childNames});

  @override
  State<ChildLeaveSheet> createState() => _ChildLeaveSheetState();
}

class _ChildLeaveSheetState extends State<ChildLeaveSheet> with KeyboardSheetMixin {
  late final ChildLeaveRequestParentService _service;
  String? _childId;
  int? _startDate;
  int? _endDate;
  final _reasonCtrl = TextEditingController();
  bool _loading = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    _service = Get.find<ChildLeaveRequestParentService>();
    if (_isEdit) {
      final i = widget.initial!;
      _childId = i.childId;
      _startDate = i.startDate;
      _endDate = i.endDate;
      _reasonCtrl.text = i.reason;
    }
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  String _formatDate(int? ts) {
    if (ts == null) return 'child_leave_pick_date'.tr;
    final d = DateTime.fromMillisecondsSinceEpoch(ts);
    return '${d.day}/${d.month}/${d.year}';
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showAppDatePicker(
      context,
      initialDate: DateTime.now(),
      minimumDate: DateTime(2020),
      maximumDate: DateTime(2030),
    );
    if (picked == null) return;
    final ts = picked.millisecondsSinceEpoch;
    setState(() => isStart ? _startDate = ts : _endDate = ts);
  }

  Future<void> _save() async {
    if (_childId == null) {
      Loader.showError('child_leave_error_child'.tr);
      return;
    }
    if (_startDate == null) {
      Loader.showError('child_leave_error_start'.tr);
      return;
    }
    if (_endDate == null) {
      Loader.showError('child_leave_error_end'.tr);
      return;
    }
    if (_reasonCtrl.text.trim().isEmpty) {
      Loader.showError('child_leave_error_reason'.tr);
      return;
    }
    setState(() => _loading = true);
    Loader.show();
    final session = Get.find<SessionService>();
    final model = ChildLeaveRequestModel(
      key: widget.initial?.key ?? const Uuid().v4(),
      nurseryId: session.nurseryId ?? '',
      childId: _childId!,
      requestedBy: session.userId ?? '',
      startDate: _startDate!,
      endDate: _endDate!,
      reason: _reasonCtrl.text.trim(),
      status: widget.initial?.status ?? 'pending',
      createdAt: widget.initial?.createdAt,
    );

    void cb(ResponseStatus s) {
      Loader.dismiss();
      setState(() => _loading = false);
      if (s == ResponseStatus.success) {
        Loader.showSuccess(
          _isEdit
              ? 'child_leave_success_updated'.tr
              : 'child_leave_success_added'.tr,
        );
        Get.back();
      } else {
        Loader.showError('child_leave_error_failed'.tr);
      }
    }

    if (_isEdit) {
      await _service.update(item: model, callBack: cb);
    } else {
      await _service.add(item: model, callBack: cb);
    }
  }

  @override
  Widget build(BuildContext context) {
    return wrapWithKeyboard(
      context: context,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _isEdit
                  ? 'child_leave_edit_title'.tr
                  : 'child_leave_add_title'.tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'child_leave_child_label'.tr,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => DropdownButtonFormField<String>(
                value: _childId,
                hint: Text('child_leave_child_hint'.tr),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items: widget.childNames.entries
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _childId = v),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _DatePicker(
                    label: 'child_leave_start_date'.tr,
                    value: _formatDate(_startDate),
                    onTap: () => _pickDate(true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DatePicker(
                    label: 'child_leave_end_date'.tr,
                    value: _formatDate(_endDate),
                    onTap: () => _pickDate(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'child_leave_reason_label'.tr,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'child_leave_reason_hint'.tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'child_leave_save'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DatePicker extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _DatePicker({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF475569),
        ),
      ),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF94A3B8)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
