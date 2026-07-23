import '../../../../../index/index_main.dart';

class EnrollmentSheet extends StatefulWidget {
  final EnrollmentModel? initial;
  const EnrollmentSheet({super.key, this.initial});

  @override
  State<EnrollmentSheet> createState() => _EnrollmentSheetState();
}

class _EnrollmentSheetState extends State<EnrollmentSheet>
    with KeyboardSheetMixin {
  late final EnrollmentParentService _service;
  late final ChildParentService _childService;
  late final BranchParentService _branchService;

  List<ChildModel> _children = [];
  List<BranchModel> _branches = [];

  String? _childId;
  String? _branchId;
  String _status = 'enrolled';
  DateTime? _startDate;
  bool _loading = true;

  bool get isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    _service = Get.find<EnrollmentParentService>();
    _childService = Get.find<ChildParentService>();
    _branchService = Get.find<BranchParentService>();
    if (isEdit) {
      _childId = widget.initial!.childId;
      _branchId = widget.initial!.branchId;
      _status = widget.initial!.status;
      if (widget.initial!.startDate != null) {
        _startDate = DateTime.fromMillisecondsSinceEpoch(widget.initial!.startDate!);
      }
    }
    _loadLookups();
  }

  Future<void> _loadLookups() async {
    await Future.wait([
      _childService.getAll(callBack: (list) => _children = list.whereType<ChildModel>().toList()),
      _branchService.getAll(callBack: (list) => _branches = list.whereType<BranchModel>().toList()),
    ]);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _submit() async {
    if (_childId == null) { Loader.showError('enrollment_error_child'.tr); return; }
    if (_branchId == null) { Loader.showError('enrollment_error_branch'.tr); return; }
    final nurseryId = SessionService().nurseryId ?? '';
    final id = isEdit ? (widget.initial!.key ?? const Uuid().v4()) : const Uuid().v4();
    final item = EnrollmentModel(
      key: id,
      nurseryId: nurseryId,
      childId: _childId!,
      branchId: _branchId!,
      startDate: _startDate?.millisecondsSinceEpoch,
      status: _status,
    );
    Loader.show();
    if (isEdit) {
      await _service.update(item: item, callBack: (s) {
        Loader.dismiss();
        if (s == ResponseStatus.success) { Loader.showSuccess('enrollment_success_updated'.tr); Get.back(); }
        else Loader.showError('enrollment_error_failed'.tr);
      });
    } else {
      await _service.add(item: item, callBack: (s) {
        Loader.dismiss();
        if (s == ResponseStatus.success) { Loader.showSuccess('enrollment_success_added'.tr); Get.back(); }
        else Loader.showError('enrollment_error_failed'.tr);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: wrapWithKeyboard(
        context: context,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Handle(),
              SizedBox(height: 20.h),
              Text(
                isEdit ? 'enrollment_edit_title'.tr : 'enrollment_add_title'.tr,
                style: context.typography.mdBold.copyWith(fontSize: 18, color: const Color(0xFF1E293B)),
              ),
              SizedBox(height: 24.h),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else ...[
                _Label('enrollment_child_label'.tr),
                SizedBox(height: 6.h),
                _DropdownField<ChildModel>(
                  hint: 'enrollment_child_hint'.tr,
                  value: _children.where((c) => c.key == _childId).firstOrNull,
                  items: _children,
                  label: (c) => '${c.firstName} ${c.lastName}',
                  onChanged: (c) => setState(() => _childId = c?.key),
                ),
                SizedBox(height: 16.h),
                _Label('enrollment_branch_label'.tr),
                SizedBox(height: 6.h),
                _DropdownField<BranchModel>(
                  hint: 'enrollment_branch_hint'.tr,
                  value: _branches.where((b) => b.key == _branchId).firstOrNull,
                  items: _branches,
                  label: (b) => b.name,
                  onChanged: (b) => setState(() => _branchId = b?.key),
                ),
                SizedBox(height: 16.h),
                _Label('enrollment_status_label'.tr),
                SizedBox(height: 6.h),
                _StatusSelector(
                  selected: _status,
                  onChanged: (v) => setState(() => _status = v),
                ),
                SizedBox(height: 16.h),
                _Label('enrollment_start_date_label'.tr),
                SizedBox(height: 6.h),
                InkWell(
                  onTap: () async {
                    final d = await showAppDatePicker(
                      context,
                      initialDate: _startDate ?? DateTime.now(),
                      minimumDate: DateTime(2020),
                      maximumDate: DateTime(2030),
                    );
                    if (d != null) setState(() => _startDate = d);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 18.sp, color: const Color(0xFF94A3B8)),
                        SizedBox(width: 8.w),
                        Text(
                          _startDate != null
                              ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                              : 'enrollment_start_date_hint'.tr,
                          style: context.typography.smRegular.copyWith(fontSize: 15, color: _startDate != null ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1)),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
                SizedBox(
                  width: double.infinity, height: 52.h,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      elevation: 0,
                    ),
                    child: Text('enrollment_save'.tr, style: context.typography.smSemiBold.copyWith(fontSize: 16)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusSelector extends StatelessWidget {
  final String selected;
  final void Function(String) onChanged;
  const _StatusSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final statuses = ['enrolled', 'pending', 'withdrawn', 'graduated'];
    return Wrap(
      spacing: 8.w,
      children: statuses.map((s) {
        final isSelected = s == selected;
        return GestureDetector(
          onTap: () => onChanged(s),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0)),
            ),
            child: Text(
              'enrollment_status_$s'.tr,
              style: context.typography.xsMedium.copyWith(fontSize: 13, color: isSelected ? Colors.white : const Color(0xFF475569)),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<T> items;
  final String Function(T) label;
  final void Function(T?) onChanged;
  const _DropdownField({required this.hint, required this.value, required this.items, required this.label, required this.onChanged});

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<T>(
    value: value,
    hint: Text(hint, style: context.typography.smRegular.copyWith(color: const Color(0xFFCBD5E1), fontSize: 14)),
    onChanged: onChanged,
    items: items.map((i) => DropdownMenuItem(value: i, child: Text(label(i), style: context.typography.smRegular.copyWith(fontSize: 15)))).toList(),
    decoration: InputDecoration(
      filled: true, fillColor: const Color(0xFFF8FAFC),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
    ),
  );
}

class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4.r))),
  );
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: context.typography.smMedium.copyWith(fontSize: 14, color: const Color(0xFF475569)));
}
