import '../../../../../index/index_main.dart';
import '../controller.dart';
import 'setup_item_tile.dart';

class FeesStep extends StatelessWidget {
  final ManagerSetupController controller;
  const FeesStep({super.key, required this.controller});

  void _showAdd(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (_) => _AddFeeSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.fees;
      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48.w,
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Icon(Icons.payments_rounded,
                            color: const Color(0xFF10B981), size: 24.sp),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('setup_step_fees'.tr,
                                style: context.typography.mdBold.copyWith(
                                    fontSize: 17,
                                    color: const Color(0xFF1F2937))),
                            Text('setup_fees_subtitle'.tr,
                                style: context.typography.xsRegular.copyWith(
                                    fontSize: 12,
                                    color: const Color(0xFF6B7280))),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showAdd(context),
                        icon: Icon(Icons.add_rounded, size: 16.sp),
                        label: Text('setup_add_fee'.tr,
                            style: context.typography.xsRegular
                                .copyWith(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5E35B1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r)),
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 8.h),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  if (list.isEmpty)
                    _EmptyFees()
                  else
                    ...list.map((f) => SetupItemTile(
                          icon: Icons.payments_rounded,
                          iconBg: const Color(0xFFECFDF5),
                          iconColor: const Color(0xFF10B981),
                          title: f.name,
                          subtitle:
                              '${f.price.toStringAsFixed(0)} ${'setup_fee_currency'.tr} / ${'fee_duration_${f.duration}'.tr}',
                          onDelete: () => controller.deleteFee(f.key ?? ''),
                        )),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _EmptyFees extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Column(
            children: [
              Icon(Icons.payments_outlined,
                  size: 52.sp, color: const Color(0xFFD1D5DB)),
              SizedBox(height: 12.h),
              Text('setup_fees_empty'.tr,
                  style: context.typography.smSemiBold.copyWith(
                      fontSize: 14, color: const Color(0xFF9CA3AF))),
            ],
          ),
        ),
      );
}

// ── Add Fee Sheet ─────────────────────────────────────────────────────────────

class _AddFeeSheet extends StatefulWidget {
  final ManagerSetupController controller;
  const _AddFeeSheet({required this.controller});
  @override
  State<_AddFeeSheet> createState() => _AddFeeSheetState();
}

class _AddFeeSheetState extends State<_AddFeeSheet> {
  final _nameCtrl  = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  String _duration = 'monthly';

  static const _durations = ['monthly', 'term', 'yearly', 'oneTime'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0;
    if (name.isEmpty) {
      Loader.showError('setup_fee_name_required'.tr);
      return;
    }
    Get.back();
    widget.controller.addFee(
      name: name,
      price: price,
      duration: _duration,
      description: _descCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              SizedBox(height: 20.h),
              Text('setup_add_fee_title'.tr,
                  style: context.typography.mdBold
                      .copyWith(fontSize: 18, color: const Color(0xFF1E293B))),
              SizedBox(height: 24.h),

              _Label('setup_fee_name_label'.tr),
              SizedBox(height: 6.h),
              _Field(controller: _nameCtrl, hint: 'setup_fee_name_hint'.tr),
              SizedBox(height: 16.h),

              _Label('setup_fee_price_label'.tr),
              SizedBox(height: 6.h),
              _Field(
                  controller: _priceCtrl,
                  hint: 'setup_fee_price_hint'.tr,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              SizedBox(height: 16.h),

              _Label('setup_fee_duration_label'.tr),
              SizedBox(height: 6.h),
              StatefulBuilder(builder: (_, ss) => Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _duration,
                        isExpanded: true,
                        style: context.typography.smRegular.copyWith(
                            fontSize: 15, color: const Color(0xFF1E293B)),
                        items: _durations
                            .map((d) => DropdownMenuItem(
                                value: d,
                                child: Text('fee_duration_$d'.tr)))
                            .toList(),
                        onChanged: (d) {
                          if (d != null) ss(() => _duration = d);
                        },
                      ),
                    ),
                  )),
              SizedBox(height: 16.h),

              _Label('setup_fee_desc_label'.tr),
              SizedBox(height: 6.h),
              _Field(
                  controller: _descCtrl, hint: 'setup_fee_desc_hint'.tr),
              SizedBox(height: 28.h),

              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5E35B1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r)),
                    elevation: 0,
                  ),
                  child: Text('setup_add_btn'.tr,
                      style: context.typography.smSemiBold
                          .copyWith(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: context.typography.smMedium
          .copyWith(fontSize: 14, color: const Color(0xFF475569)));
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  const _Field(
      {required this.controller,
      required this.hint,
      this.keyboardType = TextInputType.text});
  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: const [EnglishDigitsFormatter()],
        style: context.typography.smRegular
            .copyWith(fontSize: 15, color: const Color(0xFF1E293B)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: context.typography.smRegular
              .copyWith(color: const Color(0xFFCBD5E1), fontSize: 14),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide:
                const BorderSide(color: Color(0xFF5E35B1), width: 1.5),
          ),
        ),
      );
}
