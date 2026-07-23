import '../../../../index/index_main.dart';

/// Owner setting: turn ON/OFF the cross-branch activity-photo review banner on
/// the owner's home dashboard. Default OFF. Managers keep their own per-branch
/// review regardless of this switch.
class OwnerPhotoReviewSettingsView extends StatefulWidget {
  const OwnerPhotoReviewSettingsView({super.key});

  @override
  State<OwnerPhotoReviewSettingsView> createState() =>
      _OwnerPhotoReviewSettingsViewState();
}

class _OwnerPhotoReviewSettingsViewState
    extends State<OwnerPhotoReviewSettingsView> {
  late final OwnerPhotoReviewService _service;

  static const _accent = Color(0xFF0891B2);

  @override
  void initState() {
    super.initState();
    _service = Get.find<OwnerPhotoReviewService>();
    _service.load(force: true);
  }

  Future<void> _toggle(bool value) async {
    final ok = await _service.setEnabled(value);
    if (!ok) Loader.showError('owner_photo_review_save_error'.tr);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral100,
      appBar: OwnerAppBar(
        title: 'owner_photo_review_title'.tr,
        onBack: () => Get.back(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        children: [
          Obx(() {
            final on = _service.enabled.value;
            return Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: on
                      ? _accent.withValues(alpha: 0.5)
                      : AppColors.borderNeutralPrimary.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        on
                            ? Icons.rate_review_rounded
                            : Icons.rate_review_outlined,
                        size: 20.sp,
                        color: on ? _accent : AppColors.grayMedium,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: AppText(
                          text: 'owner_photo_review_toggle'.tr,
                          textStyle: context.typography.smSemiBold
                              .copyWith(color: AppColors.textPrimaryParagraph),
                        ),
                      ),
                      Switch(
                        value: on,
                        activeThumbColor: _accent,
                        onChanged: _service.isSaving.value ? null : _toggle,
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  AppText(
                    text: 'owner_photo_review_hint'.tr,
                    textStyle: context.typography.xsRegular
                        .copyWith(color: AppColors.grayMedium),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
