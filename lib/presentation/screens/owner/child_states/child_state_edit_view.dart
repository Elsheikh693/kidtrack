import '../../../../index/index_main.dart';

/// Full-screen editor for a child-state template (add / edit).
/// Replaces the former bottom sheet — reached via `Get.to` from the
/// [ChildStatesController].
class ChildStateEditView extends StatefulWidget {
  final ChildStateTemplateModel? existing;
  const ChildStateEditView({super.key, this.existing});

  @override
  State<ChildStateEditView> createState() => _ChildStateEditViewState();
}

class _ChildStateEditViewState extends State<ChildStateEditView> {
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: HomeAppBar(
          title: widget.existing == null
              ? 'child_state_sheet_add'.tr
              : 'child_state_sheet_edit'.tr,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ChildStateIconPicker(
                selected: _icon,
                accent: _accent,
                onSelected: (key) => setState(() => _icon = key),
              ),
              const SizedBox(height: 20),
              ChildStateTitleField(
                controller: _titleCtrl,
                accent: _accent,
                onSubmitted: _submit,
              ),
              const SizedBox(height: 20),
              ChildStatePreviewTile(
                controller: _titleCtrl,
                icon: _icon,
                accent: _accent,
              ),
              const SizedBox(height: 20),
              ChildStateClassificationToggle(
                value: _hasClassification,
                accent: _accent,
                onChanged: (v) => setState(() => _hasClassification = v),
              ),
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
        bottomNavigationBar: SafeArea(
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
      ),
    );
  }
}
