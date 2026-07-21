import '../../../../index/index_main.dart';
import 'reception_collection_controller.dart';

const _accent = Color(0xFF7C3AED);
const _ink = Color(0xFF111827);
const _muted = Color(0xFF8A93A4);
const _line = Color(0xFFEEF0F4);
const _bg = Color(0xFFF6F7FB);
const _green = Color(0xFF16A34A);
const _red = Color(0xFFDC2626);

/// Reception collect sheet: shows a child's total outstanding, lets the
/// receptionist collect the FULL remaining or a PARTIAL amount (with a live
/// "remaining after" readout), and pick the method — cash / InstaPay / e-wallet.
class CollectPaymentSheet extends StatefulWidget {
  final ReceptionCollectionController controller;
  final ChildModel child;

  const CollectPaymentSheet({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  State<CollectPaymentSheet> createState() => _CollectPaymentSheetState();
}

class _CollectPaymentSheetState extends State<CollectPaymentSheet> {
  bool _partial = false;
  String _method = 'cash';
  final _amountCtrl = TextEditingController();

  static const _methods = ['cash', 'instapay', 'wallet'];

  double get _outstanding => widget.controller.outstandingFor(widget.child.key);

  double get _enteredAmount {
    if (!_partial) return _outstanding;
    return double.tryParse(_amountCtrl.text.trim()) ?? 0;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final amount = _enteredAmount;
    if (amount <= 0 || amount > _outstanding + 0.5) {
      Loader.showError('collect_amount_invalid'.tr);
      return;
    }
    final ok = await widget.controller.collectDues(
      child: widget.child,
      amount: amount,
      method: _method,
    );
    if (ok) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final remainingAfter = (_outstanding - _enteredAmount).clamp(0, _outstanding);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 28.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                '${'collect_sheet_title'.tr} ${widget.child.fullName}',
                style: context.typography.lgBold.copyWith(color: _ink),
              ),
              SizedBox(height: 14.h),

              // ── Outstanding banner ──────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: (_outstanding > 0 ? _red : _green)
                      .withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      _outstanding > 0
                          ? Icons.account_balance_wallet_rounded
                          : Icons.verified_rounded,
                      size: 20.sp,
                      color: _outstanding > 0 ? _red : _green,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'collect_outstanding'.tr,
                      style: context.typography.xsMedium.copyWith(color: _muted),
                    ),
                    const Spacer(),
                    Text(
                      '${_outstanding.toStringAsFixed(0)} ${'overdue_currency'.tr}',
                      style: context.typography.smSemiBold.copyWith(
                        color: _outstanding > 0 ? _red : _green,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),

              // ── Guardian transfer proof (if submitted) ──────────────────────
              if (widget.controller.proofFor(widget.child.key) != null) ...[
                _ProofPreview(
                  url: widget.controller.proofFor(widget.child.key)!,
                ),
                SizedBox(height: 14.h),
              ],

              // ── Full / partial toggle ───────────────────────────────────────
              Row(
                children: [
                  _ModeChip(
                    label: 'collect_full'.tr,
                    active: !_partial,
                    onTap: () => setState(() => _partial = false),
                  ),
                  SizedBox(width: 10.w),
                  _ModeChip(
                    label: 'collect_partial'.tr,
                    active: _partial,
                    onTap: () => setState(() => _partial = true),
                  ),
                ],
              ),

              // ── Partial amount + remaining-after ────────────────────────────
              if (_partial) ...[
                SizedBox(height: 16.h),
                Text(
                  'collect_amount'.tr,
                  style: context.typography.xsMedium.copyWith(color: _ink),
                ),
                SizedBox(height: 6.h),
                TextField(
                  controller: _amountCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: const [EnglishDigitsFormatter()],
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: '0',
                    filled: true,
                    fillColor: _bg,
                    suffixText: 'overdue_currency'.tr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.trending_down_rounded, size: 15.sp, color: _muted),
                    SizedBox(width: 6.w),
                    Text(
                      'collect_remaining_after'.tr,
                      style: context.typography.xsRegular.copyWith(color: _muted),
                    ),
                    const Spacer(),
                    Text(
                      '${remainingAfter.toStringAsFixed(0)} ${'overdue_currency'.tr}',
                      style: context.typography.xsMedium.copyWith(
                        color: remainingAfter > 0 ? _red : _green,
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 18.h),

              // ── Method ──────────────────────────────────────────────────────
              Text(
                'collect_method'.tr,
                style: context.typography.smSemiBold.copyWith(color: _ink),
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  for (var i = 0; i < _methods.length; i++) ...[
                    if (i > 0) SizedBox(width: 8.w),
                    _MethodChip(
                      method: _methods[i],
                      active: _method == _methods[i],
                      onTap: () => setState(() => _method = _methods[i]),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 24.h),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _outstanding <= 0 ? null : _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFCBD5E1),
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    'collect_confirm'.tr,
                    style: context.typography.smSemiBold.copyWith(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
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

class _ModeChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _ModeChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? _accent.withValues(alpha: 0.12) : _bg,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: active ? _accent : _line),
          ),
          child: Text(
            label,
            style: context.typography.smSemiBold.copyWith(
              color: active ? _accent : _muted,
            ),
          ),
        ),
      ),
    );
  }
}

class _MethodChip extends StatelessWidget {
  final String method;
  final bool active;
  final VoidCallback onTap;
  const _MethodChip({
    required this.method,
    required this.active,
    required this.onTap,
  });

  IconData get _icon {
    switch (method) {
      case 'instapay':
        return Icons.qr_code_rounded;
      case 'wallet':
        return Icons.account_balance_wallet_rounded;
      default:
        return Icons.payments_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
          decoration: BoxDecoration(
            color: active ? _accent.withValues(alpha: 0.12) : _bg,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: active ? _accent : _line),
          ),
          child: Column(
            children: [
              Icon(_icon, size: 20.sp, color: active ? _accent : _muted),
              SizedBox(height: 6.h),
              Text(
                'payment_method_$method'.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.typography.xsMedium.copyWith(
                  color: active ? _accent : _muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The guardian's uploaded transfer screenshot, shown to reception before they
/// confirm the collection. Tap to view it full-screen.
class _ProofPreview extends StatelessWidget {
  final String url;
  const _ProofPreview({required this.url});

  void _view() => showFullImage(url);

  @override
  Widget build(BuildContext context) {
    const amber = Color(0xFFD97706);
    return GestureDetector(
      onTap: _view,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: amber.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: amber.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: amber.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(11.r),
              ),
              child: Icon(Icons.receipt_long_rounded, size: 20.sp, color: amber),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'collect_proof_title'.tr,
                    style: context.typography.smSemiBold.copyWith(color: _ink),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'collect_view_proof'.tr,
                    style: context.typography.xsRegular.copyWith(color: amber),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: amber,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.zoom_in_rounded, size: 15.sp, color: Colors.white),
                  SizedBox(width: 4.w),
                  Text(
                    'invoice_proof_view'.tr,
                    style: context.typography.xsMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
