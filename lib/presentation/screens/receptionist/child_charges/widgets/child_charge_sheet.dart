import '../../../../../index/index_main.dart';
import 'charge_child_picker.dart';

/// Add / edit a daily-expense charge: pick a child, enter the amount and the
/// reason. On save it delegates to [ChildChargesController], which writes the
/// invoice and (on add) messages + notifies the guardian.
class ChildChargeSheet extends StatefulWidget {
  const ChildChargeSheet({
    super.key,
    required this.controller,
    this.existing,
  });

  final ChildChargesController controller;
  final InvoiceModel? existing;

  @override
  State<ChildChargeSheet> createState() => _ChildChargeSheetState();
}

class _ChildChargeSheetState extends State<ChildChargeSheet> {
  final _amountCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  ChildModel? _child;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _amountCtrl.text =
          e.totalAmount.toStringAsFixed(e.totalAmount % 1 == 0 ? 0 : 2);
      _reasonCtrl.text = e.title ?? '';
      _child = widget.controller.childOf(e.childId);
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickChild() async {
    final result = await Get.bottomSheet<ChildModel>(
      ChargeChildPicker(children: widget.controller.pickableChildren),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
    );
    if (result != null) setState(() => _child = result);
  }

  void _submit() {
    final child = _child;
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    final reason = _reasonCtrl.text.trim();
    if (child == null) {
      Loader.showError('daily_expense_pick_child'.tr);
      return;
    }
    if (amount <= 0) {
      Loader.showError('daily_expense_invalid_amount'.tr);
      return;
    }
    if (reason.isEmpty) {
      Loader.showError('daily_expense_reason_required'.tr);
      return;
    }
    if (_isEdit) {
      widget.controller
          .submitEdit(item: widget.existing!, amount: amount, reason: reason);
    } else {
      widget.controller.submitAdd(child: child, amount: amount, reason: reason);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
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
                _isEdit ? 'daily_expense_edit'.tr : 'daily_expense_add'.tr,
                style: context.typography.lgBold
                    .copyWith(color: const Color(0xFF1E293B)),
              ),
              SizedBox(height: 20.h),
              _Label('daily_expense_child'.tr),
              SizedBox(height: 8.h),
              _ChildPickerField(child: _child, onTap: _isEdit ? null : _pickChild),
              SizedBox(height: 18.h),
              _Label('daily_expense_amount'.tr),
              SizedBox(height: 8.h),
              _field(
                context,
                controller: _amountCtrl,
                hint: 'daily_expense_amount_hint'.tr,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 18.h),
              _Label('daily_expense_reason'.tr),
              SizedBox(height: 8.h),
              _field(
                context,
                controller: _reasonCtrl,
                hint: 'daily_expense_reason_hint'.tr,
                maxLines: 2,
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
                    _isEdit ? 'daily_expense_update'.tr : 'daily_expense_save'.tr,
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

  Widget _field(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: context.typography.smRegular.copyWith(color: AppColors.textDefault),
      decoration: InputDecoration(
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
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.typography.xsMedium.copyWith(color: const Color(0xFF374151)),
    );
  }
}

class _ChildPickerField extends StatelessWidget {
  const _ChildPickerField({required this.child, required this.onTap});
  final ChildModel? child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            if (child != null) ...[
              ChildAvatar(
                name: child!.fullName,
                imageUrl: child!.profileImage,
                size: 34,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  child!.fullName,
                  style: context.typography.smSemiBold
                      .copyWith(color: AppColors.textDefault),
                ),
              ),
            ] else
              Expanded(
                child: Text(
                  'daily_expense_pick_child'.tr,
                  style: context.typography.smRegular
                      .copyWith(color: const Color(0xFF94A3B8)),
                ),
              ),
            if (onTap != null)
              Icon(Icons.expand_more_rounded,
                  color: AppColors.grayMedium, size: 22.sp),
          ],
        ),
      ),
    );
  }
}
