import '../../../../../index/index_main.dart';
import '../../children/parent_account/parent_status_chip.dart';

const _accent = Color(0xFF0891B2);

/// Home card summarising the parent-onboarding funnel: how many guardians have
/// activated the app, how many were invited but haven't logged in yet, and how
/// many were never invited. Numbers come from the dashboard controller, which
/// already loads every parent record.
class ParentActivationCard extends StatelessWidget {
  final ReceptionistDashboardController controller;
  const ParentActivationCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final total = controller.totalParents.value;
      return Container(
        padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(color: const Color(0xFFEEF0F4)),
          boxShadow: [
            BoxShadow(
              color: _accent.withValues(alpha: 0.06),
              blurRadius: 16.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34.w,
                  height: 34.h,
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.insights_rounded, color: _accent, size: 19.sp),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'rc_funnel_title'.tr,
                        style: context.typography.smSemiBold.copyWith(
                          color: const Color(0xFF111827),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'rc_funnel_scope'.trParams({'count': '$total'}),
                        style: context.typography.xsRegular.copyWith(
                          color: const Color(0xFF8A93A4),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                _cell(
                  context,
                  ParentOnboardingStatus.activated,
                  controller.parentsActivated.value,
                ),
                _divider(),
                _cell(
                  context,
                  ParentOnboardingStatus.sent,
                  controller.parentsAwaiting.value,
                ),
                _divider(),
                _cell(
                  context,
                  ParentOnboardingStatus.notSent,
                  controller.parentsNotSent.value,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _divider() => Container(
        width: 1,
        height: 40.h,
        color: const Color(0xFFEEF0F4),
        margin: EdgeInsets.symmetric(horizontal: 6.w),
      );

  Widget _cell(BuildContext context, ParentOnboardingStatus status, int count) {
    final s = parentStatusStyle(status);
    return Expanded(
      child: Column(
        children: [
          Icon(s.icon, size: 19.sp, color: s.color),
          SizedBox(height: 6.h),
          Text(
            '$count',
            style: context.typography.mdBold.copyWith(
              color: s.color,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            s.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.typography.xsMedium.copyWith(
              color: const Color(0xFF8A93A4),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
