import '../../../../../index/index_main.dart';
import '../../../../../Data/models/nursery_event/nursery_event_model.dart';
import '../controller.dart';

class AnnouncementsSection extends StatelessWidget {
  const AnnouncementsSection({super.key, required this.controller});
  final ParentDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final event = controller.nextEvent.value;
      if (event == null) return const SizedBox.shrink();

      return Container(
        margin: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 16.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: event.category.color.withValues(alpha: 0.18),
              blurRadius: 14.r,
              offset: Offset(0.w, 5.h)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: _FeaturedEventBanner(event: event, controller: controller),
        ));
    });
  }
}

class _FeaturedEventBanner extends StatelessWidget {
  const _FeaturedEventBanner({required this.event, required this.controller});
  final NurseryEventModel event;
  final ParentDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final color = event.category.color;
    return GestureDetector(
      onTap: () => Get.toNamed(parentEventsView),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.80),
              Color.lerp(color, Colors.white, 0.30)!,
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          image: event.coverImage != null
              ? DecorationImage(
                  image: appCachedImageProvider(event.coverImage!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    color.withValues(alpha: 0.55),
                    BlendMode.multiply,
                  ),
                )
              : null,
        ),
        child: Stack(
          children: [
            Positioned(
              top: -30,
              left: -20,
              child: Container(
                width: 110.w,
                height: 110.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                )),
            ),
            Positioned(
              bottom: -24,
              right: 60,
              child: Container(
                width: 80.w,
                height: 80.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                )),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52.w,
                      height: 52.h,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      child: Icon(event.category.icon, color: Colors.white, size: 26.sp)),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'parent_next_event_label'.tr,
                            style: context.typography.xsMedium.copyWith(color: Colors.white.withValues(alpha: 0.8), fontSize: 11, letterSpacing: 0.3),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            event.title,
                            style: context.typography.lgBold.copyWith(color: Colors.white, fontSize: 19, height: 1.2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    _DateChip(dateStr: event.formattedDate),
                    const Spacer(),
                    _ActionButton(
                      label: 'event_details'.tr,
                      onTap: () => Get.toNamed(parentEventsView),
                    ),
                    SizedBox(width: 8.w),
                    Obx(() {
                      final attending = controller.isAttendingNextEvent.value;
                      return _ActionButton(
                        label: attending
                            ? 'event_attending'.tr
                            : 'event_confirm_attendance'.tr,
                        onTap: controller.toggleNextEventAttendance,
                        isPrimary: true,
                      );
                    }),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({required this.dateStr});
  final String dateStr;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today_rounded, size: 12.sp, color: Colors.white),
          SizedBox(width: 5.w),
          Text(
            dateStr,
            style: context.typography.smSemiBold.copyWith(color: Colors.white, fontSize: 12),
          ),
        ],
      ));
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: isPrimary
              ? Colors.white
              : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          label,
          style: context.typography.displaySmBold.copyWith(color: isPrimary
                ? const Color(0xFF1E293B)
                : Colors.white, fontSize: 12),
        )),
    );
  }
}
