import '../../../../../index/index_main.dart';

class ChildPickupCard extends StatelessWidget {
  const ChildPickupCard({
    super.key,
    required this.child,
    required this.controller,
    required this.isTracking,
  });

  final BusChildEntry child;
  final ChaperoneHomeController controller;
  final bool isTracking;

  Color get _statusColor {
    switch (child.status) {
      case ChildBusStatus.pending:
        return const Color(0xFFD97706);
      case ChildBusStatus.onBus:
        return const Color(0xFF2563EB);
      case ChildBusStatus.delivered:
        return const Color(0xFF059669);
    }
  }

  IconData get _statusIcon {
    switch (child.status) {
      case ChildBusStatus.pending:
        return Icons.schedule_rounded;
      case ChildBusStatus.onBus:
        return Icons.directions_bus_rounded;
      case ChildBusStatus.delivered:
        return Icons.home_rounded;
    }
  }

  static String _fmtTime(int? ms) {
    if (ms == null) return '--:--';
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    final ap = d.hour >= 12 ? 'billing11_time_pm'.tr : 'billing11_time_am'.tr;
    return '$h:$m $ap';
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor;
    final delivered = child.status == ChildBusStatus.delivered;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // ── avatar ───────────────────────────────────────────────────
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24.r,
                    backgroundColor: color.withValues(alpha: 0.12),
                    backgroundImage: child.childImage != null
                        ? appCachedImageProvider(child.childImage!)
                        : null,
                    child: child.childImage == null
                        ? Icon(Icons.child_care_rounded, color: color, size: 22.sp)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16.w,
                      height: 16.h,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 1.5),
                      ),
                      child: Icon(_statusIcon, size: 9.sp, color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12.w),
              // ── name + status + times ────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.childName,
                      style: context.typography.smSemiBold
                          .copyWith(color: AppColors.textDefault),
                    ),
                    SizedBox(height: 3.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        child.status.label,
                        style: context.typography.smSemiBold.copyWith(
                          fontSize: 11,
                          color: color,
                        ),
                      ),
                    ),
                    if (child.pickedUpAt != null || child.deliveredAt != null)
                      Padding(
                        padding: EdgeInsets.only(top: 5.h),
                        child: Row(
                          children: [
                            if (child.pickedUpAt != null)
                              _TimeChip(
                                icon: Icons.directions_bus_rounded,
                                label: _fmtTime(child.pickedUpAt),
                                color: const Color(0xFF2563EB),
                              ),
                            if (child.deliveredAt != null) ...[
                              SizedBox(width: 8.w),
                              _TimeChip(
                                icon: Icons.check_circle_rounded,
                                label: _fmtTime(child.deliveredAt),
                                color: const Color(0xFF059669),
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              // ── quick actions: navigate + call ───────────────────────────
              if (child.hasLocation)
                _IconAction(
                  icon: Icons.navigation_rounded,
                  color: const Color(0xFF2563EB),
                  onTap: () => controller.openNavigation(child),
                ),
              if (child.parentPhone != null &&
                  child.parentPhone!.isNotEmpty) ...[
                SizedBox(width: 6.w),
                _IconAction(
                  icon: Icons.call_rounded,
                  color: const Color(0xFF059669),
                  onTap: () => controller.callParent(child),
                ),
              ],
            ],
          ),
          // ── status action buttons (only while tracking) ──────────────────
          if (isTracking && !delivered) ...[
            SizedBox(height: 12.h),
            _ActionButtons(child: child, controller: controller),
          ],
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13.sp, color: color),
        SizedBox(width: 3.w),
        Text(
          label,
          style: context.typography.smSemiBold.copyWith(
            fontSize: 11,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38.w,
        height: 38.h,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(icon, size: 19.sp, color: color),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.child, required this.controller});
  final BusChildEntry child;
  final ChaperoneHomeController controller;

  @override
  Widget build(BuildContext context) {
    final dir = controller.direction.value;
    return Row(
      children: [
        if (child.status == ChildBusStatus.pending) ...[
          Expanded(
            child: _ActionBtn(
              label: dir.pickupLabel,
              color: const Color(0xFF2563EB),
              onTap: () => controller.markChildOnBus(child),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _ActionBtn(
              label: 'tracking_btn_near'.tr,
              color: const Color(0xFFD97706),
              onTap: () => controller.notifyNearHouse(child),
              outline: true,
            ),
          ),
        ],
        if (child.status == ChildBusStatus.onBus)
          Expanded(
            child: _ActionBtn(
              label: dir.deliverLabel,
              color: const Color(0xFF059669),
              onTap: () => controller.markChildDelivered(child),
            ),
          ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.label,
    required this.color,
    required this.onTap,
    this.outline = false,
  });
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool outline;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: outline ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(10.r),
          border: outline ? Border.all(color: color, width: 1.5) : null,
        ),
        child: Text(
          label,
          style: context.typography.displaySmBold.copyWith(
            fontSize: 12,
            color: outline ? color : Colors.white,
          ),
        ),
      ),
    );
  }
}
