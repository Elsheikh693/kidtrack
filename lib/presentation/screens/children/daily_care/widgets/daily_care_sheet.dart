import '../../../../../index/index_main.dart';

class DailyCareSheet extends StatefulWidget {
  final DailyCareLogModel? initial;
  final RxMap<String, String> childNames;
  final RxMap<String, String> classroomNames;

  const DailyCareSheet({
    super.key,
    this.initial,
    required this.childNames,
    required this.classroomNames,
  });

  @override
  State<DailyCareSheet> createState() => _DailyCareSheetState();
}

class _DailyCareSheetState extends State<DailyCareSheet> with KeyboardSheetMixin {
  late final DailyCareLogParentService _service;
  String? _childId;
  String? _classroomId;
  String? _breakfastStatus;
  String? _lunchStatus;
  String? _snackStatus;
  String? _mood;
  int _bathroomCount = 0;
  int _diaperChanges = 0;
  final _notesCtrl = TextEditingController();
  bool _loading = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    _service = Get.find<DailyCareLogParentService>();
    if (_isEdit) {
      final i = widget.initial!;
      _childId = i.childId;
      _classroomId = i.classroomId;
      _breakfastStatus = i.breakfastStatus;
      _lunchStatus = i.lunchStatus;
      _snackStatus = i.snackStatus;
      _mood = i.mood;
      _bathroomCount = i.bathroomCount;
      _diaperChanges = i.diaperChanges;
      _notesCtrl.text = i.notes ?? '';
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_childId == null) {
      Loader.showError('care_error_child'.tr);
      return;
    }
    if (_classroomId == null) {
      Loader.showError('care_error_classroom'.tr);
      return;
    }
    setState(() => _loading = true);
    Loader.show();
    final session = Get.find<SessionService>();
    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final model = DailyCareLogModel(
      key: widget.initial?.key ?? const Uuid().v4(),
      nurseryId: session.nurseryId ?? '',
      childId: _childId!,
      classroomId: _classroomId!,
      recordedBy: session.userId ?? '',
      date: widget.initial?.date ?? date,
      breakfastStatus: _breakfastStatus,
      lunchStatus: _lunchStatus,
      snackStatus: _snackStatus,
      mood: _mood,
      bathroomCount: _bathroomCount,
      diaperChanges: _diaperChanges,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      createdAt: widget.initial?.createdAt,
    );

    void cb(ResponseStatus s) {
      Loader.dismiss();
      setState(() => _loading = false);
      if (s == ResponseStatus.success) {
        Loader.showSuccess(
          _isEdit ? 'care_success_updated'.tr : 'care_success_added'.tr,
        );
        Get.back();
      } else {
        Loader.showError('care_error_failed'.tr);
      }
    }

    if (_isEdit) {
      await _service.update(item: model, callBack: cb);
    } else {
      await _service.add(item: model, callBack: cb);
    }
  }

  @override
  Widget build(BuildContext context) {
    return wrapWithKeyboard(
      context: context,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              _isEdit ? 'care_edit_title'.tr : 'care_add_title'.tr,
              style: context.typography.mdBold.copyWith(
                fontSize: 18,
                color: const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 20.h),
            _DropdownField(
              label: 'care_child_label'.tr,
              hint: 'care_child_hint'.tr,
              value: _childId,
              items: widget.childNames,
              onChanged: (v) => setState(() => _childId = v),
            ),
            SizedBox(height: 16.h),
            _DropdownField(
              label: 'care_classroom_label'.tr,
              hint: 'care_classroom_hint'.tr,
              value: _classroomId,
              items: widget.classroomNames,
              onChanged: (v) => setState(() => _classroomId = v),
            ),
            SizedBox(height: 16.h),
            Text(
              'care_meals_section'.tr,
              style: context.typography.displaySmBold.copyWith(
                fontSize: 15,
                color: const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 10.h),
            _MealRow(
              label: 'care_breakfast'.tr,
              value: _breakfastStatus,
              onChanged: (v) => setState(() => _breakfastStatus = v),
            ),
            SizedBox(height: 10.h),
            _MealRow(
              label: 'care_lunch'.tr,
              value: _lunchStatus,
              onChanged: (v) => setState(() => _lunchStatus = v),
            ),
            SizedBox(height: 10.h),
            _MealRow(
              label: 'care_snack'.tr,
              value: _snackStatus,
              onChanged: (v) => setState(() => _snackStatus = v),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _CounterField(
                    label: 'care_bathroom_count'.tr,
                    value: _bathroomCount,
                    onChanged: (v) => setState(() => _bathroomCount = v),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _CounterField(
                    label: 'care_diaper_changes'.tr,
                    value: _diaperChanges,
                    onChanged: (v) => setState(() => _diaperChanges = v),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              'care_mood_section'.tr,
              style: context.typography.smSemiBold.copyWith(
                fontSize: 14,
                color: const Color(0xFF475569),
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              children: ['happy', 'calm', 'cranky', 'sick'].map((m) {
                final active = _mood == m;
                return GestureDetector(
                  onTap: () => setState(() => _mood = active ? null : m),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: active
                            ? AppColors.primary
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Text(
                      'care_mood_$m'.tr,
                      style: context.typography.xsMedium.copyWith(
                        fontSize: 13,
                        color: active ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16.h),
            Text(
              'care_notes_label'.tr,
              style: context.typography.smSemiBold.copyWith(
                fontSize: 14,
                color: const Color(0xFF475569),
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'care_save'.tr,
                  style: context.typography.smSemiBold.copyWith(
                    color: Colors.white,
                    fontSize: 16,
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

class _DropdownField extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final RxMap<String, String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: context.typography.smSemiBold.copyWith(
          fontSize: 14,
          color: const Color(0xFF475569),
        ),
      ),
      SizedBox(height: 8.h),
      Obx(
        () => DropdownButtonFormField<String>(
          value: value,
          hint: Text(hint),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
          ),
          items: items.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    ],
  );
}

class _MealRow extends StatelessWidget {
  final String label;
  final String? value;
  final ValueChanged<String?> onChanged;
  const _MealRow({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: context.typography.xsRegular.copyWith(fontSize: 13, color: const Color(0xFF475569))),
      SizedBox(height: 6.h),
      Wrap(
        spacing: 8.w,
        children: ['ate_all', 'ate_some', 'did_not_eat'].map((s) {
          final active = value == s;
          return GestureDetector(
            onTap: () => onChanged(active ? null : s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: active ? AppColors.primary : const Color(0xFFE2E8F0),
                ),
              ),
              child: Text(
                'care_meal_$s'.tr,
                style: context.typography.xsRegular.copyWith(
                  fontSize: 12,
                  color: active ? Colors.white : const Color(0xFF475569),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ],
  );
}

class _CounterField extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  const _CounterField({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
      ),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove, size: 18),
              onPressed: value > 0 ? () => onChanged(value - 1) : null,
            ),
            Expanded(
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, size: 18),
              onPressed: () => onChanged(value + 1),
            ),
          ],
        ),
      ),
    ],
  );
}
