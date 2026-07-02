import '../../../../../index/index_main.dart';

class ChildStateSheet extends StatefulWidget {
  final ChildStateTemplateModel? existing;
  const ChildStateSheet({super.key, this.existing});

  @override
  State<ChildStateSheet> createState() => _ChildStateSheetState();
}

class _ChildStateSheetState extends State<ChildStateSheet>
    with KeyboardSheetMixin {
  final _titleCtrl = TextEditingController();
  String _icon = '😴';

  static const _presets = [
    '😴', '🍽️', '🚼', '🍼', '💊', '🚿', '📚', '🎨',
    '🏃', '🧸', '🌙', '🍎', '🥤', '🎵', '🏊', '🪥',
  ];

  static const _accent = Color(0xFF0891B2);

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleCtrl.text = e?.title ?? '';
    _icon = e?.icon ?? '😴';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;

    final session = SessionService();
    final isNew = widget.existing == null;
    final key = widget.existing?.key ??
        'state_${DateTime.now().millisecondsSinceEpoch}';

    final model = ChildStateTemplateModel(
      key: key,
      nurseryId: session.nurseryId ?? '',
      title: title,
      icon: _icon,
      isActive: widget.existing?.isActive ?? true,
      createdAt: widget.existing?.createdAt ??
          DateTime.now().millisecondsSinceEpoch,
    );

    final service = Get.find<BaseService<ChildStateTemplateModel>>(
      tag: 'childStateTemplates',
    );

    Loader.show();
    service.addData(
      item: model,
      toJson: (m) => m.toJson(),
      id: key,
      voidCallBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess(
            isNew ? 'child_state_saved'.tr : 'child_state_updated'.tr,
          );
          Get.back();
        } else {
          Loader.showError('child_state_error'.tr);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: wrapWithKeyboard(
        context: context,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                widget.existing == null
                    ? 'child_state_sheet_add'.tr
                    : 'child_state_sheet_edit'.tr,
                style: context.typography.lgBold
                    .copyWith(color: const Color(0xFF1E293B)),
              ),
              const SizedBox(height: 20),

              // Icon picker
              Text(
                'child_state_label_icon'.tr,
                style: context.typography.xsMedium
                    .copyWith(color: const Color(0xFF374151)),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _presets.map((e) {
                  final selected = _icon == e;
                  return GestureDetector(
                    onTap: () => setState(() => _icon = e),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: selected
                            ? _accent.withValues(alpha: 0.12)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected
                              ? _accent
                              : const Color(0xFFE2E8F0),
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          e,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Title field
              Text(
                'child_state_label_title'.tr,
                style: context.typography.xsMedium
                    .copyWith(color: const Color(0xFF374151)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  hintText: 'child_state_label_title_hint'.tr,
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _accent),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Preview
              ListenableBuilder(
                listenable: _titleCtrl,
                builder: (_, __) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _accent.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _icon,
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _titleCtrl.text.isEmpty
                            ? 'child_state_label_title_hint'.tr
                            : _titleCtrl.text,
                        style: context.typography.mdBold.copyWith(
                          color: _titleCtrl.text.isEmpty
                              ? const Color(0xFFCBD5E1)
                              : const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
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
                  child: Text(
                    widget.existing == null
                        ? 'child_state_save'.tr
                        : 'child_state_update'.tr,
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
}
