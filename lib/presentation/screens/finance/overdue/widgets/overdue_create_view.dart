import '../../../../../index/index_main.dart';

typedef OnSaveObligation =
    void Function({
      required String party,
      String? item,
      required ObligationCategory category,
      required double amount,
      required bool payNow,
      DateTime? dueDate,
    });

class OverdueCreateView extends StatefulWidget {
  final List<ObligationCategory> categories;
  final OnSaveObligation onSave;

  const OverdueCreateView({
    super.key,
    required this.categories,
    required this.onSave,
  });

  @override
  State<OverdueCreateView> createState() => _OverdueCreateViewState();
}

class _OverdueCreateViewState extends State<OverdueCreateView> {
  final _partyCtrl = TextEditingController();
  final _itemCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();

  ObligationCategory? _category;
  bool _payNow = true;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _category = widget.categories.isNotEmpty ? widget.categories.first : null;
    _partyCtrl.addListener(_refresh);
    _amountCtrl.addListener(_refresh);
  }

  @override
  void dispose() {
    _partyCtrl.dispose();
    _itemCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  bool get _canSave =>
      _partyCtrl.text.trim().isNotEmpty &&
      (double.tryParse(_amountCtrl.text.trim()) ?? 0) > 0 &&
      _category != null;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showAppDatePicker(
      context,
      initialDate: _dueDate ?? now,
      minimumDate: now.subtract(const Duration(days: 365)),
      maximumDate: now.add(const Duration(days: 730)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _submit() {
    if (!_canSave) return;
    widget.onSave(
      party: _partyCtrl.text.trim(),
      item: _itemCtrl.text.trim(),
      category: _category!,
      amount: double.parse(_amountCtrl.text.trim()),
      payNow: _payNow,
      dueDate: _payNow ? null : _dueDate,
    );
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            onPressed: Get.back,
            icon: const Icon(Icons.close, color: Color(0xFF1E293B)),
          ),
          title: Text(
            'overdue_sheet_title'.tr,
            style: context.typography.mdBold.copyWith(
              color: const Color(0xFF1E293B),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('overdue_field_party'.tr),
              SizedBox(height: 6.h),
              _field(_partyCtrl, 'overdue_field_party_hint'.tr),
              SizedBox(height: 14.h),

              _label('overdue_field_item'.tr),
              SizedBox(height: 6.h),
              _field(_itemCtrl, 'overdue_field_item_hint'.tr),
              SizedBox(height: 14.h),

              _label('overdue_field_amount'.tr),
              SizedBox(height: 6.h),
              _field(
                _amountCtrl,
                'overdue_field_amount_hint'.tr,
                type: TextInputType.number,
              ),
              SizedBox(height: 16.h),

              _label('overdue_field_category'.tr),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: widget.categories.map(_categoryChip).toList(),
              ),
              SizedBox(height: 18.h),

              _label('overdue_field_paytype'.tr),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: _payTypeCard(
                      selected: _payNow,
                      icon: Icons.bolt_rounded,
                      title: 'overdue_paytype_now'.tr,
                      subtitle: 'overdue_paytype_now_sub'.tr,
                      onTap: () => setState(() => _payNow = true),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _payTypeCard(
                      selected: !_payNow,
                      icon: Icons.schedule_rounded,
                      title: 'overdue_paytype_later'.tr,
                      subtitle: 'overdue_paytype_later_sub'.tr,
                      onTap: () => setState(() => _payNow = false),
                    ),
                  ),
                ],
              ),
              if (!_payNow) ...[
                SizedBox(height: 14.h),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16.sp,
                          color: const Color(0xFF94A3B8),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          _dueDate != null
                              ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                              : 'overdue_field_duedate'.tr,
                          style: context.typography.smRegular.copyWith(
                            color: _dueDate != null
                                ? const Color(0xFF1E293B)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          minimum: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSave ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: const Color(0xFFCBD5E1),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'overdue_sheet_save'.tr,
                style: context.typography.smSemiBold.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _categoryChip(ObligationCategory cat) {
    final active = _category?.id == cat.id;
    final color = Color(cat.colorValue);
    return GestureDetector(
      onTap: () => setState(() => _category = cat),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: active ? color : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: active ? color : const Color(0xFFE2E8F0)),
        ),
        child: Text(
          cat.name,
          style: context.typography.xsMedium.copyWith(
            color: active ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _payTypeCard({
    required bool selected,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFE2E8F0),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 20.sp,
              color: selected ? AppColors.primary : const Color(0xFF94A3B8),
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: context.typography.smSemiBold.copyWith(
                color: selected ? AppColors.primary : const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              subtitle,
              style: context.typography.xsRegular.copyWith(
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: context.typography.xsMedium.copyWith(color: const Color(0xFF374151)),
  );

  Widget _field(
    TextEditingController ctrl,
    String hint, {
    TextInputType type = TextInputType.text,
  }) => TextField(
    inputFormatters: const [EnglishDigitsFormatter()],
    controller: ctrl,
    keyboardType: type,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: context.typography.xsRegular.copyWith(
        fontSize: 13,
        color: const Color(0xFF94A3B8),
      ),
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
