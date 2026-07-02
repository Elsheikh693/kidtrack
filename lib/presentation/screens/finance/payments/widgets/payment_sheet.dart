import '../../../../../index/index_main.dart';

class PaymentSheet extends StatefulWidget {
  final List<ChildModel> children;
  final List<PaymentCategoryModel> categories;
  final String nurseryId;

  const PaymentSheet({
    super.key,
    required this.children,
    required this.categories,
    required this.nurseryId,
  });

  @override
  State<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<PaymentSheet> with KeyboardSheetMixin {
  String? _childId;
  String? _categoryKey;
  PaymentCategoryModel? _selectedCategory;
  String _method = 'cash';
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  static const _methods = ['cash', 'card', 'bank_transfer', 'online'];

  static const _methodIcons = {
    'cash': Icons.money_rounded,
    'card': Icons.credit_card_rounded,
    'bank_transfer': Icons.account_balance_rounded,
    'online': Icons.smartphone_rounded,
  };

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (_childId == null || amount <= 0) {
      Loader.showError('payment_fill_required'.tr);
      return;
    }

    final child = widget.children.firstWhere(
      (c) => c.key == _childId,
      orElse: () => widget.children.first,
    );

    Get.find<PaymentController>().savePayment(
      childId: _childId!,
      parentId: child.parentId,
      category: _selectedCategory,
      amount: amount,
      method: _method,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      nurseryId: widget.nurseryId,
    );

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: wrapWithKeyboard(
        context: context,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
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
                'payment_add'.tr,
                style: context.typography.lgBold.copyWith(color: Color(0xFF1E293B)),
              ),
              SizedBox(height: 20.h),

              // ── Category dropdown ───────────────────────────────────────────
              if (widget.categories.isNotEmpty) ...[
                _label('payment_category'.tr),
                SizedBox(height: 8.h),
                _buildCategoryDropdown(),
                SizedBox(height: 16.h),
              ],

              // ── Child dropdown ──────────────────────────────────────────────
              _label('invoice_child'.tr),
              SizedBox(height: 6.h),
              DropdownButtonFormField<String>(
                value: _childId,
                hint: Text(
                  'payment_select_child'.tr,
                  style: context.typography.xsRegular.copyWith(color: Color(0xFF94A3B8)),
                ),
                items: widget.children
                    .map((c) => DropdownMenuItem(
                          value: c.key!,
                          child: Text(c.fullName),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _childId = v),
                decoration: _decoration('payment_select_child'.tr),
              ),
              SizedBox(height: 16.h),

              // ── Amount ──────────────────────────────────────────────────────
              _label('payment_amount'.tr),
              SizedBox(height: 6.h),
              TextField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: _decoration('payment_amount_hint'.tr).copyWith(
                  prefixIcon: Icon(Icons.attach_money_rounded,
                      color: const Color(0xFF94A3B8), size: 18.sp),
                ),
              ),
              SizedBox(height: 16.h),

              // ── Payment method ──────────────────────────────────────────────
              _label('payment_method'.tr),
              SizedBox(height: 10.h),
              Row(
                children: _methods.map((m) {
                  final active = _method == m;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _method = m),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: EdgeInsets.only(
                            left: m != _methods.first ? 6.w : 0),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: BoxDecoration(
                          color: active
                              ? const Color(0xFFD97706)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: active
                                ? const Color(0xFFD97706)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _methodIcons[m] ?? Icons.payments_rounded,
                              size: 20.sp,
                              color: active
                                  ? Colors.white
                                  : const Color(0xFF94A3B8),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'payment_method_$m'.tr,
                              style: context.typography.xsRegular.copyWith(color: active ? Colors.white : const Color(0xFF64748B)),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 16.h),

              // ── Notes ───────────────────────────────────────────────────────
              _label('invoice_notes'.tr),
              SizedBox(height: 6.h),
              TextField(
                controller: _notesCtrl,
                maxLines: 2,
                decoration: _decoration('payment_notes_hint'.tr),
              ),
              SizedBox(height: 24.h),

              // ── Submit ──────────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD97706),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                    elevation: 0,
                  ),
                  child: Text(
                    'payment_save'.tr,
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

  Widget _buildCategoryDropdown() {
    return GestureDetector(
      onTap: () async {
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
                    style: context.typography.mdBold.copyWith(color: Color(0xFF1E293B)),
                  ),
                  SizedBox(height: 16.h),
                  // "No category" option
                  _CategoryOption(
                    label: 'payment_cat_none'.tr,
                    color: const Color(0xFF94A3B8),
                    selected: _categoryKey == null,
                    onTap: () {
                      setState(() {
                        _categoryKey = null;
                        _selectedCategory = null;
                      });
                      Get.back();
                    },
                  ),
                  ...widget.categories.map((cat) => _CategoryOption(
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
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
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
                style: context.typography.smMedium.copyWith(color: Color(_selectedCategory!.colorValue)),
              ),
            ] else ...[
              Icon(Icons.category_outlined,
                  size: 18.sp, color: const Color(0xFF94A3B8)),
              SizedBox(width: 10.w),
              Text(
                'payment_cat_select'.tr,
                style: context.typography.xsRegular.copyWith(color: Color(0xFF94A3B8)),
              ),
            ],
            const Spacer(),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: context.typography.xsMedium.copyWith(color: Color(0xFF374151)),
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
        contentPadding:
            EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
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
                  : context.typography.smRegular.copyWith(color: Color(0xFF475569)),
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
