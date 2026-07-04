import '../../../../../../index/index_main.dart';

/// Top strip: total guardians plus the invitation-funnel breakdown so the
/// receptionist sees at a glance how many still need an invitation.
class BulkInviteSummary extends StatelessWidget {
  final BulkInvitationsController controller;
  const BulkInviteSummary({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(18.w, 4.h, 18.w, 16.h),
      child: Obx(
        () => Row(
          children: [
            _Stat(
              value: controller.notSentCount,
              label: 'rc_bulk_invite_stat_pending'.tr,
              color: const Color(0xFF64748B),
            ),
            _divider(),
            _Stat(
              value: controller.sentCount,
              label: 'rc_bulk_invite_stat_sent'.tr,
              color: const Color(0xFFB45309),
            ),
            _divider(),
            _Stat(
              value: controller.activatedCount,
              label: 'rc_bulk_invite_stat_activated'.tr,
              color: const Color(0xFF16A34A),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
    width: 1,
    height: 34.h,
    color: const Color(0xFFEDF0F3),
  );
}

class _Stat extends StatelessWidget {
  final int value;
  final String label;
  final Color color;
  const _Stat({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: context.typography.xxlBold.copyWith(
              fontSize: 22,
              color: color,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: context.typography.xsRegular.copyWith(
              fontSize: 11.5,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
