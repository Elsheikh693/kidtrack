import 'dart:io';
import '../../../../../index/index_main.dart';
import '../../../../../Data/models/nursery_event/nursery_event_model.dart';
import '../events_controller.dart';

// ── Palette ─────────────────────────────────────────────────────────────────────
const _indigo = Color(0xFF6366F1);
const _violet = Color(0xFF8B5CF6);
const _ink = Color(0xFF1E293B);
const _muted = Color(0xFF64748B);
const _faint = Color(0xFF94A3B8);
const _fieldBg = Color(0xFFF6F7FB);
const _line = Color(0xFFE9EDF3);

class CreateEventSheet extends StatefulWidget {
  const CreateEventSheet({super.key, this.editEvent});
  final NurseryEventModel? editEvent;

  @override
  State<CreateEventSheet> createState() => _CreateEventSheetState();
}

class _CreateEventSheetState extends State<CreateEventSheet>
    with KeyboardSheetMixin {
  late final CreateEventController _ctrl;
  late final FocusNode _titleFocus;
  late final FocusNode _descFocus;
  late final FocusNode _locationFocus;
  late final FocusNode _priceFocus;

  @override
  void initState() {
    super.initState();
    _ctrl = CreateEventController(editEvent: widget.editEvent);
    _ctrl.onInit();
    _titleFocus = kbNode();
    _descFocus = kbNode();
    _locationFocus = kbNode();
    _priceFocus = kbNode();
  }

  @override
  void dispose() {
    _ctrl.onClose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editEvent != null;
    return Directionality(
      textDirection: appTextDirection,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Header(isEdit: isEdit),
            Flexible(
              child: wrapWithKeyboard(
                context: context,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CoverPicker(ctrl: _ctrl),
                      SizedBox(height: 20.h),

                      _label('event_field_title'.tr),
                      _Field(
                        controller: _ctrl.titleCtrl,
                        focusNode: _titleFocus,
                        hint: 'event_field_title_hint'.tr,
                        icon: Icons.title_rounded,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_descFocus),
                      ),
                      SizedBox(height: 16.h),

                      _label('event_field_desc'.tr),
                      _Field(
                        controller: _ctrl.descCtrl,
                        focusNode: _descFocus,
                        hint: 'event_field_desc_hint'.tr,
                        icon: Icons.notes_rounded,
                        maxLines: 3,
                        textInputAction: TextInputAction.newline,
                      ),
                      SizedBox(height: 16.h),

                      // Date + Time row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('event_field_date'.tr),
                                Obx(() => _PickerTile(
                                      icon: Icons.calendar_today_rounded,
                                      text: _ctrl.selectedDate.value != null
                                          ? _formatDate(_ctrl.selectedDate.value!)
                                          : 'event_field_date'.tr,
                                      filled: _ctrl.selectedDate.value != null,
                                      onTap: () => _pickDate(context),
                                    )),
                              ],
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('event_field_time'.tr),
                                Obx(() {
                                  // ignore: unused_local_variable
                                  final _ = _ctrl.timeTick.value;
                                  final has = _ctrl.timeCtrl.text.isNotEmpty;
                                  return _PickerTile(
                                    icon: Icons.access_time_rounded,
                                    text: has
                                        ? _ctrl.timeCtrl.text
                                        : 'event_field_time_hint'.tr,
                                    filled: has,
                                    onTap: () => _pickTime(context),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _label('event_field_location'.tr),
                      _Field(
                        controller: _ctrl.locationCtrl,
                        focusNode: _locationFocus,
                        hint: 'event_field_location_hint'.tr,
                        icon: Icons.location_on_rounded,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_priceFocus),
                      ),
                      SizedBox(height: 16.h),

                      _label('event_field_price'.tr),
                      _Field(
                        controller: _ctrl.priceCtrl,
                        focusNode: _priceFocus,
                        hint: 'event_field_price_hint'.tr,
                        icon: Icons.payments_rounded,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => FocusScope.of(context).unfocus(),
                      ),
                      SizedBox(height: 20.h),

                      _label('event_field_category'.tr),
                      Obx(() => Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children: EventCategory.values.map((cat) {
                              final selected =
                                  _ctrl.selectedCategory.value == cat;
                              return GestureDetector(
                                onTap: () => _ctrl.selectedCategory.value = cat,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 13.w, vertical: 9.h),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? cat.color
                                        : cat.color.withValues(alpha: 0.09),
                                    borderRadius: BorderRadius.circular(14.r),
                                    border: Border.all(
                                      color: selected
                                          ? cat.color
                                          : cat.color.withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(cat.icon,
                                          size: 15.sp,
                                          color: selected
                                              ? Colors.white
                                              : cat.color),
                                      SizedBox(width: 6.w),
                                      Text(
                                        cat.labelKey.tr,
                                        style: context.typography.displaySmBold
                                            .copyWith(
                                          fontSize: 12.5,
                                          color: selected
                                              ? Colors.white
                                              : cat.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          )),
                      const SizedBox(height: 26),

                      Obx(() => _SubmitButton(
                            loading: _ctrl.isLoading.value,
                            label: isEdit
                                ? 'event_save'.tr
                                : 'event_create_btn'.tr,
                            onTap: () => _submit(context),
                          )),
                      SizedBox(height: MediaQuery.of(context).padding.bottom + 4),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8, right: 2),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
      );

  Future<void> _pickDate(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final picked = await showAppDatePicker(
      context,
      initialDate: _ctrl.selectedDate.value ?? now,
      minimumDate: now.subtract(const Duration(days: 1)),
      maximumDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked != null) _ctrl.selectedDate.value = picked;
  }

  Future<void> _pickTime(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final picked = await showAppTimePicker(
      context,
      initialTime: TimeOfDay.now(),
      use24hFormat: false,
    );
    if (picked != null) {
      final isAr = Get.locale?.languageCode == 'ar';
      final h = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
      final m = picked.minute.toString().padLeft(2, '0');
      final suffix = picked.period == DayPeriod.am
          ? (isAr ? 'ص' : 'AM')
          : (isAr ? 'م' : 'PM');
      _ctrl.timeCtrl.text = '$h:$m $suffix';
      _ctrl.timeTick.value++;
    }
  }

  String _formatDate(DateTime d) {
    return localizeDigits('${d.day} ${monthName(d.month)}');
  }

  Future<void> _submit(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final ok = await _ctrl.submit();
    if (ok) {
      if (context.mounted) Navigator.of(context).pop();
      Loader.showSuccess(
        widget.editEvent != null ? 'event_updated'.tr : 'event_created'.tr,
      );
    } else {
      Loader.showError('event_error_save'.tr);
    }
  }
}

// ── Header ───────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.isEdit});
  final bool isEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: _line,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    _indigo.withValues(alpha: 0.12),
                    _violet.withValues(alpha: 0.12),
                  ]),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.celebration_rounded,
                    color: _indigo, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isEdit ? 'event_edit_title'.tr : 'event_create_title'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: _ink,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: _fieldBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded,
                      size: 19, color: _muted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Reusable filled field ────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.textInputAction,
    this.onSubmitted,
    this.keyboardType,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      style: const TextStyle(
          fontSize: 14, color: _ink, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13.5, color: _faint),
        filled: true,
        fillColor: _fieldBg,
        prefixIcon: Padding(
          padding: EdgeInsets.only(
            top: maxLines > 1 ? 0 : 0,
            bottom: maxLines > 1 ? (maxLines - 1) * 22 : 0,
          ),
          child: Icon(icon, size: 20, color: _faint),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _indigo, width: 1.6),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _line),
        ),
      ),
    );
  }
}

