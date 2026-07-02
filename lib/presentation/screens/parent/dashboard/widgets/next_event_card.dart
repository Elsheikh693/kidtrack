import '../../../../../index/index_main.dart';
import '../controller.dart';

class NextEventCard extends StatelessWidget {
  const NextEventCard({super.key, required this.controller});
  final ParentDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final event = controller.nextEvent.value;
      if (event == null) return const SizedBox.shrink();

      final color = event.category.color;

      return Container(
        margin: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 16.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.95), color.withValues(alpha: 0.75)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(20.r),
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
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 18.r,
              offset: Offset(0.w, 6.h)),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label + date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'parent_next_event_label'.tr,
                    style: context.typography.xsMedium.copyWith(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, color: Colors.white, size: 12.sp),
                        SizedBox(width: 4.w),
                        Text(
                          event.formattedDate,
                          style: context.typography.displaySmBold.copyWith(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    )),
                ],
              ),
              SizedBox(height: 6.h),

              // Event name
              Row(
                children: [
                  Icon(event.category.icon, color: Colors.white, size: 22.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      event.title,
                      style: context.typography.xlBold.copyWith(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              if (event.location != null) ...[
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, color: Colors.white70, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text(
                      event.location!,
                      style: context.typography.xsRegular.copyWith(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],

              SizedBox(height: 14.h),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.toNamed(parentEventsView),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white, width: 1.5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                      ),
                      child: Text(
                        'event_details'.tr,
                        style: context.typography.smSemiBold.copyWith(fontSize: 13),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Obx(() {
                      final attending = controller.isAttendingNextEvent.value;
                      return ElevatedButton.icon(
                        onPressed: controller.toggleNextEventAttendance,
                        icon: Icon(
                          attending ? Icons.check_circle_rounded : Icons.how_to_reg_rounded,
                          size: 16.sp,
                          color: attending ? const Color(0xFF059669) : color),
                        label: Text(
                          attending ? 'event_attending'.tr : 'event_confirm_attendance'.tr,
                          style: context.typography.displaySmBold.copyWith(color: attending ? const Color(0xFF059669) : color, fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: color,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
