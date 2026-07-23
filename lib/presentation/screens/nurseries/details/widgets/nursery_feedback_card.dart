import '../../../../../index/index_main.dart';

/// SuperAdmin control panel for a nursery's KidTrack app-rating campaign:
/// current campaign + status, live response stats, and actions.
class NurseryFeedbackCard extends StatelessWidget {
  final NurseryDetailsController controller;
  const NurseryFeedbackCard({super.key, required this.controller});

  static const _accent = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.feedback_rounded, color: _accent, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'sa_feedback_card_title'.tr,
                style: context.typography.displaySmBold
                    .copyWith(color: const Color(0xFF1E293B)),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Obx(() {
            if (controller.loadingFeedback.value) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            final campaign = controller.currentCampaign.value;
            if (campaign == null) return _empty(context);
            return _active(context, campaign);
          }),
        ],
      ),
    );
  }

  Widget _empty(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'sa_feedback_card_none'.tr,
          style: context.typography.smRegular
              .copyWith(color: const Color(0xFF94A3B8)),
        ),
        SizedBox(height: 14.h),
        ElevatedButton.icon(
          onPressed: controller.openCampaignPicker,
          icon: const Icon(Icons.add, color: Colors.white, size: 18),
          label: Text('sa_feedback_assign_btn'.tr,
              style: context.typography.smSemiBold.copyWith(
                color: Colors.white,
              )),
          style: ElevatedButton.styleFrom(
            backgroundColor: _accent,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r)),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _active(
      BuildContext context, KidtrackFeedbackCampaignModel campaign) {
    final stats = controller.feedbackStats.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                campaign.title,
                style: context.typography.smSemiBold
                    .copyWith(color: const Color(0xFF1E293B)),
              ),
            ),
            _statusBadge(context, campaign.enabled),
          ],
        ),
        SizedBox(height: 14.h),
        if (stats != null) _statsGrid(context, stats),
        SizedBox(height: 14.h),
        Row(
          children: [
            Expanded(
              child: _btn(context, 'sa_feedback_open_btn'.tr,
                  Icons.list_alt_rounded, _accent, controller.openResponses),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _btn(context, 'sa_feedback_remind_btn'.tr,
                  Icons.notifications_active_rounded,
                  const Color(0xFF6366F1), controller.sendReminders),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _btn(context, 'sa_feedback_change_btn'.tr,
                  Icons.swap_horiz_rounded, const Color(0xFF0EA5E9),
                  controller.openCampaignPicker),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _btn(context, 'sa_feedback_disable_btn'.tr,
                  Icons.block_rounded, const Color(0xFFDC2626),
                  controller.disableCampaign),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statsGrid(BuildContext context, KidtrackFeedbackStats s) {
    final rate = (s.responseRate * 100).toStringAsFixed(0);
    final avg = s.average.toStringAsFixed(1);
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: [
        _chip(context, 'sa_feedback_stat_parents'.tr, '${s.totalParents}'),
        _chip(context, 'sa_feedback_stat_answered'.tr, '${s.answered}'),
        _chip(context, 'sa_feedback_stat_waiting'.tr, '${s.waiting}'),
        _chip(context, 'sa_feedback_stat_rate'.tr, '$rate%'),
        _chip(context, 'sa_feedback_stat_avg'.tr, avg),
      ],
    );
  }

  Widget _chip(BuildContext context, String label, String value) {
    return Container(
      width: 96.w,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: context.typography.mdBold
                  .copyWith(color: const Color(0xFF1E293B))),
          SizedBox(height: 2.h),
          Text(label,
              style: context.typography.xsRegular
                  .copyWith(color: const Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  Widget _statusBadge(BuildContext context, bool on) {
    final color = on ? const Color(0xFF16A34A) : const Color(0xFF94A3B8);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        on ? 'sa_feedback_status_enabled'.tr : 'sa_feedback_status_disabled'.tr,
        style: context.typography.xsMedium.copyWith(color: color),
      ),
    );
  }

  Widget _btn(BuildContext context, String label, IconData icon, Color color,
      VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: color, size: 16.sp),
      label: Text(label,
          style: context.typography.xsMedium.copyWith(color: color)),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        side: BorderSide(color: color.withValues(alpha: 0.4)),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }
}
