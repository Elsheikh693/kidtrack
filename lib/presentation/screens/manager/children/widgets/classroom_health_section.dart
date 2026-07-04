import '../../../../../index/index_main.dart';
import '../../widgets/manager_section_header.dart';
import 'classroom_health_card.dart';

/// The core of the Children tab: per-classroom occupancy + staffing, with the
/// classrooms that need attention sorted to the top.
class ClassroomHealthSection extends StatelessWidget {
  const ClassroomHealthSection({super.key, required this.controller});

  final ManagerChildrenController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rooms = controller.classHealth;
      final issues = rooms.where((r) => r.hasIssue).length;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ManagerSectionHeader(
            title: 'manager_children_classrooms_title'.tr,
            icon: Icons.meeting_room_rounded,
            color: AppColors.activityGreen,
            trailing: issues > 0 ? '$issues' : null,
          ),
          if (rooms.isEmpty)
            _EmptyClassrooms()
          else
            LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 12.0;
                final cardWidth = (constraints.maxWidth - spacing) / 2;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: rooms
                      .map((r) => SizedBox(
                            width: cardWidth,
                            child: ClassroomHealthCard(data: r),
                          ))
                      .toList(),
                );
              },
            ),
        ],
      );
    });
  }
}

class _EmptyClassrooms extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.meeting_room_outlined,
              size: 34, color: AppColors.grayMedium),
          const SizedBox(height: 10),
          Text(
            'manager_children_classrooms_empty'.tr,
            style: context.typography.smRegular
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
        ],
      ),
    );
  }
}
