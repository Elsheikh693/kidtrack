import '../../../../../index/index_main.dart';
import '../controller.dart';

const _ink2 = Color(0xFF374151);
const _line = Color(0xFFEDF0F4);
const _red = Color(0xFFDC2626);

/// Wrapping grid of the receptionist's most-used operational actions.
/// Check-in lives in its own prominent button above this.
///
/// Uses a plain [Wrap] (width derived from [MediaQuery]) instead of a
/// GridView/LayoutBuilder so it composes safely inside the dashboard's
/// CustomScrollView without reserving fixed height or breaking sliver layout.
class OpsQuickActions extends StatelessWidget {
  final ReceptionistDashboardController controller;
  const OpsQuickActions({super.key, required this.controller});

  static const double _spacing = 12;
  static const double _hPadding = 32; // 16 left + 16 right from the page padding

  @override
  Widget build(BuildContext context) {
    final tileWidth =
        (MediaQuery.of(context).size.width - _hPadding - _spacing) / 2;

    return Wrap(
      spacing: _spacing,
      runSpacing: _spacing,
      children: [
        SizedBox(
          width: tileWidth,
          child: Obx(() => _ActionCard(
                icon: Icons.directions_car_rounded,
                label: 'reception_action_pickup_requests'.tr,
                color: const Color(0xFF7C3AED),
                badge: controller.pendingPickupRequests.value > 0
                    ? '${controller.pendingPickupRequests.value}'
                    : null,
                onTap: () => Get.toNamed(pickupRequestsView),
              )),
        ),
        SizedBox(
          width: tileWidth,
          child: _ActionCard(
            icon: Icons.verified_user_rounded,
            label: 'reception_action_pickup_verify'.tr,
            color: const Color(0xFF16A34A),
            onTap: () => Get.toNamed(pickupVerificationView),
          ),
        ),
        SizedBox(
          width: tileWidth,
          child: _ActionCard(
            icon: Icons.person_add_alt_1_rounded,
            label: 'reception_action_enrollment'.tr,
            color: const Color(0xFF2563EB),
            onTap: () => Get.toNamed(enrollmentsView),
          ),
        ),
        SizedBox(
          width: tileWidth,
          child: _ActionCard(
            icon: Icons.celebration_rounded,
            label: 'reception_action_events'.tr,
            color: const Color(0xFFF59E0B),
            onTap: () => Get.toNamed(receptionistEventsView),
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String? badge;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: _line),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF111827).withValues(alpha: 0.04),
              blurRadius: 10.r,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: color, size: 21.sp),
                ),
                const Spacer(),
                if (badge != null)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: _red,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      badge!,
                      style: context.typography.displaySmBold.copyWith(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              label,
              style: context.typography.displaySmBold.copyWith(
                fontSize: 13.5,
                color: _ink2,
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
