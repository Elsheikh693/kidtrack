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

  String _kind = kStateKindStatus;
  bool _hasClassification = false;
  List<ChildStateOption> _options = const [];

  static const _accent = Color(0xFF0891B2);

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleCtrl.text = e?.title ?? '';
    _icon = e?.icon ?? ChildStateIcons.defaultKey;
    _kind = e?.kind ?? kStateKindStatus;
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
      kind: _kind,
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

  Widget _kindSelector(BuildContext context) {
    Widget opt({
      required String kind,
      required IconData icon,
      required String title,
      required String hint,
    }) {
      final selected = _kind == kind;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _kind = kind),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: selected
                  ? _accent.withValues(alpha: 0.08)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? _accent : const Color(0xFFE2E8F0),
                width: selected ? 1.4 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon,
                    size: 20,
                    color: selected ? _accent : const Color(0xFF94A3B8)),
                const SizedBox(height: 8),
                Text(title,
                    style: context.typography.smSemiBold.copyWith(
                        color: selected ? _accent : const Color(0xFF334155))),
                const SizedBox(height: 3),
                Text(hint,
                    style: context.typography.xsRegular
                        .copyWith(color: const Color(0xFF94A3B8), height: 1.4)),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('child_state_kind_label'.tr,
            style: context.typography.xsMedium
                .copyWith(color: const Color(0xFF374151))),
        const SizedBox(height: 8),
        Row(
          children: [
            opt(
              kind: kStateKindStatus,
              icon: Icons.timelapse_rounded,
              title: 'child_state_kind_status'.tr,
              hint: 'child_state_kind_status_hint'.tr,
            ),
            const SizedBox(width: 10),
            opt(
              kind: kStateKindEvent,
              icon: Icons.bolt_rounded,
              title: 'child_state_kind_event'.tr,
              hint: 'child_state_kind_event_hint'.tr,
            ),
          ],
        ),
      ],
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
              _kindSelector(context),
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
