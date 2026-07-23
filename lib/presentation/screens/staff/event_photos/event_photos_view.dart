import '../../../../index/index_main.dart';
import 'widgets/event_photos_header.dart';
import 'widgets/event_photos_grid.dart';
import 'widgets/add_photos_button.dart';

/// Shared staff screen for an event's photos: every staff member sees all
/// photos (approved + pending) and can add more. Reached from the staff events
/// list and from the receptionist events screen.
class EventPhotosView extends StatefulWidget {
  const EventPhotosView({super.key});

  @override
  State<EventPhotosView> createState() => _EventPhotosViewState();
}

class _EventPhotosViewState extends State<EventPhotosView> {
  late final EventPhotosController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<EventPhotosController>();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        appBar: HomeAppBar(title: 'event_photos_title'.tr),
        floatingActionButton: AddPhotosButton(controller: controller),
        body: Obx(() {
          final event = controller.event.value;
          if (event == null) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          return Column(
            children: [
              EventPhotosHeader(event: event),
              Expanded(
                child: EventPhotosGrid(controller: controller),
              ),
            ],
          );
        }),
      ),
    );
  }
}
