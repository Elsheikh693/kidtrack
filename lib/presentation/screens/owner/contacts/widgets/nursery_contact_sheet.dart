import '../../../../../index/index_main.dart';

class NurseryContactSheet extends StatefulWidget {
  final NurseryContactModel? existing;
  final int nextOrder;
  const NurseryContactSheet({super.key, this.existing, this.nextOrder = 0});

  @override
  State<NurseryContactSheet> createState() => _NurseryContactSheetState();
}

class _NurseryContactSheetState extends State<NurseryContactSheet>
    with KeyboardSheetMixin {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  late final FocusNode _nameFocus;
  late final FocusNode _phoneFocus;
  late String _roleKey;

  @override
  void initState() {
    super.initState();
    _nameFocus = kbNode();
    _phoneFocus = kbNode();
    final e = widget.existing;
    _nameCtrl.text = e?.name ?? '';
    _phoneCtrl.text = e?.phone ?? '';
    _roleKey = e?.roleKey ?? 'reception';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    if (name.isEmpty || phone.isEmpty) return;

    final session = SessionService();
    final isNew = widget.existing == null;
    final key =
        widget.existing?.key ??
        'contact_${DateTime.now().millisecondsSinceEpoch}';

    final model = NurseryContactModel(
      key: key,
      nurseryId: session.nurseryId ?? '',
      name: name,
      phone: phone,
      roleKey: _roleKey,
      order: widget.existing?.order ?? widget.nextOrder,
      createdAt:
          widget.existing?.createdAt ?? DateTime.now().millisecondsSinceEpoch,
    );

    final service = Get.find<BaseService<NurseryContactModel>>(
      tag: 'nurseryContacts',
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
            isNew ? 'nursery_contact_saved'.tr : 'nursery_contact_updated'.tr,
          );
          Get.back();
        } else {
          Loader.showError('nursery_contact_error'.tr);
        }
      },
    );
  }

  InputDecoration _decoration(String hintKey) => InputDecoration(
    hintText: hintKey.tr,
    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColors.primary),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );

  @override
  Widget build(BuildContext context) {
    final accent = Color(NurseryContactModel.roleColor(_roleKey));
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            // ── Grabber ──────────────────────────────────────────────────
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // ── Title ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  widget.existing == null
                      ? 'nursery_contact_add'.tr
                      : 'nursery_contact_edit'.tr,
                  style: context.typography.lgBold.copyWith(
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFE2E8F0),
            ),
            // ── Scrollable form ──────────────────────────────────────────
            Expanded(
              child: wrapWithKeyboard(
                context: context,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              // ── Role ────────────────────────────────────────────────────
              Text(
                'nursery_contact_role'.tr,
                style: context.typography.xsMedium.copyWith(
                  color: const Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: NurseryContactModel.roleKeys.map((r) {
                  final selected = _roleKey == r;
                  final c = Color(NurseryContactModel.roleColor(r));
                  return GestureDetector(
                    onTap: () => setState(() => _roleKey = r),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? c.withOpacity(0.12)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected ? c : Colors.transparent,
                          width: 1.4,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            NurseryContactModel.roleIcon(r),
                            size: 16,
                            color: selected ? c : const Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            NurseryContactModel.roleLabelKey(r).tr,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: selected ? c : const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // ── Name / label ────────────────────────────────────────────
              Text(
                'nursery_contact_name'.tr,
                style: context.typography.xsMedium.copyWith(
                  color: const Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                inputFormatters: const [EnglishDigitsFormatter()],
                controller: _nameCtrl,
                focusNode: _nameFocus,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _phoneFocus.requestFocus(),
                decoration: _decoration('nursery_contact_name_hint'),
              ),
              const SizedBox(height: 16),

              // ── Phone ───────────────────────────────────────────────────
              Text(
                'nursery_contact_phone'.tr,
                style: context.typography.xsMedium.copyWith(
                  color: const Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                inputFormatters: const [EnglishDigitsFormatter()],
                controller: _phoneCtrl,
                focusNode: _phoneFocus,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                textDirection: TextDirection.ltr,
                onSubmitted: (_) => _submit(),
                decoration: _decoration('nursery_contact_phone_hint'),
              ),
              const SizedBox(height: 24),

              // ── Preview ─────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accent.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        NurseryContactModel.roleIcon(_roleKey),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ListenableBuilder(
                        listenable: Listenable.merge([_nameCtrl, _phoneCtrl]),
                        builder: (_, __) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _nameCtrl.text.isEmpty
                                  ? 'nursery_contact_preview'.tr
                                  : _nameCtrl.text,
                              style: context.typography.smSemiBold.copyWith(
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            if (_phoneCtrl.text.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                _phoneCtrl.text,
                                textDirection: TextDirection.ltr,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chat_rounded,
                      color: Color(0xFF25D366),
                      size: 22,
                    ),
                  ],
                ),
              ),
                    ],
                  ),
                ),
              ),
            ),
            // ── Pinned save button ───────────────────────────────────────
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.existing == null
                          ? 'nursery_contact_save'.tr
                          : 'nursery_contact_update'.tr,
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
