import '../../../../../index/index_main.dart';

class AttendanceChildSheet extends StatefulWidget {
  final ChildAttendanceModel? initial;
  final RxMap<String, String> childNames;

  const AttendanceChildSheet({
    super.key,
    this.initial,
    required this.childNames,
  });

  @override
  State<AttendanceChildSheet> createState() => _AttendanceChildSheetState();
}

class _AttendanceChildSheetState extends State<AttendanceChildSheet> with KeyboardSheetMixin {
  late final ChildAttendanceParentService _service;
  String? _selectedChildId;
  String _status = 'present';
  String _date = '';
  final _noteCtrl = TextEditingController();
  bool _loading = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    _service = Get.find<ChildAttendanceParentService>();
    if (_isEdit) {
      final i = widget.initial!;
      _selectedChildId = i.childId;
      _status = i.status;
      _date = i.date;
      _noteCtrl.text = i.note ?? '';
    } else {
      final now = DateTime.now();
      _date =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_selectedChildId == null) {
      Loader.showError('checkin_error_child'.tr);
      return;
    }
    if (_date.isEmpty) {
      Loader.showError('checkin_error_date'.tr);
      return;
    }
    setState(() => _loading = true);
    Loader.show();
    final session = Get.find<SessionService>();
    final now = DateTime.now().millisecondsSinceEpoch;
    final model = ChildAttendanceModel(
      key: widget.initial?.key ?? const Uuid().v4(),
      nurseryId: session.nurseryId ?? '',
      childId: _selectedChildId!,
      branchId: session.branchId ?? '',
      date: _date,
      status: _status,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      createdAt: widget.initial?.createdAt ?? now,
      updatedAt: now,
    );

    void cb(ResponseStatus s) {
      Loader.dismiss();
      setState(() => _loading = false);
      if (s == ResponseStatus.success) {
        Loader.showSuccess(
          _isEdit ? 'checkin_success_updated'.tr : 'checkin_success_added'.tr,
        );
        Get.back();
      } else {
        Loader.showError('checkin_error_failed'.tr);
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
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              _isEdit ? 'checkin_edit_title'.tr : 'checkin_add_title'.tr,
              style: context.typography.mdBold.copyWith(
                fontSize: 18,
                color: const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'checkin_child_label'.tr,
              style: context.typography.smSemiBold.copyWith(
                fontSize: 14,
                color: const Color(0xFF475569),
              ),
            ),
            SizedBox(height: 8.h),
            Obx(
              () => DropdownButtonFormField<String>(
                value: _selectedChildId,
                hint: Text('checkin_child_hint'.tr),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
                items: widget.childNames.entries
                    .map(
                      (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedChildId = v),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'checkin_status_label'.tr,
              style: context.typography.smSemiBold.copyWith(
                fontSize: 14,
                color: const Color(0xFF475569),
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              children: ['present', 'absent', 'late', 'excused'].map((s) {
                final active = _status == s;
                return GestureDetector(
                  onTap: () => setState(() => _status = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: active
                            ? AppColors.primary
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Text(
                      'checkin_status_$s'.tr,
                      style: context.typography.xsMedium.copyWith(
                        fontSize: 13,
                        color: active ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16.h),
            Text(
              'checkin_note_label'.tr,
              style: context.typography.smSemiBold.copyWith(
                fontSize: 14,
                color: const Color(0xFF475569),
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _noteCtrl,
              decoration: InputDecoration(
                hintText: 'checkin_note_hint'.tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'checkin_save'.tr,
                  style: context.typography.smSemiBold.copyWith(
                    color: Colors.white,
                    fontSize: 16,
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
