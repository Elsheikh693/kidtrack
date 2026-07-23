import '../../../../../index/index_main.dart';
import '../controller.dart';

const _ink = Color(0xFF111827);
const _muted = Color(0xFF8A93A4);
const _amber = Color(0xFFF59E0B);
const _line = Color(0xFFEDF0F4);

/// Active / upcoming events surfaced on the receptionist Home (live data).
class ActiveEventsSection extends StatelessWidget {
  final ReceptionistDashboardController controller;
  const ActiveEventsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3.5.w,
              height: 17.h,
              decoration: BoxDecoration(
                color: _amber,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 9.w),
            Text(
              'reception_events_active_title'.tr,
              style: context.typography.mdBold.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _ink,
                letterSpacing: -0.2,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => Get.find<MainPageViewModel>().changePage(4),
              child: Icon(Icons.arrow_forward_ios_rounded,
                  size: 14.sp, color: _muted),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Obx(() {
          final events = controller.activeEvents;
          if (events.isEmpty) return _EmptyEvents();
          return Column(
            children: events
                .take(3)
                .map((e) => _EventTile(
                      event: e,
                      live: controller.isEventLive(e),
                    ))
                .toList(),
          );
        }),
      ],
    );
  }
}

class _EventTile extends StatelessWidget {
  final NurseryEventModel event;
  final bool live;
  const _EventTile({required this.event, required this.live});

  String get _timeLabel {
    final base = event.formattedDate;
    return event.timeStr != null && event.timeStr!.isNotEmpty
        ? '$base • ${event.timeStr}'
        : base;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.find<MainPageViewModel>().changePage(4),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.fromLTRB(14.w, 12.h, 12.w, 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _line),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF111827).withValues(alpha: 0.04),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: event.category.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(event.category.icon,
                  color: event.category.color, size: 21.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: context.typography.displaySmBold.copyWith(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: _ink,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded,
                          size: 13.sp, color: _muted),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          _timeLabel,
                          style: context.typography.xsMedium.copyWith(
                            fontSize: 12,
                            color: _muted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (live)
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _amber.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6.w,
                      height: 6.h,
                      decoration: const BoxDecoration(
                        color: _amber,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      'reception_events_live_badge'.tr,
                      style: context.typography.displaySmBold.copyWith(
                        color: _amber,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
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

class _EmptyEvents extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _line),
      ),
      child: Text(
        'reception_events_none'.tr,
        style: context.typography.xsMedium.copyWith(
          fontSize: 13,
          color: _muted,
        ),
      ),
    );
  }
}
