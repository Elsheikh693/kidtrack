import '../../../../../index/index_main.dart';

class ShiftSheet extends StatefulWidget {
  final ShiftModel? existing;
  final int nextSortOrder;

  const ShiftSheet({super.key, this.existing, this.nextSortOrder = 0});

  @override
  State<ShiftSheet> createState() => _ShiftSheetState();
}

class _ShiftSheetState extends State<ShiftSheet> {
  final _nameCtrl = TextEditingController();
  late TimeOfDay _start;
  late TimeOfDay _end;
  late int _grace;
  late bool _isActive;
  bool _saving = false;

  static const _graceOptions = [0, 5, 10, 15, 20, 30];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl.text = e?.name ?? '';
    _start = e != null
        ? _fromMinutes(e.startMinutes)
        : const TimeOfDay(hour: 8, minute: 0);
    _end = e != null
        ? _fromMinutes(e.endMinutes)
        : const TimeOfDay(hour: 12, minute: 0);
    _grace = e?.graceMinutes ?? 15;
    _isActive = e?.isActive ?? true;
  }

  TimeOfDay _fromMinutes(int m) => TimeOfDay(hour: m ~/ 60, minute: m % 60);

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _start : _end,
    );
    if (picked != null) {
      setState(() => isStart ? _start = picked : _end = picked);
    }
  }

  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      Loader.showError('shifts_error_name'.tr);
      return;
    }
    if (_toMinutes(_end) <= _toMinutes(_start)) {
      Loader.showError('shifts_error_time'.tr);
      return;
    }
    final session = SessionService();
    final isNew = widget.existing == null;
    final key =
        widget.existing?.key ?? 'shift_${DateTime.now().millisecondsSinceEpoch}';
    final model = ShiftModel(
      key: key,
      nurseryId: session.nurseryId ?? '',
      name: name,
      startMinutes: _toMinutes(_start),
      endMinutes: _toMinutes(_end),
      graceMinutes: _grace,
      isActive: _isActive,
      sortOrder: widget.existing?.sortOrder ?? widget.nextSortOrder,
      createdAt: widget.existing?.createdAt,
    );
    final service = Get.find<ShiftParentService>();
    setState(() => _saving = true);
    Loader.show();
    void cb(ResponseStatus status) {
      Loader.dismiss();
      if (status == ResponseStatus.success) {
        Loader.showSuccess(isNew ? 'shifts_saved'.tr : 'shifts_updated'.tr);
        Get.back();
      } else {
        setState(() => _saving = false);
        Loader.showError('shifts_error'.tr);
      }
    }

    isNew
        ? service.add(item: model, callBack: cb)
        : service.update(item: model, callBack: cb);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Text(
                widget.existing == null ? 'shifts_add'.tr : 'shifts_edit'.tr,
                style: context.typography.lgBold
                    .copyWith(color: const Color(0xFF1E293B)),
              ),
              SizedBox(height: 20.h),
              _label('shifts_name'.tr),
              SizedBox(height: 8.h),
              _nameField(context),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: _TimeField(
                      label: 'shifts_start'.tr,
                      value: ShiftModel.formatMinutes(_toMinutes(_start)),
                      onTap: () => _pickTime(true),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _TimeField(
                      label: 'shifts_end'.tr,
                      value: ShiftModel.formatMinutes(_toMinutes(_end)),
                      onTap: () => _pickTime(false),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              _label('shifts_grace'.tr),
              SizedBox(height: 10.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: _graceOptions.map((g) {
                  final selected = _grace == g;
                  return GestureDetector(
                    onTap: () => setState(() => _grace = g),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        'shifts_grace_option'.trParams({'m': '$g'}),
                        style: context.typography.xsMedium.copyWith(
                          color: selected ? Colors.white : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 12.h),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.primary,
                title: Text('shifts_active'.tr,
                    style: context.typography.smMedium
                        .copyWith(color: const Color(0xFF374151))),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: Text(
                    widget.existing == null
                        ? 'shifts_save'.tr
                        : 'shifts_update'.tr,
                    style: context.typography.smSemiBold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: context.typography.xsMedium
            .copyWith(color: const Color(0xFF374151)),
      );

  Widget _nameField(BuildContext context) => TextField(
        controller: _nameCtrl,
        decoration: InputDecoration(
          hintText: 'shifts_name_hint'.tr,
          hintStyle: context.typography.xsRegular
              .copyWith(fontSize: 13, color: const Color(0xFF94A3B8)),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: AppColors.primary),
          ),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        ),
      );
}

class _TimeField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _TimeField(
      {required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: context.typography.xsMedium
                .copyWith(color: const Color(0xFF374151))),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10.r),
              border: const Border.fromBorderSide(
                  BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value,
                    style: context.typography.smSemiBold
                        .copyWith(color: const Color(0xFF1E293B))),
                Icon(Icons.access_time_rounded,
                    size: 18.sp, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
