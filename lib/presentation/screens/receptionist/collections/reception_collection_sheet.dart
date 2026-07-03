import '../../../../index/index_main.dart';
import 'reception_collection_controller.dart';

const _accent = Color(0xFF7C3AED);
const _ink = Color(0xFF1E293B);
const _muted = Color(0xFF94A3B8);
const _field = Color(0xFFF8FAFC);
const _border = Color(0xFFE2E8F0);

/// Records a single cash collection for the already-selected child. Pure
/// [FeeCategoryModel] + [FinancialTransactionModel] flow: pick category →
/// default amount pre-fills → edit if needed → optional note → save.
class ReceptionCollectionSheet extends StatefulWidget {
  final ReceptionCollectionController controller;

  const ReceptionCollectionSheet({super.key, required this.controller});

  @override
  State<ReceptionCollectionSheet> createState() =>
      _ReceptionCollectionSheetState();
}

class _ReceptionCollectionSheetState extends State<ReceptionCollectionSheet> {
  FeeCategoryModel? _category;
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _pickCategory(FeeCategoryModel cat) {
    setState(() {
      _category = cat;
      if (cat.defaultAmount != null && cat.defaultAmount! > 0) {
        _amountCtrl.text = cat.defaultAmount!.toStringAsFixed(0);
      }
    });
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (_category == null) {
      Loader.showError('collection_pick_category'.tr);
      return;
    }
    if (amount <= 0) {
      Loader.showError('payment_fill_required'.tr);
      return;
    }
    final ok = await widget.controller.saveCollection(
      category: _category!,
      amount: amount,
      notes: _notesCtrl.text,
    );
    if (ok) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.controller.selectedChild.value;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'collection_new'.tr,
                          style: context.typography.mdBold
                              .copyWith(fontSize: 18, color: _ink),
                        ),
                        if (child != null) ...[
                          SizedBox(height: 2.h),
                          Text(
                            child.fullName,
                            style: context.typography.xsRegular
                                .copyWith(fontSize: 12.5, color: _muted),
                          ),
                        ],
                      ],
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
                      child: Icon(Icons.close_rounded,
                          size: 19.sp, color: const Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              _label('payment_category'.tr),
              SizedBox(height: 8.h),
              _CategoryGrid(
                categories: widget.controller.categories,
                selected: _category,
                onSelect: _pickCategory,
              ),
              SizedBox(height: 18.h),

              _label('payment_amount'.tr),
              SizedBox(height: 6.h),
              TextField(
                inputFormatters: const [EnglishDigitsFormatter()],
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
                inputFormatters: const [EnglishDigitsFormatter()],
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
                      borderRadius: BorderRadius.circular(14.r),
                    ),
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
          borderSide: const BorderSide(color: _accent, width: 1.5),
        ),
      );
}

class _CategoryGrid extends StatelessWidget {
  final List<FeeCategoryModel> categories;
  final FeeCategoryModel? selected;
  final ValueChanged<FeeCategoryModel> onSelect;

  const _CategoryGrid({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 14.w),
        decoration: BoxDecoration(
          color: _field,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: _border),
        ),
        child: Text(
          'collection_no_categories'.tr,
          textAlign: TextAlign.center,
          style: context.typography.xsRegular
              .copyWith(color: _muted, fontSize: 12.5),
        ),
      );
    }
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: categories.map((cat) {
        final isSel = selected?.key == cat.key;
        return GestureDetector(
          onTap: () => onSelect(cat),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isSel ? _accent.withValues(alpha: 0.10) : _field,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSel ? _accent : _border,
                width: isSel ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSel) ...[
                  Icon(Icons.check_circle_rounded, size: 16.sp, color: _accent),
                  SizedBox(width: 6.w),
                ],
                Text(
                  cat.name,
                  style: context.typography.smMedium.copyWith(
                    color: isSel ? _accent : const Color(0xFF475569),
                    fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
