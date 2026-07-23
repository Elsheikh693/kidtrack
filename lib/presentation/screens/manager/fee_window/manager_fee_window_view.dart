import '../../../../index/index_main.dart';
import 'widgets/fee_window_editor.dart';

/// Manager/owner setting: the monthly fee-collection window (day-of-month
/// from/to). Once the window passes, guardians who still owe this month's fees
/// get one polite automatic chat reminder (feeReminderScan Cloud Function).
/// Leaving both days unset keeps the reminder off.
class ManagerFeeWindowView extends StatefulWidget {
  const ManagerFeeWindowView({super.key});

  @override
  State<ManagerFeeWindowView> createState() => _ManagerFeeWindowViewState();
}

class _ManagerFeeWindowViewState extends State<ManagerFeeWindowView> {
  late final FeeCollectionWindowService _service;

  static const _accent = AppColors.activityGreen;

  @override
  void initState() {
    super.initState();
    _service = Get.find<FeeCollectionWindowService>();
    _service.load(force: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral100,
      appBar: OwnerAppBar(
        title: 'manager_profile_fee_window'.tr,
        onBack: () => Get.back(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: AppColors.borderNeutralPrimary.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.event_available_rounded,
                        size: 20.sp, color: _accent),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: AppText(
                        text: 'manager_profile_fee_window'.tr,
                        textStyle: context.typography.smSemiBold.copyWith(
                            color: AppColors.textPrimaryParagraph),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                AppText(
                  text: 'manager_profile_fee_window_hint'.tr,
                  textStyle: context.typography.xsRegular
                      .copyWith(color: AppColors.grayMedium),
                ),
                SizedBox(height: 16.h),
                FeeWindowEditor(service: _service),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
