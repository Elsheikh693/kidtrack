import '../../../../../index/index_main.dart';
import 'pickup_request_sheet.dart';

class PickupSection extends StatelessWidget {
  const PickupSection({super.key, required this.controller});
  final ParentDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 16.r,
              offset: Offset(0.w, 4.h)),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6.r,
              offset: Offset(0.w, 1.h)),
          ],
        ),
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0.h),
              child: Row(
                children: [
                  Container(
                    width: 32.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.directions_car_rounded,
                      color: AppColors.primary,
                      size: 18.sp)),
                  SizedBox(width: 10.w),
                  Text(
                    'الاستلام',
                    style: context.typography.smSemiBold
                        .copyWith(color: AppColors.textDefault),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.toNamed(parentPickupHistoryView),
                    child: Row(
                      children: [
                        Text(
                          'عرض الكل',
                          style: context.typography.xsMedium
                              .copyWith(color: AppColors.primary),
                        ),
                        SizedBox(width: 3.w),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 11.sp,
                          color: AppColors.primary),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Body (reactive) ──────────────────────────────────
            Obx(() {
              final requested = controller.pickupRequested.value;
              final eta = controller.pickupEta.value;
              final status = controller.pickupStatus.value;
              // reading childCurrentStatus triggers rebuild on any live status change
              final _ = controller.childCurrentStatus.value;
              final effective = controller.effectiveStatus;
              final childFirst = controller.childName.split(' ').first;

              if (requested) {
                return _ActivePickupBody(
                  eta: eta,
                  status: status,
                  childName: childFirst,
                  onCancel: controller.cancelPickup,
                );
              }

              if (!controller.isChildActive) {
                return _ChildUnavailableBody(effective: effective);
              }

              return _IdlePickupBody(
                controller: controller,
                childName: childFirst,
                checkInTime: controller.realCheckInTime,
                statusLabel: effective.label,
                statusColor: effective.color,
                statusIcon: effective.icon,
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ── Idle state ────────────────────────────────────────────────────────────────

class _IdlePickupBody extends StatelessWidget {
  const _IdlePickupBody({
    required this.controller,
    required this.childName,
    required this.checkInTime,
    required this.statusLabel,
    required this.statusColor,
    required this.statusIcon,
  });

  final ParentDashboardController controller;
  final String childName;
  final String checkInTime;
  final String statusLabel;
  final Color statusColor;
  final IconData statusIcon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      child: Column(
        children: [
          // ── Info row ──────────────────────────────────────────
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.backgroundNeutral100,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                _InfoChip(
                  icon: Icons.login_rounded,
                  label: 'دخل',
                  value: checkInTime,
                  color: const Color(0xFF059669),
                ),
                SizedBox(width: 12.w),
                Container(
                    width: 1.w,
                    height: 28.h,
                    color: AppColors.borderNeutralPrimary),
                SizedBox(width: 12.w),
                _InfoChip(
                  icon: statusIcon,
                  label: 'الحالة',
                  value: statusLabel,
                  color: statusColor,
                ),
                const Spacer(),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6.w,
                        height: 6.h,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        )),
                      SizedBox(width: 5.w),
                      Text(
                        'مباشر',
                        style: context.typography.smSemiBold.copyWith(color: statusColor, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // ── Action button ─────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => showPickupRequestSheet(context, controller),
              icon: Icon(Icons.directions_car_rounded, size: 18.sp),
              label: Text(
                'طلب استلام $childName',
                style: context.typography.displaySmBold.copyWith(fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 13.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Child not available for pickup ───────────────────────────────────────────

class _ChildUnavailableBody extends StatelessWidget {
  const _ChildUnavailableBody({required this.effective});
  final EffectiveChildStatus effective;

  @override
  Widget build(BuildContext context) {
    final isCheckedOut = effective.key == 'checked_out';
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: effective.color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: effective.color.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: effective.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(effective.icon, color: effective.color, size: 20.sp)),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    effective.label,
                    style: context.typography.displaySmBold.copyWith(color: effective.color, fontSize: 13),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    isCheckedOut
                        ? 'غادر الطفل الحضانة، لا يمكن طلب الاستلام'
                        : 'لم يصل الطفل بعد، لا يمكن طلب الاستلام الآن',
                    style: context.typography.xsRegular.copyWith(color: Color(0xFF94A3B8), fontSize: 11),
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

// ── Active pickup — status-aware ──────────────────────────────────────────────

class _ActivePickupBody extends StatelessWidget {
  const _ActivePickupBody({
    required this.eta,
    required this.status,
    required this.childName,
    required this.onCancel,
  });

  final String eta;
  final String status;
  final String childName;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      child: Column(
        children: [
          _StatusBanner(status: status, eta: eta, childName: childName),
          SizedBox(height: 10.h),
          GestureDetector(
            onTap: onCancel,
            child: Text(
              'إلغاء طلب الاستلام',
              style: context.typography.smSemiBold.copyWith(color: Color(0xFFDC2626), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status banner — changes as receptionist advances the flow ─────────────────

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.status,
    required this.eta,
    required this.childName,
  });

  final String status;
  final String eta;
  final String childName;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      'preparing' => _buildBanner(
          gradient: const [Color(0xFFF97316), Color(0xFFFB923C)],
          shadowColor: const Color(0xFFF97316),
          icon: Icons.backpack_rounded,
          title: 'جاري تحضير $childName',
          subtitle: 'سيكون جاهزاً في أقرب وقت',
        ),
      _ => _buildBanner(
          gradient: const [Color(0xFF059669), Color(0xFF10B981)],
          shadowColor: const Color(0xFF059669),
          icon: Icons.directions_car_rounded,
          title: 'في الطريق',
          subtitle: 'سأصل لاستلام $childName خلال $eta',
          trailing: _etaBadge(eta),
        ),
    };
  }

  Widget _buildBanner({
    required List<Color> gradient,
    required Color shadowColor,
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.25),
            blurRadius: 12.r,
            offset: Offset(0.w, 4.h)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.h,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 22.sp)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }

  Widget _etaBadge(String eta) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Text(
        eta,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ));
  }
}

// ── Info chip ─────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.sp, color: color),
        SizedBox(width: 5.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: context.typography.xsMedium.copyWith(color: Color(0xFF94A3B8), fontSize: 10),
            ),
            Text(
              value,
              style: context.typography.displaySmBold.copyWith(color: Color(0xFF1E293B), fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Pickup FAB ────────────────────────────────────────────────────────────────

class PickupFab extends StatelessWidget {
  const PickupFab({super.key, required this.controller});
  final ParentDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final requested = controller.pickupRequested.value;
      final status = controller.pickupStatus.value;
      final eta = controller.pickupEta.value;

      if (requested) {
        final (label, color) = switch (status) {
          'preparing' => ('جاري التحضير...', const Color(0xFFF97316)),
          _ => ('في الطريق • $eta', const Color(0xFF059669)),
        };

        return FloatingActionButton.extended(
          heroTag: 'pickup_fab',
          onPressed: () => _showCancelDialog(context),
          backgroundColor: color,
          icon: Icon(Icons.directions_car_rounded,
              color: Colors.white, size: 20.sp),
          label: Text(
            label,
            style: context.typography.displaySmBold.copyWith(color: Colors.white, fontSize: 13),
          ),
        );
      }

      return FloatingActionButton.extended(
        heroTag: 'pickup_fab',
        onPressed: () => showPickupRequestSheet(context, controller),
        backgroundColor: AppColors.primary,
        icon: Icon(Icons.directions_car_rounded,
            color: Colors.white, size: 20.sp),
        label: Text(
          'طلب استلام',
          style: context.typography.displaySmBold.copyWith(color: Colors.white, fontSize: 13),
        ),
      );
    });
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Text('إلغاء طلب الاستلام؟',
              style: context.typography.mdBold.copyWith(fontSize: 16)),
          content: Text('هل تريد إلغاء طلب الاستلام الحالي؟',
              style: context.typography.xsRegular.copyWith(fontSize: 13)),
          actions: [
            TextButton(
              onPressed: Get.back,
              child: Text('لا',
                  style: context.typography.smRegular.copyWith(color: AppColors.textSecondaryParagraph)),
            ),
            TextButton(
              onPressed: () {
                controller.cancelPickup();
                Get.back();
              },
              child: Text('نعم، إلغاء',
                  style: context.typography.displaySmBold.copyWith(color: Color(0xFFDC2626))),
            ),
          ],
        ),
      ),
    );
  }
}
