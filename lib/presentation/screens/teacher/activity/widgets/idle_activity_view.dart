import '../../../../../index/index_main.dart';
import 'activity_empty_day.dart';
import 'classroom_tabs.dart';
import 'session_card.dart';

/// Idle state of the Activities tab: pick a classroom (pills) and start today's
/// scheduled sessions straight from their cards. Starting is schedule-driven.
class IdleActivityView extends StatelessWidget {
  const IdleActivityView({super.key, required this.ctrl});

  final TeacherActivityController ctrl;

  static String _hm(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        TeacherClassicAppBar(title: 'teacher_tab_activities'.tr),
        SliverToBoxAdapter(child: ClassroomTabs(ctrl: ctrl)),
        Obx(() {
          final classroomId = ctrl.selectedClassroomId.value;
          final completed = ctrl.todayCompleted.toList();
          final upcoming = ctrl.todayScheduleSlots.toList();
          final total = completed.length + upcoming.length;

          final Widget content = total == 0
              ? _empty(context, classroomId)
              : _list(context, classroomId, completed, upcoming);

          return SliverToBoxAdapter(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.05, 0),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: content,
            ),
          );
        }),
      ],
    );
  }

  Widget _empty(BuildContext context, String classroomId) {
    return SizedBox(
      key: ValueKey('empty_$classroomId'),
      height: 420.h,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 56.h, 24.w, 0),
        child: const Align(
          alignment: Alignment.topCenter,
          child: ActivityEmptyDay(),
        ),
      ),
    );
  }

  Widget _list(
    BuildContext context,
    String classroomId,
    List<ClassroomActivityModel> completed,
    List<ScheduleModel> upcoming,
  ) {
    return Column(
      key: ValueKey('list_$classroomId'),
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              'teacher_activity_today_list'.tr,
              style: context.typography.mdBold
                  .copyWith(color: AppColors.textDefault),
            ),
          ),
        ),
        for (final a in completed)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: SessionCard(
              startTime: _hm(a.startedAt),
              title: a.title,
              subtitle: a.subjectName,
              status: SessionStatus.done,
            ),
          ),
        for (var i = 0; i < upcoming.length; i++)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: SessionCard(
              startTime: upcoming[i].startTime,
              endTime: upcoming[i].endTime,
              title: ctrl.scheduleTitle(upcoming[i]),
              subtitle: _topicOf(upcoming[i]),
              status: i == 0 ? SessionStatus.now : SessionStatus.upcoming,
              onStart: i == 0 ? () => ctrl.startFromSchedule(upcoming[i]) : null,
            ),
          ),
        SizedBox(height: 100.h),
      ],
    );
  }

  String? _topicOf(ScheduleModel s) {
    final t = s.topic?.trim() ?? '';
    return t.isEmpty ? null : t;
  }
}
