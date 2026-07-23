import '../../../../index/index_main.dart';

/// Manager/owner setting: whether teacher-uploaded photos (activities AND
/// "fun day" events) must be reviewed before guardians see them. ON (default) =
/// current review flow — photos pass through the manager first. OFF = photos go
/// straight to guardians the moment they're uploaded. Nursery-wide.
class ManagerPhotoApprovalSettingsView extends StatefulWidget {
  const ManagerPhotoApprovalSettingsView({super.key});

  @override
  State<ManagerPhotoApprovalSettingsView> createState() =>
      _ManagerPhotoApprovalSettingsViewState();
}

class _ManagerPhotoApprovalSettingsViewState
    extends State<ManagerPhotoApprovalSettingsView> {
  late final PhotoApprovalPolicyService _service;

  static const _accent = Color(0xFF0891B2);

  @override
  void initState() {
    super.initState();
    _service = Get.find<PhotoApprovalPolicyService>();
    _service.load(force: true);
  }

  Future<void> _toggle(bool value) async {
    final ok = await _service.setEnabled(value);
    if (!ok) Loader.showError('manager_photo_approval_save_error'.tr);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral100,
      appBar: OwnerAppBar(
        title: 'manager_photo_approval_title'.tr,
        onBack: () => Get.back(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        children: [
          Obx(() {
            final on = _service.needsApproval.value;
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
                          text: 'manager_photo_approval_toggle'.tr,
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
                    text: 'manager_photo_approval_hint'.tr,
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
