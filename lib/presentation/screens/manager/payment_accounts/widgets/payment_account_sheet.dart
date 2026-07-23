import '../../../../../index/index_main.dart';

/// Add/edit form for one nursery payment account. Handles its own save via
/// [PaymentAccountParentService], then pops — the list controller reloads on
/// return.
class PaymentAccountSheet extends StatefulWidget {
  final PaymentAccountModel? existing;

  const PaymentAccountSheet({super.key, this.existing});

  @override
  State<PaymentAccountSheet> createState() => _PaymentAccountSheetState();
}

class _PaymentAccountSheetState extends State<PaymentAccountSheet>
    with KeyboardSheetMixin {
  late String _type;
  final _titleCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _type = e?.type ?? 'instapay';
    _titleCtrl.text = e?.title ?? '';
    _numberCtrl.text = e?.number ?? '';
    _linkCtrl.text = e?.link ?? '';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _numberCtrl.dispose();
    _linkCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    final number = _numberCtrl.text.trim();
    final link = _type == 'instapay' ? _linkCtrl.text.trim() : '';
    if (title.isEmpty || (number.isEmpty && link.isEmpty)) {
      Loader.showError('nursery_pay_account_required'.tr);
      return;
    }

    final session = SessionService();
    final e = widget.existing;
    final key = e?.key ?? 'pacc_${DateTime.now().millisecondsSinceEpoch}';
    final model = PaymentAccountModel(
      key: key,
      nurseryId: session.nurseryId ?? '',
      type: _type,
      title: title,
      number: number,
      link: link,
      createdAt: e?.createdAt,
    );

    final service = Get.find<PaymentAccountParentService>();
    Loader.show();
    void done(ResponseStatus status) {
      Loader.dismiss();
      if (status == ResponseStatus.success) {
        Loader.showSuccess('nursery_pay_account_saved'.tr);
        Get.back();
      } else {
        Loader.showError('nursery_pay_account_save_error'.tr);
      }
    }

    if (e == null) {
      service.add(item: model, callBack: done);
    } else {
      service.update(item: model, callBack: done);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isInstapay = _type == 'instapay';
    return Directionality(
      textDirection: appTextDirection,
      child: wrapWithKeyboard(
        context: context,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
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
                widget.existing == null
                    ? 'nursery_pay_accounts_add'.tr
                    : 'nursery_pay_account_edit'.tr,
                style: context.typography.lgBold
                    .copyWith(color: const Color(0xFF1E293B)),
              ),
              SizedBox(height: 20.h),

              // ── Type toggle ────────────────────────────────────────────────
              _label('nursery_pay_account_type'.tr),
              SizedBox(height: 8.h),
              Row(
                children: [
                  _TypeChip(
                    icon: Icons.qr_code_rounded,
                    label: 'nursery_pay_type_instapay'.tr,
                    active: isInstapay,
                    color: const Color(0xFF6D4AFF),
                    onTap: () => setState(() => _type = 'instapay'),
                  ),
                  SizedBox(width: 10.w),
                  _TypeChip(
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'nursery_pay_type_wallet'.tr,
                    active: !isInstapay,
                    color: const Color(0xFF16A34A),
                    onTap: () => setState(() => _type = 'wallet'),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // ── Title ──────────────────────────────────────────────────────
              _label('nursery_pay_account_name'.tr),
              SizedBox(height: 6.h),
              TextField(
                controller: _titleCtrl,
                decoration: _decoration('nursery_pay_account_name_hint'.tr),
              ),
              SizedBox(height: 14.h),

              // ── Number ─────────────────────────────────────────────────────
              _label(isInstapay
                  ? 'pay_instapay_number'.tr
                  : 'pay_wallet_number'.tr),
              SizedBox(height: 6.h),
              TextField(
                controller: _numberCtrl,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                inputFormatters: const [EnglishDigitsFormatter()],
                decoration: _decoration('nursery_pay_account_number_hint'.tr),
              ),

              // ── Link (InstaPay only) ───────────────────────────────────────
              if (isInstapay) ...[
                SizedBox(height: 14.h),
                _label('nursery_pay_account_link'.tr),
                SizedBox(height: 6.h),
                TextField(
                  controller: _linkCtrl,
                  keyboardType: TextInputType.url,
                  textDirection: TextDirection.ltr,
                  decoration: _decoration('nursery_pay_account_link_hint'.tr),
                ),
              ],
              SizedBox(height: 24.h),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'nursery_pay_account_save'.tr,
                    style: context.typography.displaySmBold,
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

  InputDecoration _decoration(String hint) => InputDecoration(
        hintText: hint,
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
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      );
}

class _TypeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const _TypeChip({
    required this.icon,
    required this.label,
    required this.active,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: active ? color.withValues(alpha: 0.12) : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: active ? color : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18.sp,
                  color: active ? color : const Color(0xFF94A3B8)),
              SizedBox(width: 8.w),
              Text(
                label,
                style: context.typography.xsMedium.copyWith(
                  color: active ? color : const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
