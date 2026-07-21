import '../../../../index/index_main.dart';
import 'widgets/current_activity_card.dart';
import 'widgets/teacher_notes_section.dart';
import 'widgets/education_shimmer.dart';
import 'widgets/day_hero_card.dart';
import 'widgets/journal_timeline_section.dart';
import 'widgets/journal_section_header.dart';
import 'widgets/homework_section.dart';
import 'widgets/journal_meta.dart';

class ParentEducationView extends StatefulWidget {
  const ParentEducationView({super.key});

  @override
  State<ParentEducationView> createState() => _ParentEducationViewState();
}

class _ParentEducationViewState extends State<ParentEducationView> {
  late final ParentEducationController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => ParentEducationController());
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const ParentTabScaffold(
          backgroundColor: kJBg,
          body: CustomScrollView(
            physics: NeverScrollableScrollPhysics(),
            slivers: [SliverToBoxAdapter(child: EducationShimmer())],
          ),
        );
      }

      final date = controller.selectedDate.value;
      final active = controller.activeActivity.value;
      final timeline = controller.timeline.toList();
      final notes = controller.teacherNotes.toList();
      final summary =
          controller.daySummary.value ??
          const DaySummary(
            activityCount: 0,
            homeworkTotal: 0,
            homeworkDone: 0,
            negativeNotes: 0,
            skills: [],
          );

      return ParentTabScaffold(
        backgroundColor: kJBg,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: _LinkBookEntry()),
            if (active != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: CurrentActivityCard(
                    activity: active,
                    allActivities: controller.todayActivities,
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: DayHeroCard(
                childName: controller.childName,
                summary: summary,
              ),
            ),
            SliverToBoxAdapter(
              child: JournalTimelineSection(items: timeline, enableNotes: true),
            ),
            const SliverToBoxAdapter(
              child: JournalSectionHeader(
                icon: Icons.assignment_rounded,
                label: 'الواجبات',
                color: Color(0xFF8E44AD),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: HomeworkSection(controller: controller),
              ),
            ),
            if (notes.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
                  child: TeacherNotesSection(notes: notes, date: date),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      );
    });
  }
}

/// Entry point to the full Link Book (all days) from the education tab.
class _LinkBookEntry extends StatelessWidget {
  const _LinkBookEntry();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: GestureDetector(
        onTap: () => Get.to(() => const LinkBookView()),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF6C4DDB).withValues(alpha: 0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C4DDB).withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C4DDB), Color(0xFF8B5CF6)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  color: Colors.white,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'دفتر التواصل',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: kJInk,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'تصفّح كل أيام طفلك في مكان واحد',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: kJMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: kJMuted),
            ],
          ),
        ),
      ),
    );
  }
}
