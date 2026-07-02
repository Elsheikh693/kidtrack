import '../../../../../index/index_main.dart';
import 'active_activity_card.dart';
import 'no_activity_card.dart';

class ActiveActivitySection extends StatelessWidget {
  const ActiveActivitySection({
    super.key,
    required this.controller,
    required this.onGoToActivities,
  });

  final TeacherHomeController controller;
  final VoidCallback onGoToActivities;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final activity = controller.activeActivity.value;
      if (activity != null) {
        return ActiveActivityCard(
          activity: activity,
          totalChildren: controller.totalChildren.value,
          onTap: onGoToActivities,
        );
      }
      return NoActivityCard(
        onTap: onGoToActivities,
        activitiesDone: controller.todayActivitiesDone.value,
        activitiesTotal: controller.todayActivitiesTotal.value,
      );
    });
  }
}
