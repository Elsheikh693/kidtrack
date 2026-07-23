import '../../../../../index/index_main.dart';

/// Bottom sheet shown when the manager approves an application. Lets them pick
/// the visit date + time, then confirms approval (which also prepares the
/// WhatsApp message to the guardian).
class ApproveAppointmentSheet extends StatefulWidget {
  final ValueChanged<DateTime> onConfirm;
  const ApproveAppointmentSheet({super.key, required this.onConfirm});

  @override
  State<ApproveAppointmentSheet> createState() =>
      _ApproveAppointmentSheetState();
}

class _ApproveAppointmentSheetState extends State<ApproveAppointmentSheet> {
  DateTime? _date;
  TimeOfDay? _time;

  String get _dateText => _date == null
      ? ''
      : '${_date!.year}/${_date!.month.toString().padLeft(2, '0')}/${_date!.day.toString().padLeft(2, '0')}';

  String get _timeText {
    final t = _time;
    if (t == null) return '';
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final period = t.period == DayPeriod.am ? 'apply_time_am'.tr : 'apply_time_pm'.tr;
    return '$h:${t.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w,
            18.h + MediaQuery.of(context).viewInsets.bottom),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: 'apply_appointment_title'.tr,
              textStyle: context.typography.mdBold
                  .copyWith(color: AppColors.textDefault),
            ),
            SizedBox(height: 4.h),
            AppText(
              text: 'apply_appointment_sub'.tr,
              textStyle: context.typography.xsRegular
                  .copyWith(color: AppColors.textSecondaryParagraph),
              maxLines: 2,
            ),
            SizedBox(height: 16.h),
            _pickerField(
              context,
              icon: Icons.calendar_today_rounded,
              label: 'apply_appointment_date'.tr,
              value: _dateText,
              onTap: _pickDate,
            ),
            SizedBox(height: 12.h),
            _pickerField(
              context,
              icon: Icons.access_time_rounded,
              label: 'apply_appointment_time'.tr,
              value: _timeText,
              onTap: _pickTime,
            ),
            SizedBox(height: 18.h),
            PrimaryTextButton(
              appButtonSize: AppButtonSize.xlarge,
              onTap: _confirm,
              label: AppText(
                text: 'apply_appointment_confirm'.tr,
                textStyle: context.typography.smSemiBold
                    .copyWith(color: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showAppDatePicker(
      context,
      initialDate: _date ?? now,
      minimumDate: DateTime(now.year, now.month, now.day),
      maximumDate: DateTime(now.year + 1, 12, 31),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showAppTimePicker(
      context,
      initialTime: _time ?? const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null) setState(() => _time = picked);
  }

  void _confirm() {
    if (_date == null) {
      Loader.showError('apply_appointment_date_required'.tr);
      return;
    }
    if (_time == null) {
      Loader.showError('apply_appointment_time_required'.tr);
      return;
    }
    final dt = DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _time!.hour,
      _time!.minute,
    );
    widget.onConfirm(dt);
  }

  Widget _pickerField(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final hasValue = value.isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasValue ? AppColors.primary : AppColors.grayLight,
            width: hasValue ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: AppColors.primary),
            SizedBox(width: 10.w),
            Expanded(
              child: AppText(
                text: hasValue ? value : label,
                textStyle: context.typography.smMedium.copyWith(
                  color: hasValue
                      ? AppColors.textDefault
                      : AppColors.textSecondaryParagraph,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 20.sp, color: AppColors.grayMedium),
          ],
        ),
      ),
    );
  }
}
