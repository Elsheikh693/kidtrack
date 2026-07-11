import '../../../../../index/index_main.dart';

class ChildStateSheet extends StatefulWidget {
  final ChildStateTemplateModel? existing;
  const ChildStateSheet({super.key, this.existing});

  @override
  State<ChildStateSheet> createState() => _ChildStateSheetState();
}

class _ChildStateSheetState extends State<ChildStateSheet> {
  final _titleCtrl = TextEditingController();
  String _icon = ChildStateIcons.defaultKey;

  bool _hasClassification = false;
  List<ChildStateOption> _options = const [];

  static const _accent = Color(0xFF0891B2);

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleCtrl.text = e?.title ?? '';
    _icon = e?.icon ?? ChildStateIcons.defaultKey;
    _options = e?.options ?? const [];
    _hasClassification = _options.isNotEmpty;
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
      options: _hasClassification ? _options : const [],
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
    // Content-sized sheet: the Column wraps its children (mainAxisSize.min) so
    // the sheet is only as tall as it needs to be. viewInsets padding lifts it
    // above the keyboard when the name field is focused.
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Handle ──────────────────────────────────────────────
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.existing == null
                          ? 'child_state_sheet_add'.tr
                          : 'child_state_sheet_edit'.tr,
                      style: context.typography.lgBold
                          .copyWith(color: const Color(0xFF1E293B)),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

            // ── Scrollable content ──────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      children: ChildStateIcons.presets.map((preset) {
                        final selected = _icon == preset.key;
                        return GestureDetector(
                          onTap: () => setState(() => _icon = preset.key),
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
                              child: Icon(
                                preset.icon,
                                size: 22,
                                color: selected
                                    ? _accent
                                    : const Color(0xFF64748B),
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
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
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
                      builder: (context, _) => Container(
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
                            Icon(
                              ChildStateIcons.iconFor(_icon),
                              size: 28,
                              color: _accent,
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
                    const SizedBox(height: 20),

                    // Classification toggle
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'child_state_needs_classification'.tr,
                                style: context.typography.smMedium.copyWith(
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'child_state_needs_classification_hint'.tr,
                                style: context.typography.xsRegular.copyWith(
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Switch.adaptive(
                          value: _hasClassification,
                          activeTrackColor: _accent,
                          onChanged: (v) =>
                              setState(() => _hasClassification = v),
                        ),
                      ],
                    ),

                    // Classification editor
                    if (_hasClassification) ...[
                      const SizedBox(height: 12),
                      Text(
                        'child_state_options_title'.tr,
                        style: context.typography.xsMedium
                            .copyWith(color: const Color(0xFF374151)),
                      ),
                      const SizedBox(height: 8),
                      StateClassificationEditor(
                        initial: _options,
                        onChanged: (opts) => _options = opts,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ── Pinned save button ──────────────────────────────────
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: SizedBox(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
