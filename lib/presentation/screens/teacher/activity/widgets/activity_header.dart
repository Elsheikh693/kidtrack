import '../../../../../index/index_main.dart';
import '../../../../../presentation/design_systems/design_constants/colors/app_colors.dart';
import 'activity_header_collapsed.dart';
import 'activity_header_expanded.dart';

class ActivityHeaderDelegate extends SliverPersistentHeaderDelegate {
  const ActivityHeaderDelegate({
    required this.activity,
    this.classroomName,
  });

  final ClassroomActivityModel activity;
  final String? classroomName;

  static const double _maxH = 148.0;
  static const double _minH = 70.0;

  @override
  double get maxExtent => _maxH;
  @override
  double get minExtent => _minH;

  @override
  bool shouldRebuild(covariant ActivityHeaderDelegate old) =>
      old.activity.key != activity.key ||
      old.activity.title != activity.title ||
      old.classroomName != classroomName;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = (shrinkOffset / (_maxH - _minH)).clamp(0.0, 1.0);
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.activityGreenDark, AppColors.activityGreen],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  AppColors.activityGreen.withValues(alpha: 0.3 * (1 - progress)),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: progress > 0.7
              ? ActivityHeaderCollapsed(activity: activity)
              : ActivityHeaderExpanded(
                  activity: activity,
                  classroomName: classroomName,
                ),
        ),
      ),
    );
  }
}
