import '../../../../../index/index_main.dart';

/// Records a payment against a single daily-expense charge. Defaults to the full
/// remaining amount (editable for a partial collection) and a payment method,
/// then delegates to [ChildChargesController.recordPayment] — which runs
/// [FinanceService.recordPayment] so the invoice is settled AND a revenue entry
/// lands in the finance reports.
class ChargePaymentSheet extends StatefulWidget {
  const ChargePaymentSheet({
    super.key,
    required this.controller,
    required this.charge,
  });

  final ChildChargesController controller;
  final InvoiceModel charge;

  @override
  State<ChargePaymentSheet> createState() => _ChargePaymentSheetState();
}

class _ChargePaymentSheetState extends State<ChargePaymentSheet> {
  late final TextEditingController _amountCtrl;
  String _method = 'cash';

  static const _methods = ['cash', 'instapay', 'wallet'];

  @override
  void initState() {
    super.initState();
    final remaining = widget.charge.remaining;
    _amountCtrl = TextEditingController(
      text: remaining.toStringAsFixed(remaining % 1 == 0 ? 0 : 2),
    );
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (amount <= 0) {
      Loader.showError('daily_expense_invalid_amount'.tr);
      return;
    }
    widget.controller
        .recordPayment(charge: widget.charge, amount: amount, method: _method);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
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
                'daily_expense_collect'.tr,
                style: context.typography.lgBold
                    .copyWith(color: const Color(0xFF1E293B)),
              ),
              SizedBox(height: 6.h),
              Text(
                '${widget.charge.title ?? ''} · '
                '${widget.controller.childName(widget.charge.childId)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.typography.xsRegular
                    .copyWith(color: AppColors.grayMedium),
              ),
              SizedBox(height: 20.h),
              Text(
                'daily_expense_amount'.tr,
                style: context.typography.xsMedium
                    .copyWith(color: const Color(0xFF374151)),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: context.typography.smRegular
                    .copyWith(color: AppColors.textDefault),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  suffixText: 'currency'.tr,
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
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                'daily_expense_method'.tr,
                style: context.typography.xsMedium
                    .copyWith(color: const Color(0xFF374151)),
              ),
              SizedBox(height: 8.h),
              Row(
                children: _methods.map((m) {
                  final selected = _method == m;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _method = m),
                      child: Container(
                        margin: EdgeInsets.only(left: 8.w),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Text(
                          'daily_expense_method_$m'.tr,
                          style: context.typography.xsMedium.copyWith(
                            color: selected
                                ? AppColors.primary
                                : AppColors.grayMedium,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
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
                    'daily_expense_confirm_payment'.tr,
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
