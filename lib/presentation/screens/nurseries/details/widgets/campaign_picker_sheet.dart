import '../../../../../index/index_main.dart';

/// Lets the SuperAdmin pick which KidTrack campaign a nursery runs. Only enabled
/// campaigns are selectable; the currently linked one is marked.
class CampaignPickerSheet extends StatelessWidget {
  final List<KidtrackFeedbackCampaignModel> campaigns;
  final String? currentId;
  final void Function(String campaignId) onPick;

  const CampaignPickerSheet({
    super.key,
    required this.campaigns,
    required this.currentId,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final selectable = campaigns.where((c) => c.enabled).toList();
    return Directionality(
      textDirection: appTextDirection,
      child: Container(
        constraints: BoxConstraints(maxHeight: 0.7.sh),
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            Text(
              'sa_feedback_pick_title'.tr,
              style: context.typography.lgBold
                  .copyWith(color: const Color(0xFF1E293B)),
            ),
            SizedBox(height: 16.h),
            if (selectable.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Center(
                  child: Text(
                    'sa_feedback_pick_empty'.tr,
                    style: context.typography.smRegular
                        .copyWith(color: const Color(0xFF94A3B8)),
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: selectable.length,
                  separatorBuilder: (_, _) => SizedBox(height: 8.h),
                  itemBuilder: (_, i) {
                    final c = selectable[i];
                    final selected = c.key == currentId;
                    return InkWell(
                      onTap: () {
                        Get.back();
                        onPick(c.key ?? '');
                      },
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary.withValues(alpha: 0.08)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                c.title,
                                style: context.typography.smSemiBold
                                    .copyWith(color: const Color(0xFF1E293B)),
                              ),
                            ),
                            if (selected)
                              Icon(Icons.check_circle,
                                  color: AppColors.primary, size: 20.sp),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
