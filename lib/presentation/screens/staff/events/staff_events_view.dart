import '../../../../index/index_main.dart';
import 'widgets/staff_event_card.dart';

/// Staff-facing events list. Tapping an event opens its shared photos screen.
class StaffEventsView extends StatefulWidget {
  const StaffEventsView({super.key});

  @override
  State<StaffEventsView> createState() => _StaffEventsViewState();
}

class _StaffEventsViewState extends State<StaffEventsView> {
  late final StaffEventsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<StaffEventsController>();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        appBar: HomeAppBar(title: 'event_photos_events_title'.tr),
        body: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          final events = controller.events;
          if (events.isEmpty) return const _StaffEventsEmpty();
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 40.h),
            itemCount: events.length,
            itemBuilder: (_, i) => StaffEventCard(
              event: events[i],
              onTap: () => Get.toNamed(
                staffEventPhotosView,
                arguments: events[i],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _StaffEventsEmpty extends StatelessWidget {
  const _StaffEventsEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.celebration_outlined,
              size: 60.sp, color: Colors.grey.shade300),
          SizedBox(height: 14.h),
          Text(
            'event_empty'.tr,
            style: context.typography.smMedium
                .copyWith(color: AppColors.grayMedium),
          ),
        ],
      ),
    );
  }
}
