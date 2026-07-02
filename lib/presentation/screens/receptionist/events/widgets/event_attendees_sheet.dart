import '../../../../../index/index_main.dart';
import '../../../../../Data/models/nursery_event/nursery_event_model.dart';
import '../../../../../Data/models/event_attendance/event_attendance_model.dart';
import '../events_controller.dart';

class EventAttendeesSheet extends StatelessWidget {
  const EventAttendeesSheet({
    super.key,
    required this.event,
    required this.controller,
  });

  final NurseryEventModel event;
  final ReceptionistEventsController controller;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Icons.people_rounded, color: Color(0xFF6366F1)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${'event_attendees_for'.tr} ${event.title}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: Get.back,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: Obx(() {
                final list = controller.attendees;
                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.people_outline_rounded, size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          'event_no_attendees'.tr,
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: list.length,
                  itemBuilder: (_, i) => _AttendeeRow(item: list[i], index: i + 1),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendeeRow extends StatelessWidget {
  const _AttendeeRow({required this.item, required this.index});
  final EventAttendanceModel item;
  final int index;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.12),
        child: Text(
          '$index',
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6366F1),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      title: Text(
        item.childName,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
      ),
      subtitle: Text(
        '${'event_attendee_parent'.tr}: ${item.parentName}',
        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
      ),
      trailing: const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 20),
    );
  }
}
