import '../../../../index/index_main.dart';
import '../../../../Data/models/nursery_course/nursery_course_model.dart';
import 'receptionist_courses_controller.dart';
import 'course_enroll_view.dart';
import 'course_sessions_view.dart';

class ReceptionistCoursesTab extends StatelessWidget {
  const ReceptionistCoursesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ReceptionistCoursesController());

    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: AppColors.backgroundNeutral100,
        appBar: HomeAppBar(
          title: 'reception_tab_courses'.tr,
          showFilterIcon: false,
          onSettingsTap: () => Get.toNamed(settingsView),
        ),
        body: Obx(() {
          if (c.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (c.courses.isEmpty) {
            return const _EmptyState();
          }
          return CustomScrollView(
            slivers: [
              if (c.availableCategories.length > 1)
                SliverToBoxAdapter(child: _CategoryBar(controller: c)),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                sliver: SliverList.separated(
                  itemCount: c.filtered.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (_, i) {
                    final course = c.filtered[i];
                    return _CourseCard(
                      course: course,
                      enrolledCount: c.enrolledCount(course.id),
                      onEnroll: () =>
                          Get.to(() => CourseEnrollView(course: course)),
                      onSessions: () =>
                          Get.to(() => CourseSessionsView(course: course)),
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ─── Category filter bar ──────────────────────────────────────────────────────

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({required this.controller});
  final ReceptionistCoursesController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.h,
      child: Obx(() {
        final cats = controller.availableCategories;
        final selected = controller.filterCat.value;
        return ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          children: [
            _CatChip(
              label: 'receptioni28_filter_all'.tr,
              color: AppColors.primary,
              selected: selected == null,
              onTap: () => controller.filterBy(null),
            ),
            ...cats.map((cat) => Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: _CatChip(
                    label: cat.label,
                    color: cat.color,
                    selected: selected == cat,
                    onTap: () => controller.filterBy(cat),
                  ),
                )),
          ],
        );
      }),
    );
  }
}

class _CatChip extends StatelessWidget {
  const _CatChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: selected ? color : AppColors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: selected ? color : AppColors.grayLight,
            ),
          ),
          child: Text(
            label,
            style: context.typography.xsMedium.copyWith(
              color: selected ? Colors.white : AppColors.textSecondaryParagraph,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Course card ──────────────────────────────────────────────────────────────

class _CourseCard extends StatelessWidget {
  const _CourseCard({
    required this.course,
    required this.enrolledCount,
    required this.onEnroll,
    required this.onSessions,
  });

  final NurseryCourse course;
  final int enrolledCount;
  final VoidCallback onEnroll;
  final VoidCallback onSessions;

  @override
  Widget build(BuildContext context) {
    final color = course.category.color;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              children: [
                Container(
                  width: 52.w,
                  height: 52.w,
                  decoration: BoxDecoration(
                    gradient: course.category.gradient,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(course.category.icon,
                      color: Colors.white, size: 26.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.typography.displaySmBold
                            .copyWith(color: AppColors.textDefault),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          _MetaPill(
                            icon: Icons.event_note_rounded,
                            label: 'receptioni28_sessions_count'
                                .trParams({'count': '${course.totalSessions}'}),
                            color: color,
                          ),
                          SizedBox(width: 6.w),
                          _MetaPill(
                            icon: Icons.people_alt_rounded,
                            label: 'receptioni28_children_count'
                                .trParams({'count': '$enrolledCount'}),
                            color: const Color(0xFF059669),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.grayLight.withValues(alpha: 0.5)),
          Row(
            children: [
              Expanded(
                child: _CardAction(
                  icon: Icons.group_add_rounded,
                  label: 'receptioni28_children'.tr,
                  color: const Color(0xFF059669),
                  onTap: onEnroll,
                ),
              ),
              Container(width: 1, height: 24.h, color: AppColors.grayLight.withValues(alpha: 0.5)),
              Expanded(
                child: _CardAction(
                  icon: Icons.how_to_reg_rounded,
                  label: 'receptioni28_attendance'.tr,
                  color: color,
                  onTap: onSessions,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: color),
          SizedBox(width: 4.w),
          Text(label,
              style: context.typography.xsMedium.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _CardAction extends StatelessWidget {
  const _CardAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 13.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17.sp, color: color),
            SizedBox(width: 6.w),
            Text(label,
                style: context.typography.smSemiBold.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.school_outlined, size: 64.sp, color: AppColors.grayLight),
        SizedBox(height: 12.h),
        Text(
          'receptioni28_no_courses'.tr,
          style: context.typography.mdBold
              .copyWith(color: AppColors.textSecondaryParagraph),
        ),
        SizedBox(height: 4.h),
        Text(
          'receptioni28_no_courses_hint'.tr,
          style: context.typography.xsRegular.copyWith(color: AppColors.grayMedium),
        ),
      ],
    );
  }
}
