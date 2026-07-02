import '../../../../../index/index_main.dart';
import '../../../../../Data/models/classroom_activity/classroom_activity_model.dart';
import 'timeline_item.dart';

class TimelineSection extends StatelessWidget {
  const TimelineSection({
    super.key,
    required this.activities,
    required this.onGoToActivities,
  });

  final List<ClassroomActivityModel> activities;
  final VoidCallback onGoToActivities;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: activities.asMap().entries.map((e) {
            final isLast = e.key == activities.length - 1;
            return TimelineItem(
              activity: e.value,
              isLast: isLast,
              onTap: onGoToActivities,
            );
          }).toList(),
        ),
      ),
    );
  }
}
