import '../../../../../index/index_main.dart';

class DocumentSheet extends StatefulWidget {
  final DocumentModel? initial;
  const DocumentSheet({super.key, this.initial});

  @override
  State<DocumentSheet> createState() => _DocumentSheetState();
}

class _DocumentSheetState extends State<DocumentSheet> with KeyboardSheetMixin {
  late final DocumentParentService _service;
  late final ChildParentService _childService;

  List<ChildModel> _children = [];
  String? _childId;
  String _type = 'other';
  final titleCtrl = TextEditingController();
  final fileUrlCtrl = TextEditingController();
  bool _loading = true;

  bool get isEdit => widget.initial != null;

  final _types = ['birth_certificate', 'id', 'vaccination', 'medical', 'other'];

  @override
  void initState() {
    super.initState();
    _service = Get.find<DocumentParentService>();
    _childService = Get.find<ChildParentService>();
    if (isEdit) {
      _childId = widget.initial!.childId;
      _type = widget.initial!.type;
      titleCtrl.text = widget.initial!.title ?? '';
      fileUrlCtrl.text = widget.initial!.fileUrl;
    }
    _childService.getAll(callBack: (list) {
      if (mounted) setState(() { _children = list.whereType<ChildModel>().toList(); _loading = false; });
    });
  }

  @override
  void dispose() { titleCtrl.dispose(); fileUrlCtrl.dispose(); super.dispose(); }

  String _typeLabel(String t) {
    switch (t) {
      case 'birth_certificate': return 'document_type_birth'.tr;
      case 'id': return 'document_type_id'.tr;
      case 'vaccination': return 'document_type_vaccination'.tr;
      case 'medical': return 'document_type_medical'.tr;
      default: return 'document_type_other'.tr;
    }
  }

  Future<void> _submit() async {
    if (_childId == null) { Loader.showError('document_error_child'.tr); return; }
    if (fileUrlCtrl.text.trim().isEmpty) { Loader.showError('document_error_url'.tr); return; }
    final nurseryId = SessionService().nurseryId ?? '';
    final id = isEdit ? (widget.initial!.key ?? const Uuid().v4()) : const Uuid().v4();
    final item = DocumentModel(
      key: id, nurseryId: nurseryId, childId: _childId!, type: _type,
      title: titleCtrl.text.trim().isEmpty ? null : titleCtrl.text.trim(),
      fileUrl: fileUrlCtrl.text.trim(),
    );
    Loader.show();
    if (isEdit) {
      await _service.update(item: item, callBack: (s) {
        Loader.dismiss();
        if (s == ResponseStatus.success) { Loader.showSuccess('document_success_updated'.tr); Get.back(); }
        else Loader.showError('document_error_failed'.tr);
      });
    } else {
      await _service.add(item: item, callBack: (s) {
        Loader.dismiss();
        if (s == ResponseStatus.success) { Loader.showSuccess('document_success_added'.tr); Get.back(); }
        else Loader.showError('document_error_failed'.tr);
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
              Text(isEdit ? 'document_edit_title'.tr : 'document_add_title'.tr, style: context.typography.mdBold.copyWith(fontSize: 18, color: const Color(0xFF1E293B))),
              SizedBox(height: 24.h),
              if (_loading) const Center(child: CircularProgressIndicator()) else ...[
                _Label('document_child_label'.tr),
                SizedBox(height: 6.h),
                DropdownButtonFormField<ChildModel>(
                  value: _children.where((c) => c.key == _childId).firstOrNull,
                  hint: Text('document_child_hint'.tr, style: context.typography.smRegular.copyWith(color: const Color(0xFFCBD5E1), fontSize: 14)),
                  onChanged: (c) => setState(() => _childId = c?.key),
                  items: _children.map((c) => DropdownMenuItem(value: c, child: Text('${c.firstName} ${c.lastName}'))).toList(),
                  decoration: _dec(),
                ),
                SizedBox(height: 16.h),
                _Label('document_type_label'.tr),
                SizedBox(height: 6.h),
                DropdownButtonFormField<String>(
                  value: _type,
                  onChanged: (v) => setState(() => _type = v ?? 'other'),
                  items: _types.map((t) => DropdownMenuItem(value: t, child: Text(_typeLabel(t)))).toList(),
                  decoration: _dec(),
                ),
                SizedBox(height: 16.h),
                _Label('document_title_label'.tr),
                SizedBox(height: 6.h),
                _Field(controller: titleCtrl, hint: 'document_title_hint'.tr),
                SizedBox(height: 16.h),
                _Label('document_url_label'.tr),
                SizedBox(height: 6.h),
                _Field(controller: fileUrlCtrl, hint: 'document_url_hint'.tr),
                SizedBox(height: 32.h),
                SizedBox(
                  width: double.infinity, height: 52.h,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0EA5E9), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)), elevation: 0),
                    child: Text('document_save'.tr, style: context.typography.smSemiBold.copyWith(fontSize: 16)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _dec() => InputDecoration(
    filled: true, fillColor: const Color(0xFFF8FAFC),
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
  );
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
  const _Field({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller, keyboardType: TextInputType.text, maxLines: 1,
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
