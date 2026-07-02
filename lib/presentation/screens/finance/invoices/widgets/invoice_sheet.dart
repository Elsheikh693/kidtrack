import '../../../../../index/index_main.dart';

class InvoiceSheet extends StatefulWidget {
  final InvoiceModel? existing;
  final List<ChildModel> children;
  final List<PaymentCategoryModel> categories;
  final String nurseryId;

  const InvoiceSheet({
    super.key,
    this.existing,
    required this.children,
    required this.categories,
    required this.nurseryId,
  });

  @override
  State<InvoiceSheet> createState() => _InvoiceSheetState();
}

class _InvoiceSheetState extends State<InvoiceSheet> with KeyboardSheetMixin {
  late String _childId;
  late String _status;
  String? _categoryId;
  String? _categoryName;
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  int? _dueDate;

  static const _statuses = ['pending', 'paid', 'overdue', 'cancelled'];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _childId = e?.childId ?? (widget.children.isNotEmpty ? widget.children.first.key! : '');
    _status = e?.status ?? 'pending';
    _categoryId = e?.categoryId;
    _categoryName = e?.categoryName;
    _titleCtrl.text = e?.title ?? '';
    _amountCtrl.text = e != null ? e.amount.toStringAsFixed(2) : '';
    _discountCtrl.text = e != null ? e.discount.toStringAsFixed(2) : '0';
    _notesCtrl.text = e?.notes ?? '';
    _dueDate = e?.dueDate;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _discountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showAppDatePicker(
      context,
      initialDate: _dueDate != null ? DateTime.fromMillisecondsSinceEpoch(_dueDate!) : now,
      minimumDate: now.subtract(const Duration(days: 365)),
      maximumDate: now.add(const Duration(days: 730)),
    );
    if (picked != null) setState(() => _dueDate = picked.millisecondsSinceEpoch);
  }

  void _submit() {
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    final discount = double.tryParse(_discountCtrl.text.trim()) ?? 0;
    if (_childId.isEmpty || amount <= 0) return;
    final service = Get.find<InvoiceParentService>();
    final key = widget.existing?.key ?? 'inv_${DateTime.now().millisecondsSinceEpoch}';
    final model = InvoiceModel(
      key: key,
      nurseryId: widget.nurseryId,
      childId: _childId,
      categoryId: _categoryId,
      categoryName: _categoryName,
      title: _titleCtrl.text.trim().isEmpty ? null : _titleCtrl.text.trim(),
      amount: amount,
      discount: discount,
      totalAmount: amount - discount,
      status: _status,
      dueDate: _dueDate,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      createdAt: widget.existing?.createdAt,
    );
    Loader.show();
    if (widget.existing == null) {
      service.add(
        item: model,
        callBack: (status) {
          Loader.dismiss();
          if (status == ResponseStatus.success) {
            Loader.showSuccess('invoice_save_success'.tr);
            Get.back();
          } else {
            Loader.showError('invoice_error_failed'.tr);
          }
        },
      );
    } else {
      service.update(
        item: model,
        callBack: (status) {
          Loader.dismiss();
          if (status == ResponseStatus.success) {
            Loader.showSuccess('invoice_update_success'.tr);
            Get.back();
          } else {
            Loader.showError('invoice_error_failed'.tr);
          }
        },
      );
    }
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
                widget.existing == null ? 'invoice_add'.tr : 'invoice_edit'.tr,
                style: context.typography.lgBold.copyWith(color: Color(0xFF1E293B)),
              ),
              SizedBox(height: 20.h),

              // ── Category chips ──────────────────────────────────────────────
              if (widget.categories.isNotEmpty) ...[
                _label('invoice_category'.tr),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: widget.categories.map((cat) {
                    final active = _categoryId == cat.key;
                    final color = Color(cat.colorValue);
                    return GestureDetector(
                      onTap: () => setState(() {
                        _categoryId = cat.key;
                        _categoryName = cat.name;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: active ? color : Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: active ? color : const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.wallet_rounded, size: 14.sp, color: active ? Colors.white : color),
                            SizedBox(width: 6.w),
                            Text(
                              cat.name,
                              style: context.typography.xsMedium.copyWith(
                                color: active ? Colors.white : const Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16.h),
              ],

              // ── Child dropdown ──────────────────────────────────────────────
              _label('invoice_child'.tr),
              SizedBox(height: 6.h),
              DropdownButtonFormField<String>(
                value: _childId.isEmpty ? null : _childId,
                items: widget.children
                    .map((c) => DropdownMenuItem(value: c.key!, child: Text(c.fullName)))
                    .toList(),
                onChanged: (v) => setState(() => _childId = v ?? ''),
                decoration: _decoration('invoice_child'.tr),
              ),
              SizedBox(height: 14.h),

              // ── Title ───────────────────────────────────────────────────────
              _label('invoice_title'.tr),
              SizedBox(height: 6.h),
              TextField(
                controller: _titleCtrl,
                decoration: _decoration('invoice_title_hint'.tr),
              ),
              SizedBox(height: 14.h),

              // ── Amount + discount ───────────────────────────────────────────
              Row(children: [
                Expanded(child: _fieldCol('invoice_amount'.tr, _amountCtrl, TextInputType.number)),
                SizedBox(width: 12.w),
                Expanded(child: _fieldCol('invoice_discount'.tr, _discountCtrl, TextInputType.number)),
              ]),
              SizedBox(height: 14.h),

              // ── Status ──────────────────────────────────────────────────────
              _label('invoice_status_label'.tr),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: _statuses.map((s) {
                  final active = _status == s;
                  final color = _statusColor(s);
                  return GestureDetector(
                    onTap: () => setState(() => _status = s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: active ? color : Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: active ? color : const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        'invoice_status_$s'.tr,
                        style: context.typography.xsMedium.copyWith(
                          color: active ? Colors.white : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 14.h),

              // ── Due date ────────────────────────────────────────────────────
              GestureDetector(
                onTap: _pickDueDate,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(children: [
                    Icon(Icons.calendar_today_outlined, size: 16.sp, color: const Color(0xFF94A3B8)),
                    SizedBox(width: 8.w),
                    Text(
                      _dueDate != null
                          ? () {
                              final d = DateTime.fromMillisecondsSinceEpoch(_dueDate!);
                              return '${d.day}/${d.month}/${d.year}';
                            }()
                          : 'invoice_due_date'.tr,
                      style: context.typography.xsRegular.copyWith(
                        color: _dueDate != null ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
                      ),
                    ),
                    if (_dueDate != null) ...[
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() => _dueDate = null),
                        child: Icon(Icons.close, size: 16.sp, color: const Color(0xFF94A3B8)),
                      ),
                    ],
                  ]),
                ),
              ),
              SizedBox(height: 14.h),

              // ── Notes ───────────────────────────────────────────────────────
              TextFormField(
                controller: _notesCtrl,
                decoration: _decoration('invoice_notes'.tr),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: Text(
                    widget.existing == null ? 'invoice_save'.tr : 'invoice_update'.tr,
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
        style: context.typography.xsMedium.copyWith(color: const Color(0xFF374151)),
      );

  Widget _fieldCol(String label, TextEditingController ctrl, TextInputType type) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label),
          SizedBox(height: 6.h),
          TextField(controller: ctrl, keyboardType: type, decoration: _decoration(label)),
        ],
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

  Color _statusColor(String s) {
    switch (s) {
      case 'paid':
        return const Color(0xFF16A34A);
      case 'overdue':
        return const Color(0xFFDC2626);
      case 'cancelled':
        return const Color(0xFF64748B);
      default:
        return const Color(0xFFD97706);
    }
  }
}
