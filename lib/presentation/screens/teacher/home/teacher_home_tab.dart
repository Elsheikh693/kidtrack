import '../../../../index/index_main.dart';
import 'widgets/teacher_home_app_bar.dart';
import 'widgets/active_activity_section.dart';
import 'widgets/home_section_header.dart';
import 'widgets/class_card.dart';
import 'widgets/classroom_states_sheet.dart';

class TeacherHomeTab extends StatefulWidget {
  const TeacherHomeTab({super.key});

  @override
  State<TeacherHomeTab> createState() => _TeacherHomeTabState();
}

class _TeacherHomeTabState extends State<TeacherHomeTab> {
  late final TeacherHomeController controller;
  Worker? _pageWorker;

  @override
  void initState() {
    super.initState();
    controller = Get.find<TeacherHomeController>();
    // The home tab's State is recreated every time we return to it (pages are
    // swapped, not kept in an IndexedStack), but the fenix controller stays
    // alive — so onInit/_load won't re-run. Silently refresh today's data on
    // every return so actions done elsewhere (e.g. completing an activity)
    // show up without a hot reload. Skipped on the very first build, where
    // onInit's _load() is already running.
    if (!controller.isLoading.value) {
      controller.refreshTodaySummary();
    }
    final mainVm = Get.find<MainPageViewModel>();
    _pageWorker = ever(mainVm.currentIndex, (index) {
      if (index == 0) controller.refreshTodaySummary();
    });
  }

  @override
  void dispose() {
    _pageWorker?.dispose();
    super.dispose();
  }

  void _goToActivities() => Get.find<MainPageViewModel>().changePage(1);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refresh,
      color: AppColors.activityPurple,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          TeacherHomeAppBar(controller: controller),
          SliverToBoxAdapter(
            child: Obx(
              () => controller.isLoading.value
                  ? const _HomeSkeleton()
                  : _HomeBody(
                      controller: controller,
                      onGoToActivities: _goToActivities,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Animated body ─────────────────────────────────────────────────────────────

class _HomeBody extends StatefulWidget {
  const _HomeBody({required this.controller, required this.onGoToActivities});

  final TeacherHomeController controller;
  final VoidCallback onGoToActivities;

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  void _openClass(ClassroomModel c) {
    widget.controller.prepareClassroomStates(c);
    Get.bottomSheet(
      const ClassroomStatesSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // Active activity / start CTA
        _FadeSlideIn(
          delay: Duration.zero,
          child: ActiveActivitySection(
            controller: controller,
            onGoToActivities: widget.onGoToActivities,
          ),
        ),
        const SizedBox(height: 26),

        // My classes — the hero of the screen
        Obx(() {
          final classrooms = controller.myClassrooms;
          if (classrooms.isEmpty) return const _EmptyClasses();

          // Snapshot reactive maps inside Obx so each is registered as a
          // dependency (itemBuilder runs lazily, outside the Obx scope).
          final childCounts = Map<String, int>.of(
            controller.classroomChildCount,
          );
          final present = Map<String, int>.of(
            controller.classroomPresentCount,
          );
          final programs = Map<String, String>.of(
            controller.classroomProgramName,
          );
          final activityCounts = Map<String, int>.of(
            controller.classroomActivitiesCount,
          );
          controller.assignment.value; // register subject assignment

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeSectionHeader(
                label: 'teacher_home_my_classrooms'.tr,
                color: AppColors.activityPurple,
                badge: classrooms.length.toString(),
              ),
              const SizedBox(height: 14),
              for (int i = 0; i < classrooms.length; i++)
                _FadeSlideIn(
                  delay: Duration(milliseconds: 80 + i * 70),
                  child: ClassCard(
                    classroom: classrooms[i],
                    childCount: childCounts[classrooms[i].key ?? ''] ?? 0,
                    presentCount: present[classrooms[i].key ?? ''] ?? 0,
                    programName: programs[classrooms[i].key ?? ''] ?? '',
                    activitiesCount:
                        activityCounts[classrooms[i].key ?? ''] ?? 0,
                    onTap: () => _openClass(classrooms[i]),
                  ),
                ),
            ],
          );
        }),

        const SizedBox(height: 24),
      ],
    );
  }
}

// ── Empty state (no classes assigned) ─────────────────────────────────────────

class _EmptyClasses extends StatelessWidget {
  const _EmptyClasses();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 40),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.activityBlue.withValues(alpha: .08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.meeting_room_outlined,
              size: 40,
              color: AppColors.activityBlue,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'لم يتم تعيين فصول لك بعد',
            style: context.typography.mdBold.copyWith(
              color: AppColors.activitySlate,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'تواصلي مع مدير الحضانة لتعيين فصولك',
            textAlign: TextAlign.center,
            style: context.typography.xsRegular.copyWith(
              color: AppColors.activityMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Skeleton loader (shimmer) ─────────────────────────────────────────────────

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8EAF0),
      highlightColor: const Color(0xFFF8F9FC),
      period: const Duration(milliseconds: 1400),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active activity / CTA
            const _SkelBox(height: 92, radius: 22),
            const SizedBox(height: 26),

            // Section header
            const _SkelBox(width: 120, height: 18, radius: 6),
            const SizedBox(height: 16),

            // Big class cards
            ...List.generate(
              2,
              (i) => const Padding(
                padding: EdgeInsets.only(bottom: 14),
                child: _SkelBox(height: 168, radius: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkelBox extends StatelessWidget {
  const _SkelBox({this.width, required this.height, this.radius = 12});

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

// ── Reusable staggered fade + slide + scale entry ─────────────────────────────

class _FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _FadeSlideIn({required this.child, this.delay = Duration.zero});

  @override
  State<_FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<_FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    final curved = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.09),
      end: Offset.zero,
    ).animate(curved);
    _scale = Tween<double>(begin: 0.95, end: 1.0).animate(curved);
    Future.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _fade,
    child: SlideTransition(
      position: _slide,
      child: ScaleTransition(scale: _scale, child: widget.child),
    ),
  );
}
