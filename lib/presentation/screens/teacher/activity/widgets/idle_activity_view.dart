import '../../../../../index/index_main.dart';
import 'idle_classroom_section.dart';
import 'idle_progress_card.dart';
import 'idle_quick_actions_row.dart';
import 'idle_today_timeline.dart';
import 'start_activity_cta.dart';
import 'quick_homework_sheet.dart';

class IdleActivityView extends StatelessWidget {
  const IdleActivityView({
    super.key,
    required this.ctrl,
    required this.onStart,
  });

  final TeacherActivityController ctrl;
  final VoidCallback onStart;

  void _showQuickHomework(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuickHomeworkSheet(
        onSave: (title, desc) => ctrl.postQuickHomework(
          title: title,
          description: desc,
        ),
      ),
    );
  }

  void _goToReports() {
    Get.find<MainPageViewModel>().changePage(3);
  }

  void _goToLinkBook() {
    Get.find<MainPageViewModel>().changePage(2);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── AppBar ──────────────────────────────────────────────────────────
        TeacherClassicAppBar(title: 'teacher_tab_activities'.tr),

        // ── Classroom selector ───────────────────────────────────────────────
        SliverToBoxAdapter(child: IdleClassroomSection(ctrl: ctrl)),

        // ── Today progress + timeline + quick actions ────────────────────────
        Obx(() {
          final completed = ctrl.todayCompleted;
          final upcoming = ctrl.todayScheduleSlots;
          final totalActivities = completed.length + upcoming.length;

          return SliverList(
            delegate: SliverChildListDelegate([
              // Progress bar
              if (totalActivities > 0)
                IdleProgressCard(
                  completed: completed.length,
                  total: totalActivities,
                ),

              // Today's activities timeline
              IdleTodayTimeline(
                completed: completed,
                upcoming: upcoming,
                ctrl: ctrl,
                onStartSchedule: ctrl.startFromSchedule,
              ),


              const SizedBox(height: 14),
            ]),
          );
        }),

        // ── Start new activity CTA ───────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          sliver: SliverToBoxAdapter(child: StartActivityCta(onStart: onStart)),
        ),
      ],
    );
  }
}
