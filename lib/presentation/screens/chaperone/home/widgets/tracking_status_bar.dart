import '../../../../../index/index_main.dart';

class TrackingStatusBar extends StatelessWidget {
  const TrackingStatusBar({super.key, required this.controller});
  final ChaperoneHomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final active = controller.isTracking.value;
      final color = active ? const Color(0xFF059669) : AppColors.textSecondaryParagraph;
      return Container(
        margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            _PulseDot(color: color, active: active),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    active
                        ? 'tracking_status_active'.tr
                        : 'tracking_status_idle'.tr,
                    style: context.typography.mdBold.copyWith(
                      fontSize: 14,
                      color: color,
                    ),
                  ),
                  if (active)
                    Text(
                      'tracking_location_sharing'.tr,
                      style: context.typography.smRegular.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondaryParagraph,
                      ),
                    ),
                ],
              ),
            ),
            Obx(() => GestureDetector(
                  onTap: active
                      ? controller.stopTracking
                      : controller.startTracking,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: active
                          ? const Color(0xFFDC2626)
                          : AppColors.primary,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      active
                          ? 'tracking_btn_stop'.tr
                          : 'tracking_btn_start'.tr,
                      style: context.typography.displaySmBold.copyWith(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )),
          ],
        ),
      );
    });
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot({required this.color, required this.active});
  final Color color;
  final bool active;

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    if (widget.active) _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        width: 12.w,
        height: 12.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color
              .withValues(alpha: widget.active ? 0.5 + _ctrl.value * 0.5 : 0.4),
        ),
      ),
    );
  }
}
