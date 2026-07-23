import '../../../../../index/index_main.dart';

class CategorySheet extends StatefulWidget {
  final PaymentCategoryModel? existing;
  const CategorySheet({super.key, this.existing});

  @override
  State<CategorySheet> createState() => _CategorySheetState();
}

class _CategorySheetState extends State<CategorySheet> with KeyboardSheetMixin {
  final _nameCtrl = TextEditingController();
  late int _colorValue;

  static const _palette = [
    0xFF0D9488, // teal
    0xFFD97706, // amber
    0xFF7C3AED, // purple
    0xFF2563EB, // blue
    0xFF16A34A, // green
    0xFFDC2626, // red
    0xFFDB2777, // pink
    0xFF64748B, // slate
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl.text = e?.name ?? '';
    _colorValue = e?.colorValue ?? _palette.first;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final session = SessionService();
    final isNew = widget.existing == null;
    final key = widget.existing?.key ?? 'cat_${DateTime.now().millisecondsSinceEpoch}';
    final model = PaymentCategoryModel(
      key: key,
      nurseryId: session.nurseryId ?? '',
      name: name,
      colorValue: _colorValue,
      isActive: true,
      createdAt: widget.existing?.createdAt ?? DateTime.now().millisecondsSinceEpoch,
    );
    final service = Get.find<BaseService<PaymentCategoryModel>>(tag: 'paymentCategories');
    Loader.show();
    service.addData(
      item: model,
      toJson: (m) => m.toJson(),
      id: key,
      voidCallBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess(isNew ? 'finance_cat_saved'.tr : 'finance_cat_updated'.tr);
          Get.back();
        } else {
          Loader.showError('finance_cat_error'.tr);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
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
                widget.existing == null ? 'finance_cat_add'.tr : 'finance_cat_edit'.tr,
                style: context.typography.lgBold.copyWith(color: const Color(0xFF1E293B)),
              ),
              SizedBox(height: 20.h),
              Text(
                'finance_cat_name'.tr,
                style: context.typography.xsMedium.copyWith(color: const Color(0xFF374151)),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  hintText: 'finance_cat_name_hint'.tr,
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
              ),
              SizedBox(height: 20.h),
              Text(
                'finance_cat_color'.tr,
                style: context.typography.xsMedium.copyWith(color: const Color(0xFF374151)),
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 12.w,
                runSpacing: 12.h,
                children: _palette.map((c) {
                  final selected = _colorValue == c;
                  return GestureDetector(
                    onTap: () => setState(() => _colorValue = c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 40.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: Color(c),
                        shape: BoxShape.circle,
                        border: selected
                            ? Border.all(color: const Color(0xFF1E293B), width: 3)
                            : Border.all(color: Colors.transparent, width: 3),
                        boxShadow: selected
                            ? [BoxShadow(color: Color(c).withOpacity(0.4), blurRadius: 8.r, spreadRadius: 2.r)]
                            : null,
                      ),
                      child: selected
                          ? Icon(Icons.check, color: Colors.white, size: 18.sp)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 24.h),
              // Preview
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Color(_colorValue).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Color(_colorValue).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36.w,
                      height: 36.h,
                      decoration: BoxDecoration(
                        color: Color(_colorValue),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(Icons.wallet_rounded, color: Colors.white, size: 18.sp),
                    ),
                    SizedBox(width: 12.w),
                    ListenableBuilder(
                      listenable: _nameCtrl,
                      builder: (_, __) => Text(
                      _nameCtrl.text.isEmpty ? 'finance_cat_preview'.tr : _nameCtrl.text,
                      style: context.typography.smSemiBold.copyWith(color: Color(_colorValue)),
                    )),
                  ],
                ),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: Text(
                    widget.existing == null ? 'finance_cat_save'.tr : 'finance_cat_update'.tr,
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
