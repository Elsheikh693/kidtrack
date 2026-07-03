import 'package:intl/intl.dart' hide TextDirection;
import '../../../../index/index_main.dart';

const _accent = Color(0xFFDC2626);
const _ink = Color(0xFF1E293B);
const _muted = Color(0xFF94A3B8);
const _field = Color(0xFFF8FAFC);
const _border = Color(0xFFE2E8F0);

/// The fixed expense categories (مرتبات/إيجار/كهرباء/أدوات/أخرى). Stored as a
/// stable key in `categoryId`; the translated label is snapshotted onto the
/// expense so a later locale change never rewrites history.
const List<String> expenseCategoryKeys = [
  'exp_cat_salaries',
  'exp_cat_rent',
  'exp_cat_utilities',
  'exp_cat_supplies',
  'exp_cat_other',
];

/// Opens the add-expense bottom sheet for the dashboard's current scope.
Future<void> showExpenseFormSheet({
  required FinanceDashboardController controller,
}) {
  return Get.bottomSheet(
    _ExpenseFormSheet(controller: controller),
    isScrollControlled: true,
    backgroundColor: Colors.white,
  );
}

class _ExpenseFormSheet extends StatefulWidget {
  final FinanceDashboardController controller;
  const _ExpenseFormSheet({required this.controller});

  @override
  State<_ExpenseFormSheet> createState() => _ExpenseFormSheetState();
}

class _ExpenseFormSheetState extends State<_ExpenseFormSheet> {
  String? _categoryKey;
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime _date = DateTime.now();

  /// Owner in NETWORK scope must choose which branch (or overhead) the cost
  /// belongs to. Manager / single-branch scope is fixed.
  late final bool _needsBranchPick =
      widget.controller.isOwner && widget.controller.scopeBranchId == null;

  /// null = network overhead (only meaningful when [_needsBranchPick]).
  String? _pickedBranchId;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  List<BranchModel> get _branches =>
      Get.find<OwnerScopeService>().branches.toList();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (_categoryKey == null) {
      Loader.showError('expense_pick_category'.tr);
      return;
    }
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (amount <= 0) {
      Loader.showError('payment_fill_required'.tr);
      return;
    }
    final branchId = _needsBranchPick
        ? _pickedBranchId
        : widget.controller.scopeBranchId;

    final ok = await widget.controller.saveExpense(
      categoryKey: _categoryKey!,
      categoryLabel: _categoryKey!.tr,
      amount: amount,
      dateMs: DateTime(_date.year, _date.month, _date.day, 12)
          .millisecondsSinceEpoch,
      note: _noteCtrl.text,
      branchId: branchId,
    );
    if (ok) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
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
                SizedBox(height: 18.h),
                Text(
                  'expense_form_title'.tr,
                  style: context.typography.mdBold
                      .copyWith(color: _ink, fontSize: 18),
                ),
                SizedBox(height: 18.h),

                // ── Category ──────────────────────────────────────────────
                _Label('expense_form_category'.tr),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: expenseCategoryKeys.map((key) {
                    final selected = _categoryKey == key;
                    return GestureDetector(
                      onTap: () => setState(() => _categoryKey = key),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
                        decoration: BoxDecoration(
                          color: selected ? _accent : _field,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: selected ? _accent : _border,
                          ),
                        ),
                        child: Text(
                          key.tr,
                          style: context.typography.smMedium.copyWith(
                            color: selected ? Colors.white : _ink,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 18.h),

                // ── Branch (owner network only) ───────────────────────────
                if (_needsBranchPick) ...[
                  _Label('expense_form_branch'.tr),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      _BranchChip(
                        label: 'expense_form_overhead'.tr,
                        selected: _pickedBranchId == null,
                        onTap: () => setState(() => _pickedBranchId = null),
                      ),
                      ..._branches.map((b) => _BranchChip(
                            label: b.name,
                            selected: _pickedBranchId == b.key,
                            onTap: () =>
                                setState(() => _pickedBranchId = b.key),
                          )),
                    ],
                  ),
                  SizedBox(height: 18.h),
                ],

                // ── Amount ────────────────────────────────────────────────
                _Label('expense_form_amount'.tr),
                SizedBox(height: 8.h),
                _FieldBox(
                  child: TextField(
                    controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [EnglishDigitsFormatter()],
                    style: context.typography.smSemiBold
                        .copyWith(color: _ink, fontSize: 16),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: '0',
                      suffixText: 'currency'.tr,
                      suffixStyle: context.typography.xsRegular
                          .copyWith(color: _muted),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // ── Date ──────────────────────────────────────────────────
                _Label('expense_form_date'.tr),
                SizedBox(height: 8.h),
                GestureDetector(
                  onTap: _pickDate,
                  behavior: HitTestBehavior.opaque,
                  child: _FieldBox(
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 16.sp, color: _muted),
                        SizedBox(width: 8.w),
                        Text(
                          DateFormat('d MMMM yyyy', isAr ? 'ar' : 'en')
                              .format(_date),
                          style: context.typography.smMedium
                              .copyWith(color: _ink, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // ── Note ──────────────────────────────────────────────────
                _Label('expense_form_note'.tr),
                SizedBox(height: 8.h),
                _FieldBox(
                  child: TextField(
                    controller: _noteCtrl,
                    maxLines: 2,
                    style: context.typography.smRegular
                        .copyWith(color: _ink, fontSize: 14),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: 'expense_form_note_hint'.tr,
                      hintStyle:
                          context.typography.smRegular.copyWith(color: _muted),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // ── Save ──────────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: Text(
                      'expense_form_save'.tr,
                      style: context.typography.smSemiBold.copyWith(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.typography.xsMedium
          .copyWith(color: _muted, fontSize: 12.5, fontWeight: FontWeight.w700),
    );
  }
}

class _FieldBox extends StatelessWidget {
  final Widget child;
  const _FieldBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: _field,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: _border),
      ),
      child: child,
    );
  }
}

class _BranchChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _BranchChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: selected ? _ink : _field,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: selected ? _ink : _border),
        ),
        child: Text(
          label,
          style: context.typography.smMedium.copyWith(
            color: selected ? Colors.white : _ink,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
