import '../../../../../index/index_main.dart';
import 'classroom_overview_card.dart';
import 'classroom_states_sheet.dart';

class ClassroomsSection extends StatelessWidget {
  const ClassroomsSection({super.key, required this.controller});

  final TeacherHomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final classrooms = controller.myClassrooms;

      // Snapshot reactive maps inside Obx via Map.of() — this iterates the RxMap
      // entries, which registers each observable as a GetX dependency.
      // itemBuilder is called lazily (outside Obx scope), so reading RxMaps
      // there is invisible to GetX; using plain Map snapshots fixes that.
      final attentionCounts = Map<String, int>.of(
        controller.classroomAttentionCount,
      );
      final childCounts = Map<String, int>.of(controller.classroomChildCount);
      final actCounts = Map<String, int>.of(
        controller.classroomActivitiesCount,
      );
      final avgRatings = Map<String, double>.of(controller.classroomAvgRating);

      return SizedBox(
        height: 170,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemCount: classrooms.length,
          itemBuilder: (_, i) {
            final c = classrooms[i];
            final cId = c.key ?? '';
            return ClassroomOverviewCard(
              classroom: c,
              childCount: childCounts[cId] ?? 0,
              activityCount: actCounts[cId] ?? 0,
              avgRating: avgRatings[cId] ?? 0.0,
              attentionCount: attentionCounts[cId] ?? 0,
              onTap: () {
                controller.prepareClassroomStates(c);
                Get.bottomSheet(
                  const ClassroomStatesSheet(),
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                );
              },
            );
          },
        ),
      );
    });
  }
}
