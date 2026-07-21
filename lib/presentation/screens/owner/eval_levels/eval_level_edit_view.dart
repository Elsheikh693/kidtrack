import '../../../../index/index_main.dart';

/// Full-screen editor for an activity eval-level template (add / edit).
class EvalLevelEditView extends StatefulWidget {
  final EvalLevelTemplateModel? existing;
  const EvalLevelEditView({super.key, this.existing});

  @override
  State<EvalLevelEditView> createState() => _EvalLevelEditViewState();
}

class _EvalLevelEditViewState extends State<EvalLevelEditView> {
  final _titleCtrl = TextEditingController();
  String _icon = EvalLevelIcons.defaultKey;
  int _color = EvalLevelPalette.defaultColor;
  double _score = 5;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleCtrl.text = e?.title ?? '';
    _icon = e?.icon ?? EvalLevelIcons.defaultKey;
    _color = e?.color ?? EvalLevelPalette.defaultColor;
    _score = e?.score ?? 5;
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
        'eval_${DateTime.now().millisecondsSinceEpoch}';

    final model = EvalLevelTemplateModel(
      key: key,
      nurseryId: session.nurseryId ?? '',
      title: title,
      icon: _icon,
      color: _color,
      score: _score,
      isActive: widget.existing?.isActive ?? true,
      createdAt:
          widget.existing?.createdAt ?? DateTime.now().millisecondsSinceEpoch,
    );

    final service = Get.find<BaseService<EvalLevelTemplateModel>>(
      tag: 'evalLevelTemplates',
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
            isNew ? 'eval_level_saved'.tr : 'eval_level_updated'.tr,
          );
          Get.back();
        } else {
          Loader.showError('eval_level_error'.tr);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = Color(_color);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: HomeAppBar(
          title: widget.existing == null
              ? 'eval_level_sheet_add'.tr
              : 'eval_level_sheet_edit'.tr,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EvalLevelIconPicker(
                selected: _icon,
                accent: accent,
                onSelected: (k) => setState(() => _icon = k),
              ),
              const SizedBox(height: 20),
              _TitleField(controller: _titleCtrl, accent: accent),
              const SizedBox(height: 20),
              EvalLevelColorPicker(
                selected: _color,
                onSelected: (c) => setState(() => _color = c),
              ),
              const SizedBox(height: 20),
              EvalLevelScoreSelector(
                score: _score,
                accent: accent,
                onChanged: (v) => setState(() => _score = v),
              ),
              const SizedBox(height: 20),
              _PreviewTile(
                controller: _titleCtrl,
                icon: _icon,
                accent: accent,
                score: _score,
              ),
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
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  widget.existing == null
                      ? 'eval_level_save'.tr
                      : 'eval_level_update'.tr,
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

// ── Title field ──────────────────────────────────────────────────────────────

class _TitleField extends StatelessWidget {
  const _TitleField({required this.controller, required this.accent});

  final TextEditingController controller;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'eval_level_label_title'.tr,
          style: context.typography.xsMedium
              .copyWith(color: const Color(0xFF374151)),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          textInputAction: TextInputAction.done,
          style: context.typography.smSemiBold,
          decoration: InputDecoration(
            hintText: 'eval_level_hint_title'.tr,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accent, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Preview ──────────────────────────────────────────────────────────────────

class _PreviewTile extends StatelessWidget {
  const _PreviewTile({
    required this.controller,
    required this.icon,
    required this.accent,
    required this.score,
  });

  final TextEditingController controller;
  final String icon;
  final Color accent;
  final double score;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final title = controller.text.trim().isEmpty
            ? 'eval_level_preview'.tr
            : controller.text.trim();
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accent.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(EvalLevelIcons.iconFor(icon),
                    size: 28, color: accent),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: context.typography.smSemiBold.copyWith(color: accent),
              ),
            ],
          ),
        );
      },
    );
  }
}
