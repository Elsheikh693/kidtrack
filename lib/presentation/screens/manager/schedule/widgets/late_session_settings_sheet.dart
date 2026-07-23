import '../../../../../index/index_main.dart';

/// Manager control for the late-session grace window: master toggle + how many
/// minutes after a slot's start we nudge the teacher, then escalate to the
/// manager. Persisted via [LateSessionSettingsService].
class LateSessionSettingsSheet extends StatefulWidget {
  const LateSessionSettingsSheet({super.key});

  @override
  State<LateSessionSettingsSheet> createState() =>
      _LateSessionSettingsSheetState();
}

class _LateSessionSettingsSheetState extends State<LateSessionSettingsSheet> {
  late final LateSessionSettingsService _service;
  late bool _enabled;
  late int _grace;
  late int _escalate;

  static const _accent = AppColors.activityBlue;

  @override
  void initState() {
    super.initState();
    _service = Get.find<LateSessionSettingsService>();
    _enabled = _service.enabled.value;
    _grace = _service.graceMinutes.value;
    _escalate = _service.escalateMinutes.value;
  }

  Future<void> _save() async {
    final ok = await _service.save(
      enabled: _enabled,
      grace: _grace,
      escalate: _escalate,
    );
    if (!mounted) return;
    Get.back();
    if (ok) {
      Loader.showSuccess('schedule_save_success'.tr);
    } else {
      Loader.showError('schedule_save_error'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 28.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.borderNeutralPrimary,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text('late_session_settings_title'.tr,
              style:
                  context.typography.lgBold.copyWith(color: AppColors.textDefault)),
          SizedBox(height: 6.h),
          Text('late_session_settings_hint'.tr,
              style: context.typography.xsRegular
                  .copyWith(color: AppColors.textSecondaryParagraph)),
          SizedBox(height: 18.h),
          Row(
            children: [
              Expanded(
                child: Text('late_session_enabled'.tr,
                    style: context.typography.smSemiBold
                        .copyWith(color: AppColors.textDefault)),
              ),
              Switch(
                value: _enabled,
                activeTrackColor: _accent,
                onChanged: (v) => setState(() => _enabled = v),
              ),
            ],
          ),
          if (_enabled) ...[
            SizedBox(height: 8.h),
            _Stepper(
              label: 'late_session_grace_label'.tr,
              value: _grace,
              onChanged: (v) => setState(() => _grace = v),
            ),
            SizedBox(height: 12.h),
            _Stepper(
              label: 'late_session_escalate_label'.tr,
              value: _escalate,
              onChanged: (v) => setState(() => _escalate = v),
            ),
          ],
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            child: PrimaryTextButton(
              label: AppText(
                text: 'schedule_save'.tr,
                textStyle: context.typography.smSemiBold
                    .copyWith(color: AppColors.white),
              ),
              onTap: _save,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  static const _accent = AppColors.activityBlue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundNeutralDefault,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderNeutralPrimary),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: context.typography.smMedium
                    .copyWith(color: AppColors.textDefault)),
          ),
          _RoundBtn(
            icon: Icons.remove_rounded,
            onTap: () => onChanged((value - 5).clamp(1, 180)),
          ),
          SizedBox(width: 12.w),
          SizedBox(
            width: 58.w,
            child: Text(
              '$value ${'schedule_min'.tr}',
              textAlign: TextAlign.center,
              style: context.typography.smSemiBold.copyWith(color: _accent),
            ),
          ),
          SizedBox(width: 12.w),
          _RoundBtn(
            icon: Icons.add_rounded,
            onTap: () => onChanged((value + 5).clamp(1, 180)),
          ),
        ],
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  const _RoundBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32.w,
        height: 32.w,
        decoration: BoxDecoration(
          color: AppColors.activityBlue.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18.sp, color: AppColors.activityBlue),
      ),
    );
  }
}
