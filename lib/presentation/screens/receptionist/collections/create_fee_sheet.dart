import '../../../../index/index_main.dart';

const _accent = Color(0xFF7C3AED);
const _ink = Color(0xFF1E293B);
const _muted = Color(0xFF94A3B8);
const _field = Color(0xFFF8FAFC);
const _border = Color(0xFFE2E8F0);

/// Creates a one-off broadcast fee (e.g. "App subscription") that is charged to
/// every active child in the branch. The charge merges into this month's
/// collection worklist, where the receptionist marks who paid.
class CreateFeeSheet extends StatefulWidget {
  final CollectionsController controller;

  const CreateFeeSheet({super.key, required this.controller});

  @override
  State<CreateFeeSheet> createState() => _CreateFeeSheetState();
}

class _CreateFeeSheetState extends State<CreateFeeSheet> {
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  bool _notify = true;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (title.isEmpty || amount <= 0) {
      Loader.showError('fee_missing_data'.tr);
      return;
    }
    Get.back();
    widget.controller.createFee(
      title: title,
      amount: amount,
      notifyParents: _notify,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: _border,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              SizedBox(height: 14.h),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      'fee_new_title'.tr,
                      style: context.typography.mdBold.copyWith(
                        fontSize: 18,
                        color: _ink,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: Get.back,
                    child: Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: const BoxDecoration(
                        color: _field,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 19.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              _label('fee_name_label'.tr),
              SizedBox(height: 6.h),
              TextField(
                controller: _titleCtrl,
                textInputAction: TextInputAction.next,
                style: context.typography.smRegular
                    .copyWith(fontSize: 15, color: _ink),
                decoration: _decoration(hint: 'fee_name_hint'.tr),
              ),
              SizedBox(height: 16.h),

              _label('fee_amount_label'.tr),
              SizedBox(height: 6.h),
              TextField(
                inputFormatters: const [EnglishDigitsFormatter()],
                controller: _amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: context.typography.smRegular
                    .copyWith(fontSize: 15, color: _ink),
                decoration: _decoration(hint: 'fee_amount_hint'.tr).copyWith(
                  suffixIcon: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    child: Text(
                      'overdue_currency'.tr,
                      textAlign: TextAlign.center,
                      style: context.typography.smSemiBold
                          .copyWith(color: _accent, fontSize: 14),
                    ),
                  ),
                  suffixIconConstraints:
                      const BoxConstraints(minWidth: 0, minHeight: 0),
                ),
              ),
              SizedBox(height: 16.h),

              // ── Notify parents toggle ────────────────────────────────────
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _field,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: _border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'fee_notify_parents'.tr,
                            style: context.typography.smSemiBold
                                .copyWith(color: _ink, fontSize: 14),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'fee_notify_parents_hint'.tr,
                            style: context.typography.xsRegular
                                .copyWith(color: _muted, fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: _notify,
                      activeColor: _accent,
                      onChanged: (v) => setState(() => _notify = v),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.groups_2_rounded, size: 16.sp, color: _muted),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'fee_target_hint'.tr,
                      style: context.typography.xsRegular
                          .copyWith(color: _muted, fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 22.h),

              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'fee_create_button'.tr,
                    style:
                        context.typography.smSemiBold.copyWith(fontSize: 16),
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
        style: context.typography.smMedium
            .copyWith(fontSize: 14, color: const Color(0xFF475569)),
      );

  InputDecoration _decoration({String? hint}) => InputDecoration(
        hintText: hint,
        hintStyle: context.typography.smRegular
            .copyWith(color: _muted, fontSize: 14),
        filled: true,
        fillColor: _field,
        contentPadding:
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: _accent, width: 1.5),
        ),
      );
}
