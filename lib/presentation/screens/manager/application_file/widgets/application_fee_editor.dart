import '../../../../../index/index_main.dart';

/// Application (file-opening) fee editor + the "free application" marketing
/// toggle. When free is on, the numeric field is disabled and the nursery is
/// shown as "🎁 Free Application" in Discovery. Controller-agnostic: drives a
/// plain [TextEditingController] + an [RxBool] so any screen can host it.
class ApplicationFeeEditor extends StatelessWidget {
  const ApplicationFeeEditor({
    super.key,
    required this.feeCtrl,
    required this.free,
  });

  final TextEditingController feeCtrl;
  final RxBool free;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isFree = free.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedOpacity(
            opacity: isFree ? 0.45 : 1,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: isFree,
              child: AppTextField(
                controller: feeCtrl,
                hintText: 'manager_profile_app_fee_hint'.tr,
                keyboardType: TextInputType.number,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          GestureDetector(
            onTap: () => free.value = !isFree,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isFree
                    ? AppColors.activityGreen.withValues(alpha: 0.10)
                    : AppColors.backgroundNeutral100,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isFree
                      ? AppColors.activityGreen.withValues(alpha: 0.5)
                      : AppColors.borderNeutralPrimary.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isFree ? Icons.check_circle_rounded : Icons.circle_outlined,
                    size: 20.sp,
                    color:
                        isFree ? AppColors.activityGreen : AppColors.grayMedium,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'manager_profile_app_fee_free'.tr,
                      style: context.typography.smMedium.copyWith(
                        color: isFree
                            ? AppColors.activityGreen
                            : AppColors.textPrimaryParagraph,
                        fontWeight: isFree ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                  Text('🎁',
                      style:
                          context.typography.mdRegular.copyWith(fontSize: 18)),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