// ── Date/Time picker tile ────────────────────────────────────────────────────────

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.icon,
    required this.text,
    required this.filled,
    required this.onTap,
  });
  final IconData icon;
  final String text;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: _fieldBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _line),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: filled ? _indigo : _faint),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: filled ? _ink : _faint,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Submit button ────────────────────────────────────────────────────────────────

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.loading,
    required this.label,
    required this.onTap,
  });
  final bool loading;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_indigo, _violet]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _indigo.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.4),
              )
            : Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}

// ── Cover picker ─────────────────────────────────────────────────────────────────

class _CoverPicker extends StatelessWidget {
  const _CoverPicker({required this.ctrl});
  final CreateEventController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasNew = ctrl.coverImage.value != null;
      final hasExisting =
          ctrl.editEvent?.coverImage != null && !ctrl.removeCover.value;

      if (hasNew) {
        return _preview(
          child: Image.file(File(ctrl.coverImage.value!.path),
              fit: BoxFit.cover, width: double.infinity),
          onRemove: ctrl.clearCover,
        );
      }
      if (hasExisting) {
        return _preview(
          child: AppNetworkImage(
            url: ctrl.editEvent!.coverImage!,
            fit: BoxFit.cover,
            width: double.infinity,
          ),
          onRemove: ctrl.clearCover,
        );
      }
      return GestureDetector(
        onTap: ctrl.pickCover,
        child: Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: _indigo.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _indigo.withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _indigo.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.add_photo_alternate_rounded,
                    color: _indigo, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                'event_add_cover'.tr,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _indigo,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _preview({required Widget child, required VoidCallback onRemove}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 150,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            child,
            Positioned(
              top: 10,
              left: 10,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
