import '../../../../index/index_main.dart';

const _accent = Color(0xFF7C3AED);
const _ink = Color(0xFF1E293B);
const _muted = Color(0xFF94A3B8);
const _field = Color(0xFFF8FAFC);
const _border = Color(0xFFE2E8F0);

/// Reception's simple cash-collection sheet. Reception only ever takes cash at
/// the desk, so there's no payment-method picker (the shared manager
/// [PaymentSheet] keeps that). Records the payment via [PaymentController].
class ReceptionPaymentSheet extends StatefulWidget {
  final String nurseryId;

  const ReceptionPaymentSheet({
    super.key,
    required this.nurseryId,
  });

  @override
  State<ReceptionPaymentSheet> createState() => _ReceptionPaymentSheetState();
}

class _ReceptionPaymentSheetState extends State<ReceptionPaymentSheet> {
  final _controller = Get.find<PaymentController>();
  String? _childId;
  String? _categoryKey;
  PaymentCategoryModel? _selectedCategory;
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    final children = _controller.childList;
    if (_childId == null || amount <= 0 || children.isEmpty) {
      Loader.showError('payment_fill_required'.tr);
      return;
    }

    final child = children.firstWhere(
      (c) => c.key == _childId,
      orElse: () => children.first,
    );

    _controller.savePayment(
      childId: _childId!,
      parentId: child.parentId,
      category: _selectedCategory,
      amount: amount,
      method: 'cash',
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      nurseryId: widget.nurseryId,
    );

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              SizedBox(height: 14.h),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      'payment_add'.tr,
                      style: context.typography.mdBold
                          .copyWith(fontSize: 18, color: _ink),
                    ),
                  ),
                  GestureDetector(
                    onTap: Get.back,
                    child: Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: _field,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close_rounded,
                          size: 19.sp, color: const Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              _label('invoice_child'.tr),
              SizedBox(height: 6.h),
              Obx(() {
                final children = _controller.childList;
                return DropdownButtonFormField<String>(
                  value: _childId,
                  isExpanded: true,
                  hint: Text(
                    children.isEmpty
                        ? 'payment_no_children'.tr
                        : 'payment_select_child'.tr,
                    style: context.typography.smRegular
                        .copyWith(color: _muted, fontSize: 14),
                  ),
                  items: children
                      .map((c) => DropdownMenuItem(
                            value: c.key!,
                            child: Text(c.fullName),
                          ))
                      .toList(),
                  onChanged: children.isEmpty
                      ? null
                      : (v) => setState(() => _childId = v),
                  decoration: _decoration(),
                );
              }),
              SizedBox(height: 16.h),

              Obx(() {
                if (_controller.categories.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('payment_category'.tr),
                    SizedBox(height: 6.h),
                    _buildCategoryPicker(),
                    SizedBox(height: 16.h),
                  ],
                );
              }),

              _label('payment_amount'.tr),
              SizedBox(height: 6.h),
              TextField(
                controller: _amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: context.typography.smRegular
                    .copyWith(fontSize: 15, color: _ink),
                decoration: _decoration(hint: 'payment_amount_hint'.tr).copyWith(
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

              _label('invoice_notes'.tr),
              SizedBox(height: 6.h),
              TextField(
                controller: _notesCtrl,
                maxLines: 2,
                style: context.typography.smRegular
                    .copyWith(fontSize: 15, color: _ink),
                decoration: _decoration(hint: 'payment_notes_hint'.tr),
              ),
              SizedBox(height: 24.h),

              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r)),
                    elevation: 0,
                  ),
                  child: Text(
                    'payment_save'.tr,
                    style: context.typography.smSemiBold.copyWith(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPicker() {
    return GestureDetector(
      onTap: _openCategorySheet,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        decoration: BoxDecoration(
          color: _field,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            if (_selectedCategory != null) ...[
              Container(
                width: 28.w,
                height: 28.h,
                decoration: BoxDecoration(
                  color: Color(_selectedCategory!.colorValue),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(Icons.wallet_rounded,
                    color: Colors.white, size: 14.sp),
              ),
              SizedBox(width: 10.w),
              Text(
                _selectedCategory!.name,
                style: context.typography.smMedium
                    .copyWith(color: Color(_selectedCategory!.colorValue)),
              ),
            ] else ...[
              Icon(Icons.category_outlined, size: 18.sp, color: _muted),
              SizedBox(width: 10.w),
              Text(
                'payment_cat_select'.tr,
                style: context.typography.smRegular
                    .copyWith(color: _muted, fontSize: 14),
              ),
            ],
            const Spacer(),
            const Icon(Icons.keyboard_arrow_down_rounded, color: _muted),
          ],
        ),
      ),
    );
  }

  Future<void> _openCategorySheet() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 40.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'payment_category'.tr,
                style: context.typography.mdBold.copyWith(color: _ink),
              ),
              SizedBox(height: 16.h),
              _CategoryOption(
                label: 'payment_cat_none'.tr,
                color: _muted,
                selected: _categoryKey == null,
                onTap: () {
                  setState(() {
                    _categoryKey = null;
                    _selectedCategory = null;
                  });
                  Get.back();
                },
              ),
              ..._controller.categories.map((cat) => _CategoryOption(
                    label: cat.name,
                    color: Color(cat.colorValue),
                    selected: _categoryKey == cat.key,
                    onTap: () {
                      setState(() {
                        _categoryKey = cat.key;
                        _selectedCategory = cat;
                      });
                      Get.back();
                    },
                  )),
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
        hintStyle:
            context.typography.smRegular.copyWith(color: _muted, fontSize: 14),
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
          borderSide: BorderSide(color: _accent, width: 1.5),
        ),
      );
}

class _CategoryOption extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryOption({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: selected ? color : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 10.w,
              height: 10.h,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            SizedBox(width: 12.w),
            Text(
              label,
              style: selected
                  ? context.typography.smSemiBold.copyWith(color: color)
                  : context.typography.smRegular
                      .copyWith(color: const Color(0xFF475569)),
            ),
            const Spacer(),
            if (selected)
              Icon(Icons.check_circle_rounded, color: color, size: 18.sp),
          ],
        ),
      ),
    );
  }
}
