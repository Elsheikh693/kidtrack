import '../../../../index/index_main.dart';
import 'widgets/available_course_card.dart';
import 'widgets/enrolled_course_card.dart';
import 'widgets/courses_shimmer.dart';

const _kBg = Color(0xFFF4F4F8);
const _kInk = Color(0xFF0F172A);
const _kMuted = Color(0xFF64748B);
const _kBorder = Color(0xFFEEF0F4);

class ParentCoursesView extends StatefulWidget {
  const ParentCoursesView({super.key});

  @override
  State<ParentCoursesView> createState() => _ParentCoursesViewState();
}

class _ParentCoursesViewState extends State<ParentCoursesView> {
  late final ParentCoursesController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => ParentCoursesController());
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoading.value;

      if (isLoading) {
        return const ParentTabScaffold(
          backgroundColor: _kBg,
          body: CustomScrollView(
            physics: NeverScrollableScrollPhysics(),
            slivers: [SliverToBoxAdapter(child: CoursesShimmer())],
          ),
        );
      }

      final isAll = controller.activeTab.value == 0;

      return ParentTabScaffold(
        backgroundColor: _kBg,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Segmented tabs ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: _SegmentedTabs(
                activeTab: controller.activeTab.value,
                totalCount: controller.totalCount,
                enrolledCount: controller.enrolledCount,
                onTab: controller.switchTab,
              ),
            ),

            // ── Category chips (all tab only) ──────────────────────────
            if (isAll && controller.availableCategories.length > 1)
              SliverToBoxAdapter(
                child: _CategoryChips(
                  categories: controller.availableCategories,
                  selected: controller.selectedCategory.value,
                  onSelect: controller.selectCategory,
                ),
              ),

            // ── Content ────────────────────────────────────────────────
            if (isAll)
              _AvailableList(controller: controller)
            else
              _EnrolledList(controller: controller),

            const SliverToBoxAdapter(child: SizedBox(height: 110)),
          ],
        ),
      );
    });
  }
}

// ── Segmented tabs ────────────────────────────────────────────────────────────────

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({
    required this.activeTab,
    required this.totalCount,
    required this.enrolledCount,
    required this.onTab,
  });

  final int activeTab;
  final int totalCount;
  final int enrolledCount;
  final ValueChanged<int> onTab;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kBorder),
        ),
        child: Row(
          children: [
            _Segment(
              label: 'courses_tab_all'.tr,
              count: totalCount,
              active: activeTab == 0,
              onTap: () => onTab(0),
            ),
            _Segment(
              label: 'courses_tab_mine'.tr,
              count: enrolledCount,
              active: activeTab == 1,
              onTap: () => onTab(1),
            ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.28),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: active ? Colors.white : _kMuted,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                decoration: BoxDecoration(
                  color: active
                      ? Colors.white.withValues(alpha: 0.22)
                      : _kBorder,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: active ? Colors.white : _kMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Category chips ─────────────────────────────────────────────────────────────────

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  final List<CourseCategory> categories;
  final CourseCategory? selected;
  final ValueChanged<CourseCategory?> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
        physics: const BouncingScrollPhysics(),
        children: [
          _Chip(
            label: 'courses_filter_all'.tr,
            icon: Icons.apps_rounded,
            color: AppColors.primary,
            active: selected == null,
            onTap: () => onSelect(null),
          ),
          for (final c in categories)
            _Chip(
              label: c.label,
              icon: c.icon,
              color: c.color,
              active: selected == c,
              onTap: () => onSelect(c),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.icon,
    required this.color,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsetsDirectional.only(end: 8),
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          color: active ? color : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? color : _kBorder),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.26),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: active ? Colors.white : color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : _kInk,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Available list ────────────────────────────────────────────────────────────────

class _AvailableList extends StatelessWidget {
  const _AvailableList({required this.controller});

  final ParentCoursesController controller;

  @override
  Widget build(BuildContext context) {
    final courses = controller.filteredCourses;

    if (courses.isEmpty) {
      return const SliverToBoxAdapter(
        child: _EmptyState(
          icon: Icons.menu_book_rounded,
          title: 'courses_empty_available_title',
          subtitle: 'courses_empty_available_subtitle',
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, i) => StaggerItem(
          index: i,
          child: AvailableCourseCard(
            course: courses[i],
            isEnrolled: controller.isEnrolled(courses[i].id),
            progress: controller.progressFor(courses[i]),
            index: i,
          ),
        ),
        childCount: courses.length,
      ),
    );
  }
}

// ── Enrolled list ──────────────────────────────────────────────────────────────────

class _EnrolledList extends StatelessWidget {
  const _EnrolledList({required this.controller});

  final ParentCoursesController controller;

  @override
  Widget build(BuildContext context) {
    final enrolled = controller.enrolledCourses;

    if (enrolled.isEmpty) {
      return const SliverToBoxAdapter(
        child: _EmptyState(
          icon: Icons.school_rounded,
          title: 'courses_empty_enrolled_title',
          subtitle: 'courses_empty_enrolled_subtitle',
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((_, i) {
        final course = enrolled[i];
        return StaggerItem(
          index: i,
          child: EnrolledCourseCard(
            course: course,
            attended: controller.attendedCount(course.id),
            index: i,
          ),
        );
      }, childCount: enrolled.length),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 56, 40, 40),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.07),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 40,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title.tr,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _kInk,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle.tr,
            style: const TextStyle(fontSize: 13, height: 1.6, color: _kMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
