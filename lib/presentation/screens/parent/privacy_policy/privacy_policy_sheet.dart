import '../../../../index/index_main.dart';

/// Opens the (non-dismissible) privacy-policy sheet. The parent must tick the
/// consent checkbox and press accept; there is no other way to close it —
/// completion of this future therefore means the policy was accepted.
Future<void> showPrivacyPolicySheet(List<String> clauses) {
  return Get.bottomSheet(
    PopScope(
      canPop: false,
      child: PrivacyPolicySheet(clauses: clauses),
    ),
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
    ),
  );
}

/// First-open gate for the nursery's privacy policy. Shows the sheet once per
/// device for a parent who has never accepted it — only when the nursery
/// actually published a policy. Nothing to accept (empty policy) is a silent
/// no-op and leaves the marker unset, so a later-published policy still prompts.
class PrivacyPolicyPrompt {
  static bool _showing = false;

  static Future<void> maybeShow() async {
    if (_showing) return;
    if (!SessionService().isParent) return;

    final uid = SessionService().userId ?? '';
    if (uid.isEmpty || PrivacyPolicySeen.isSeen(uid)) return;

    final nurseryId = SessionService().nurseryId ?? '';
    if (nurseryId.isEmpty) return;

    final nursery = await Get.find<NurseryParentService>().getOne(nurseryId);
    final clauses = nursery?.privacyPolicy ?? const <String>[];
    if (clauses.isEmpty) return;

    if (_showing) return;
    _showing = true;
    await showPrivacyPolicySheet(clauses);
    // The sheet can only close via accept, so reaching here means consent.
    await PrivacyPolicySeen.markSeen(uid);
    _showing = false;
  }
}

class PrivacyPolicySheet extends StatefulWidget {
  final List<String> clauses;
  const PrivacyPolicySheet({super.key, required this.clauses});

  @override
  State<PrivacyPolicySheet> createState() => _PrivacyPolicySheetState();
}

class _PrivacyPolicySheetState extends State<PrivacyPolicySheet> {
  final _agreed = false.obs;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12.h),
            Center(
              child: Container(
                width: 44.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.privacy_tip_outlined,
                      color: AppColors.primary,
                      size: 30.sp,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    'privacy_policy_title'.tr,
                    style: context.typography.lgBold
                        .copyWith(color: AppColors.textDefault),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'privacy_policy_subtitle'.tr,
                    textAlign: TextAlign.center,
                    style: context.typography.smRegular.copyWith(
                      color: AppColors.textSecondaryParagraph,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 18.h),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 0.42.sh,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (int i = 0; i < widget.clauses.length; i++) ...[
                            _PolicyRow(
                              index: i + 1,
                              text: widget.clauses[i],
                            ),
                            if (i != widget.clauses.length - 1)
                              SizedBox(height: 8.h),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Obx(
                    () => InkWell(
                      onTap: () => _agreed.value = !_agreed.value,
                      borderRadius: BorderRadius.circular(10.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _agreed.value,
                              activeColor: AppColors.primary,
                              onChanged: (v) => _agreed.value = v ?? false,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                'privacy_policy_agree'.tr,
                                style: context.typography.smMedium
                                    .copyWith(color: AppColors.textDefault),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _agreed.value ? Get.back : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor:
                              AppColors.primary.withValues(alpha: 0.35),
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 15.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        child: Text(
                          'privacy_policy_accept'.tr,
                          style: context.typography.smSemiBold
                              .copyWith(color: Colors.white, fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicyRow extends StatelessWidget {
  const _PolicyRow({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grayLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(minWidth: 22.w),
            height: 22.w,
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: AppText(
              text: '$index',
              textStyle: context.typography.xsBold
                  .copyWith(color: AppColors.primary, fontSize: 11.sp),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: AppText(
              text: text,
              textStyle: context.typography.smRegular.copyWith(
                color: AppColors.textDefault,
                height: 1.6,
              ),
              maxLines: 20,
            ),
          ),
        ],
      ),
    );
  }
}
