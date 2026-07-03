import '../../../../../index/index_main.dart';

/// Visual mapping for a parent's onboarding-funnel status. Single source of
/// truth for the color/icon/label so the guardian screen, the invitation
/// screen, and the analytics summary all render the funnel identically.
({Color color, IconData icon, String label}) parentStatusStyle(
  ParentOnboardingStatus status,
) => switch (status) {
  ParentOnboardingStatus.activated => (
    color: const Color(0xFF16A34A),
    icon: Icons.verified_rounded,
    label: 'rc_invite_status_activated'.tr,
  ),
  ParentOnboardingStatus.sent => (
    color: const Color(0xFFB45309),
    icon: Icons.schedule_rounded,
    label: 'rc_invite_status_sent'.tr,
  ),
  ParentOnboardingStatus.notSent => (
    color: const Color(0xFF64748B),
    icon: Icons.mark_email_unread_outlined,
    label: 'rc_invite_status_not_sent'.tr,
  ),
};

class ParentStatusChip extends StatelessWidget {
  final ParentOnboardingStatus status;
  const ParentStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final s = parentStatusStyle(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: s.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(s.icon, size: 14.sp, color: s.color),
          SizedBox(width: 5.w),
          Text(
            s.label,
            style: context.typography.smSemiBold.copyWith(
              fontSize: 11.5,
              color: s.color,
            ),
          ),
        ],
      ),
    );
  }
}
