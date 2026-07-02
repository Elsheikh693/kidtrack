import '../../../../../index/index_main.dart';

class PackageSheet extends StatefulWidget {
  final PackageModel? initial;
  const PackageSheet({super.key, this.initial});

  @override
  State<PackageSheet> createState() => _PackageSheetState();
}

class _PackageSheetState extends State<PackageSheet> {
  late final PackageParentService _service;
  late final BranchParentService _branchService;

  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final discountCtrl = TextEditingController();
  String _duration = 'monthly';

  bool _discountEnabled = false;
  String _discountType = 'percentage'; // percentage | fixed
  int? _offerStart;
  int? _offerEnd;

  List<BranchModel> _branches = [];
  BranchModel? _selectedBranch;
  bool _loadingBranches = true;

  late final HandleKeyboardService _keyboardService;
  late final List<String> _keys;

  bool get isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    _service = Get.find<PackageParentService>();
    _branchService = Get.find<BranchParentService>();
    _keyboardService = HandleKeyboardService();
    _keys = _keyboardService.generateKeys('package_sheet', 4);
    if (isEdit) {
      final p = widget.initial!;
      nameCtrl.text = p.name;
      descCtrl.text = p.description ?? '';
      priceCtrl.text = p.price.toStringAsFixed(0);
      _duration = p.duration;
      _discountEnabled = p.discountEnabled;
      _discountType = p.discountType;
      if (p.discountValue > 0) {
        discountCtrl.text = p.discountValue.toStringAsFixed(0);
      }
      _offerStart = p.offerStart;
      _offerEnd = p.offerEnd;
    }
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    await _branchService.getAll(
      callBack: (list) {
        _branches = list.whereType<BranchModel>().toList();
        if (isEdit && widget.initial!.branchId != null) {
          _selectedBranch = _branches
              .firstWhereOrNull((b) => b.key == widget.initial!.branchId);
        }
      },
    );
    if (mounted) setState(() => _loadingBranches = false);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    priceCtrl.dispose();
    discountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      Loader.showError('package_error_name'.tr);
      return;
    }
    if (_selectedBranch == null) {
      Loader.showError('package_error_branch'.tr);
      return;
    }
    final price = double.tryParse(priceCtrl.text.trim()) ?? 0;
    final discountValue =
        _discountEnabled ? (double.tryParse(discountCtrl.text.trim()) ?? 0) : 0.0;
    final nurseryId = SessionService().nurseryId ?? '';
    final id = isEdit ? (widget.initial!.key ?? const Uuid().v4()) : const Uuid().v4();
    final item = PackageModel(
      key: id,
      nurseryId: nurseryId,
      branchId: _selectedBranch!.key,
      name: name,
      description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
      price: price,
      duration: _duration,
      isActive: widget.initial?.isActive ?? true,
      discountEnabled: _discountEnabled && discountValue > 0,
      discountType: _discountType,
      discountValue: discountValue,
      offerStart: _offerStart,
      offerEnd: _offerEnd,
    );
    Loader.show();
    if (isEdit) {
      await _service.update(item: item, callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('package_success_updated'.tr);
          Get.back();
        } else {
          Loader.showError('package_error_failed'.tr);
        }
      });
    } else {
      await _service.add(item: item, callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('package_success_added'.tr);
          Get.back();
        } else {
          Loader.showError('package_error_failed'.tr);
        }
      });
    }
  }

  double _previewFinalPrice() {
    final price = double.tryParse(priceCtrl.text.trim()) ?? 0;
    final dv = double.tryParse(discountCtrl.text.trim()) ?? 0;
    if (!_discountEnabled || dv <= 0) return price;
    final d = _discountType == 'fixed' ? price - dv : price * (1 - dv / 100);
    return d < 0 ? 0 : d;
  }

  Future<void> _pickOfferDate(bool isStart, void Function() refresh) async {
    final now = DateTime.now();
    final initialMs = isStart ? _offerStart : _offerEnd;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialMs != null
          ? DateTime.fromMillisecondsSinceEpoch(initialMs)
          : now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (picked == null) return;
    final ms = picked.millisecondsSinceEpoch;
    if (isStart) {
      _offerStart = ms;
    } else {
      _offerEnd = ms;
    }
    refresh();
  }

  String _dateLabel(int? ms) {
    if (ms == null) return 'package_offer_date_optional'.tr;
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
  }

  Widget _buildDiscountSection() {
    return StatefulBuilder(
      builder: (ctx, setS) {
        final price = double.tryParse(priceCtrl.text.trim()) ?? 0;
        final fin = _previewFinalPrice();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => setS(() => _discountEnabled = !_discountEnabled),
              child: Row(
                children: [
                  Expanded(child: _Label('package_discount_label'.tr)),
                  Icon(
                    _discountEnabled
                        ? Icons.toggle_on_rounded
                        : Icons.toggle_off_rounded,
                    size: 38.sp,
                    color: _discountEnabled
                        ? const Color(0xFF10B981)
                        : const Color(0xFFCBD5E1),
                  ),
                ],
              ),
            ),
            if (_discountEnabled) ...[
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: _DiscountTypeChip(
                      label: 'package_discount_percentage'.tr,
                      value: 'percentage',
                      selected: _discountType,
                      onTap: (v) => setS(() => _discountType = v),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _DiscountTypeChip(
                      label: 'package_discount_fixed'.tr,
                      value: 'fixed',
                      selected: _discountType,
                      onTap: (v) => setS(() => _discountType = v),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              _Field(
                controller: discountCtrl,
                hint: _discountType == 'percentage' ? '%' : '0',
                keyboardType: TextInputType.number,
                focusNode: _keyboardService.getFocusNode(_keys[3]),
                onChanged: (_) => setS(() {}),
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Text('package_final_price'.tr,
                        style: context.typography.xsRegular.copyWith(
                            fontSize: 13, color: const Color(0xFF475569))),
                    const Spacer(),
                    if (fin < price) ...[
                      Text(
                        price.toStringAsFixed(0),
                        style: context.typography.xsRegular.copyWith(
                          fontSize: 13,
                          color: const Color(0xFF94A3B8),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ],
                    Text(
                      '${fin.toStringAsFixed(0)} ${'currency'.tr}',
                      style: context.typography.displaySmBold.copyWith(
                          color: const Color(0xFF10B981)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              _Label('package_offer_window'.tr),
              SizedBox(height: 6.h),
              Row(
                children: [
                  Expanded(
                    child: _OfferDateBox(
                      label: 'package_offer_from'.tr,
                      value: _dateLabel(_offerStart),
                      onTap: () => _pickOfferDate(true, () => setS(() {})),
                      onClear: _offerStart == null
                          ? null
                          : () => setS(() => _offerStart = null),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _OfferDateBox(
                      label: 'package_offer_to'.tr,
                      value: _dateLabel(_offerEnd),
                      onTap: () => _pickOfferDate(false, () => setS(() {})),
                      onClear: _offerEnd == null
                          ? null
                          : () => setS(() => _offerEnd = null),
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 14.h, 8.w, 14.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      isEdit ? 'package_edit_title'.tr : 'package_add_title'.tr,
                      style: context.typography.mdBold.copyWith(
                          color: const Color(0xFF1E293B)),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 34.w,
                      height: 34.h,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close_rounded,
                          size: 18.sp, color: const Color(0xFF64748B)),
                    ),
                  ),
                  SizedBox(width: 8.w),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
            Expanded(
              child: KeyboardActions(
                config: _keyboardService.buildConfig(context, _keys),
                disableScroll: true,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Label('package_name_label'.tr),
                      SizedBox(height: 6.h),
                      _Field(
                        controller: nameCtrl,
                        hint: 'package_name_hint'.tr,
                        focusNode: _keyboardService.getFocusNode(_keys[0]),
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: 16.h),
                      _Label('package_branch_label'.tr),
                      SizedBox(height: 6.h),
                      _BranchDropdown(
                        loading: _loadingBranches,
                        branches: _branches,
                        selected: _selectedBranch,
                        onChanged: (b) => setState(() => _selectedBranch = b),
                      ),
                      SizedBox(height: 16.h),
                      _Label('package_description_label'.tr),
                      SizedBox(height: 6.h),
                      _Field(
                        controller: descCtrl,
                        hint: 'package_description_hint'.tr,
                        maxLines: 2,
                        focusNode: _keyboardService.getFocusNode(_keys[1]),
                      ),
                      SizedBox(height: 16.h),
                      _Label('package_price_label'.tr),
                      SizedBox(height: 6.h),
                      _Field(
                        controller: priceCtrl,
                        hint: '0',
                        keyboardType: TextInputType.number,
                        focusNode: _keyboardService.getFocusNode(_keys[2]),
                      ),
                      SizedBox(height: 16.h),
                      _Label('package_duration_label'.tr),
                      SizedBox(height: 6.h),
                      StatefulBuilder(
                        builder: (ctx, setS) => Column(
                          children: [
                            _DurationOption(label: 'package_duration_monthly'.tr, value: 'monthly', selected: _duration, onTap: (v) { setS(() => _duration = v); }),
                            SizedBox(height: 8.h),
                            _DurationOption(label: 'package_duration_term'.tr, value: 'term', selected: _duration, onTap: (v) { setS(() => _duration = v); }),
                            SizedBox(height: 8.h),
                            _DurationOption(label: 'package_duration_yearly'.tr, value: 'yearly', selected: _duration, onTap: (v) { setS(() => _duration = v); }),
                            SizedBox(height: 8.h),
                            _DurationOption(label: 'package_duration_oneTime'.tr, value: 'oneTime', selected: _duration, onTap: (v) { setS(() => _duration = v); }),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _buildDiscountSection(),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 12.h),
                child: SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      elevation: 0,
                    ),
                    child: Text('package_save'.tr, style: context.typography.smSemiBold.copyWith(fontSize: 16)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BranchDropdown extends StatelessWidget {
  final bool loading;
  final List<BranchModel> branches;
  final BranchModel? selected;
  final void Function(BranchModel?) onChanged;
  const _BranchDropdown({
    required this.loading,
    required this.branches,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return _ReadonlyBox('...');
    }
    if (branches.isEmpty) {
      return _ReadonlyBox('setup_no_branches_yet'.tr);
    }
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<BranchModel?>(
          value: selected,
          isExpanded: true,
          style: context.typography.smRegular.copyWith(color: const Color(0xFF1E293B)),
          hint: Text(
            'setup_select_branch'.tr,
            style: context.typography.smRegular.copyWith(color: const Color(0xFFCBD5E1), fontSize: 14),
          ),
          items: branches
              .map((b) => DropdownMenuItem(value: b, child: Text(b.name)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ReadonlyBox extends StatelessWidget {
  final String label;
  const _ReadonlyBox(this.label);
  @override
  Widget build(BuildContext context) => Container(
        height: 52.h,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        alignment: AlignmentDirectional.centerStart,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Text(label,
            style: context.typography.smRegular.copyWith(color: const Color(0xFFCBD5E1), fontSize: 14)),
      );
}

class _DurationOption extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final void Function(String) onTap;
  const _DurationOption({required this.label, required this.value, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981).withValues(alpha: 0.08) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: isSelected ? const Color(0xFF10B981) : const Color(0xFFE2E8F0), width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked, size: 18.sp, color: isSelected ? const Color(0xFF10B981) : const Color(0xFF94A3B8)),
            SizedBox(width: 10.w),
            Text(label, style: context.typography.smRegular.copyWith(fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, color: isSelected ? const Color(0xFF10B981) : const Color(0xFF475569))),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: context.typography.smMedium.copyWith(fontSize: 14, color: const Color(0xFF475569)));
}

class _DiscountTypeChip extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final void Function(String) onTap;
  const _DiscountTypeChip({required this.label, required this.value, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981).withValues(alpha: 0.08) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: isSelected ? const Color(0xFF10B981) : const Color(0xFFE2E8F0), width: isSelected ? 1.5 : 1),
        ),
        child: Text(label, style: context.typography.smRegular.copyWith(fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, color: isSelected ? const Color(0xFF10B981) : const Color(0xFF475569))),
      ),
    );
  }
}

class _OfferDateBox extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  const _OfferDateBox({required this.label, required this.value, required this.onTap, this.onClear});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.typography.xsRegular.copyWith(fontSize: 12, color: const Color(0xFF94A3B8))),
        SizedBox(height: 6.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 48.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Icon(Icons.event_rounded, size: 16.sp, color: const Color(0xFF94A3B8)),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.typography.xsRegular.copyWith(fontSize: 13, color: const Color(0xFF1E293B))),
                ),
                if (onClear != null)
                  GestureDetector(
                    onTap: onClear,
                    child: Icon(Icons.close_rounded, size: 15.sp, color: const Color(0xFF94A3B8)),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final int maxLines;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  const _Field({required this.controller, required this.hint, this.keyboardType = TextInputType.text, this.maxLines = 1, this.focusNode, this.textInputAction, this.onChanged});

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    focusNode: focusNode,
    keyboardType: keyboardType,
    maxLines: maxLines,
    textInputAction: textInputAction,
    onChanged: onChanged,
    style: context.typography.smRegular.copyWith(color: const Color(0xFF1E293B)),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: context.typography.smRegular.copyWith(color: const Color(0xFFCBD5E1), fontSize: 14),
      filled: true, fillColor: const Color(0xFFF8FAFC),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
    ),
  );
}
