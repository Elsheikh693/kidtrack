import '../../../../../index/index_main.dart';

class WaitingSheet extends StatefulWidget {
  final WaitingListModel? initial;
  const WaitingSheet({super.key, this.initial});

  @override
  State<WaitingSheet> createState() => _WaitingSheetState();
}

class _WaitingSheetState extends State<WaitingSheet> with KeyboardSheetMixin {
  late final WaitingListParentService _service;

  final childNameCtrl = TextEditingController();
  final parentNameCtrl = TextEditingController();
  final parentPhoneCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  String _status = 'pending';

  bool get isEdit => widget.initial != null;
  final _statuses = ['pending', 'contacted', 'enrolled', 'cancelled'];

  @override
  void initState() {
    super.initState();
    _service = Get.find<WaitingListParentService>();
    if (isEdit) {
      childNameCtrl.text = widget.initial!.childName;
      parentNameCtrl.text = widget.initial!.parentName;
      parentPhoneCtrl.text = widget.initial!.parentPhone;
      notesCtrl.text = widget.initial!.notes ?? '';
      _status = widget.initial!.status;
    }
  }

  @override
  void dispose() { childNameCtrl.dispose(); parentNameCtrl.dispose(); parentPhoneCtrl.dispose(); notesCtrl.dispose(); super.dispose(); }

  String _statusLabel(String s) {
    switch (s) {
      case 'pending': return 'waiting_status_pending'.tr;
      case 'contacted': return 'waiting_status_contacted'.tr;
      case 'enrolled': return 'waiting_status_enrolled'.tr;
      default: return 'waiting_status_cancelled'.tr;
    }
  }

  Future<void> _submit() async {
    final childName = childNameCtrl.text.trim();
    final parentName = parentNameCtrl.text.trim();
    final parentPhone = parentPhoneCtrl.text.trim();
    if (childName.isEmpty) { Loader.showError('waiting_error_child_name'.tr); return; }
    if (parentName.isEmpty) { Loader.showError('waiting_error_parent_name'.tr); return; }
    if (parentPhone.isEmpty) { Loader.showError('waiting_error_parent_phone'.tr); return; }
    final nurseryId = SessionService().nurseryId ?? '';
    final id = isEdit ? (widget.initial!.key ?? const Uuid().v4()) : const Uuid().v4();
    final item = WaitingListModel(
      key: id, nurseryId: nurseryId, childName: childName,
      parentName: parentName, parentPhone: parentPhone,
      notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
      status: _status,
    );
    Loader.show();
    if (isEdit) {
      await _service.update(item: item, callBack: (s) {
        Loader.dismiss();
        if (s == ResponseStatus.success) { Loader.showSuccess('waiting_success_updated'.tr); Get.back(); }
        else Loader.showError('waiting_error_failed'.tr);
      });
    } else {
      await _service.add(item: item, callBack: (s) {
        Loader.dismiss();
        if (s == ResponseStatus.success) { Loader.showSuccess('waiting_success_added'.tr); Get.back(); }
        else Loader.showError('waiting_error_failed'.tr);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
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
              Text(isEdit ? 'waiting_edit_title'.tr : 'waiting_add_title'.tr, style: context.typography.mdBold.copyWith(fontSize: 18, color: const Color(0xFF1E293B))),
              SizedBox(height: 24.h),
              _Label('waiting_child_name_label'.tr),
              SizedBox(height: 6.h),
              _Field(controller: childNameCtrl, hint: 'waiting_child_name_hint'.tr),
              SizedBox(height: 16.h),
              _Label('waiting_parent_name_label'.tr),
              SizedBox(height: 6.h),
              _Field(controller: parentNameCtrl, hint: 'waiting_parent_name_hint'.tr),
              SizedBox(height: 16.h),
              _Label('waiting_parent_phone_label'.tr),
              SizedBox(height: 6.h),
              _Field(controller: parentPhoneCtrl, hint: 'waiting_parent_phone_hint'.tr, keyboardType: TextInputType.phone),
              SizedBox(height: 16.h),
              _Label('waiting_status_label'.tr),
              SizedBox(height: 6.h),
              StatefulBuilder(builder: (ctx, setS) => Wrap(
                spacing: 8.w,
                children: _statuses.map((s) {
                  final isSelected = s == _status;
                  return GestureDetector(
                    onTap: () { setS(() => _status = s); setState(() => _status = s); },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFFE2E8F0)),
                      ),
                      child: Text(_statusLabel(s), style: ctx.typography.xsMedium.copyWith(fontSize: 13, color: isSelected ? Colors.white : const Color(0xFF475569))),
                    ),
                  );
                }).toList(),
              )),
              SizedBox(height: 16.h),
              _Label('waiting_notes_label'.tr),
              SizedBox(height: 6.h),
              _Field(controller: notesCtrl, hint: 'waiting_notes_hint'.tr, maxLines: 3),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity, height: 52.h,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)), elevation: 0),
                  child: Text('waiting_save'.tr, style: context.typography.smSemiBold.copyWith(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4.r))));
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: context.typography.smMedium.copyWith(fontSize: 14, color: const Color(0xFF475569)));
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final int maxLines;
  const _Field({required this.controller, required this.hint, this.keyboardType = TextInputType.text, this.maxLines = 1});

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller, keyboardType: keyboardType, maxLines: maxLines,
    style: context.typography.smRegular.copyWith(fontSize: 15, color: const Color(0xFF1E293B)),
    decoration: InputDecoration(
      hintText: hint, hintStyle: context.typography.smRegular.copyWith(color: const Color(0xFFCBD5E1), fontSize: 14),
      filled: true, fillColor: const Color(0xFFF8FAFC),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
    ),
  );
}
