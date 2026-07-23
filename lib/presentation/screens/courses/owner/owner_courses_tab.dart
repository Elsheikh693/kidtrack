import '../../../../Data/models/nursery_course/nursery_course_model.dart';
import '../../../../index/index_main.dart';
import '../../../../Global/widgets/stagger_item.dart';
import 'owner_courses_controller.dart';
import 'create_course_sheet.dart';

class OwnerCoursesTab extends StatefulWidget {
  const OwnerCoursesTab({super.key});

  @override
  State<OwnerCoursesTab> createState() => _OwnerCoursesTabState();
}

class _OwnerCoursesTabState extends State<OwnerCoursesTab> {
  late final OwnerCoursesController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(OwnerCoursesController(), tag: 'ownerCourses');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        body: Obx(() {
          final loading = controller.isLoading.value;
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _CoursesHeader(controller: controller),
              if (loading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (controller.filtered.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(),
                )
              else
                _CoursesList(controller: controller),
              SliverToBoxAdapter(child: SizedBox(height: 100.h)),
            ],
          );
        }),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => showCreateCourseSheet(
            context,
            controller: controller,
          ),
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text(
            'coursesown13_new_course'.tr,
            style: context.typography.smSemiBold.copyWith(color: Colors.white),
          ),
        ),
      );
  }
}

// ─── World-class hero header ───────────────────────────────────────────────────

class _CoursesHeader extends StatelessWidget {
  const _CoursesHeader({required this.controller});
  final OwnerCoursesController controller;

  static const _teal = Color(0xFF0891B2);
  static const _tealDark = Color(0xFF0E7490);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_tealDark, _teal],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28.r)),
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -30.h,
              left: -20.w,
              child: Container(
                width: 120.w,
                height: 120.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              bottom: -40.h,
              right: 30.w,
              child: Container(
                width: 100.w,
                height: 100.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: back + icon + title + actions
                    Row(
                      children: [
                        if (Navigator.canPop(context)) ...[
                          _HeaderIconButton(
                            icon: Icons.arrow_back_ios_new_rounded,
                            onTap: () => Get.back(),
                          ),
                          SizedBox(width: 10.w),
                        ],
                        Container(
                          width: 44.w,
                          height: 44.h,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Icon(Icons.play_lesson_rounded,
                              color: Colors.white, size: 24.sp),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'coursesown13_courses_title'.tr,
                                style: context.typography.xlBold
                                    .copyWith(color: Colors.white),
                              ),
                              Text(
                                'coursesown13_courses_subtitle'.tr,
                                style: context.typography.xsRegular.copyWith(
                                    color: Colors.white.withOpacity(0.85)),
                              ),
                            ],
                          ),
                        ),
                        // Settings + notifications only when this is the root
                        // screen (e.g. parent's main tab); hidden when opened
                        // from within the owner dashboard (has a back button).
                        if (!Navigator.canPop(context)) ...[
                          _HeaderIconButton(
                            icon: Icons.notifications_none_rounded,
                            onTap: () => Get.toNamed(notificationsView),
                          ),
                          SizedBox(width: 8.w),
                          _HeaderIconButton(
                            icon: Icons.settings_outlined,
                            onTap: () => Get.toNamed(settingsView),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 18.h),
                    // Stats row
                    Obx(() {
                      final total = controller.courses.length;
                      final active =
                          controller.courses.where((c) => c.isActive).length;
                      final lessons = controller.courses
                          .fold<int>(0, (s, c) => s + c.lessonCount);
                      return Row(
                        children: [
                          _StatCard(
                            value: '$total',
                            label: 'coursesown13_stat_total'.tr,
                            icon: Icons.layers_rounded,
                          ),
                          SizedBox(width: 10.w),
                          _StatCard(
                            value: '$active',
                            label: 'coursesown13_available'.tr,
                            icon: Icons.lock_open_rounded,
                          ),
                          SizedBox(width: 10.w),
                          _StatCard(
                            value: '$lessons',
                            label: 'coursesown13_stat_lessons'.tr,
                            icon: Icons.menu_book_rounded,
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(icon, color: Colors.white, size: 20.sp),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
  });
  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.14),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withOpacity(0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.9), size: 18.sp),
            SizedBox(height: 8.h),
            Text(
              value,
              style: context.typography.lgBold.copyWith(color: Colors.white),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.typography.xsRegular
                  .copyWith(color: Colors.white.withOpacity(0.85)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Courses list ─────────────────────────────────────────────────────────────

class _CoursesList extends StatelessWidget {
  const _CoursesList({required this.controller});
  final OwnerCoursesController controller;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, i) {
          final course = controller.filtered[i];
          return StaggerItem(
            index: i,
            child: _OwnerCourseCard(
              course: course,
              controller: controller,
            ),
          );
        },
        childCount: controller.filtered.length,
      ),
    );
  }
}

// ─── Owner course card ────────────────────────────────────────────────────────

class _OwnerCourseCard extends StatelessWidget {
  const _OwnerCourseCard({
    required this.course,
    required this.controller,
  });

  final NurseryCourse course;
  final OwnerCoursesController controller;

  @override
  Widget build(BuildContext context) {
    final catColor    = course.category.color;
    final accentColor = course.category.accentColor;

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: catColor.withOpacity(0.08),
            blurRadius: 16.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Gradient header ──────────────────────────────────────────────
          _CardHeader(
            course: course,
            catColor: catColor,
            accentColor: accentColor,
            controller: controller,
          ),

          // ── Body ─────────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (course.description.isNotEmpty)
                  Text(
                    course.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.typography.xsRegular.copyWith(height: 1.5, color: Colors.grey.shade600),
                  ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    _Chip(
                      icon: Icons.play_lesson_rounded,
                      label: '${course.lessonCount} ${'coursesown13_lessons_suffix'.tr}',
                      color: catColor,
                    ),
                    SizedBox(width: 6.w),
                    if (course.totalMinutes > 0)
                      _Chip(
                        icon: Icons.schedule_rounded,
                        label: course.formattedDuration,
                        color: catColor,
                      ),
                    SizedBox(width: 6.w),
                    if (course.ageGroup.isNotEmpty)
                      _Chip(
                        icon: Icons.child_care_rounded,
                        label: '${course.ageGroup} ${'coursesown13_years_suffix'.tr}',
                        color: catColor,
                      ),
                  ],
                ),
                SizedBox(height: 8.h),
                _Chip(
                  icon: course.isAllBranches
                      ? Icons.public_rounded
                      : Icons.account_balance_rounded,
                  label: controller.branchScopeLabel(course),
                  color: const Color(0xFF6366F1),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    // Manage lessons button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Get.toNamed(
                          courseLessonsView,
                          arguments: course,
                        ),
                        icon: Icon(Icons.menu_book_rounded, size: 14.sp, color: catColor),
                        label: Text(
                          'coursesown13_manage_lessons'.tr,
                          style: context.typography.xsMedium.copyWith(color: catColor),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: catColor.withOpacity(0.4)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    // Active toggle
                    GestureDetector(
                      onTap: () => controller.toggleActive(course),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: course.isActive
                              ? const Color(0xFF059669).withOpacity(0.1)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: course.isActive
                                ? const Color(0xFF059669).withOpacity(0.4)
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              course.isActive
                                  ? Icons.lock_open_rounded
                                  : Icons.lock_rounded,
                              size: 14.sp,
                              color: course.isActive
                                  ? const Color(0xFF059669)
                                  : Colors.grey.shade500,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              course.isActive ? 'coursesown13_available'.tr : 'coursesown13_closed'.tr,
                              style: context.typography.xsMedium.copyWith(
                                color: course.isActive ? const Color(0xFF059669) : Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.course,
    required this.catColor,
    required this.accentColor,
    required this.controller,
  });

  final NurseryCourse course;
  final Color catColor;
  final Color accentColor;
  final OwnerCoursesController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150.h,
      decoration: BoxDecoration(
        gradient: course.coverUrl != null
            ? null
            : LinearGradient(
                colors: [catColor, accentColor],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
        image: course.coverUrl != null
            ? DecorationImage(
                image: appCachedImageProvider(course.coverUrl!),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.35),
                  BlendMode.darken,
                ),
              )
            : null,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(14.w, 10.h, 10.w, 10.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon circle
            Container(
              width: 46.w,
              height: 46.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.20),
              ),
              child: Icon(course.category.icon, color: Colors.white, size: 22.sp),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    course.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.typography.displaySmBold.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(width: 6.w),
            // Price + menu
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: course.isFree ? Colors.white.withValues(alpha: 0.20) : Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    course.priceLabel,
                    style: context.typography.xsMedium.copyWith(color: course.isFree ? Colors.white : catColor),
                  ),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  icon: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.20),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.more_horiz_rounded, color: Colors.white, size: 18.sp),
                  ),
                  onSelected: (val) {
                    if (val == 'edit') {
                      showCreateCourseSheet(
                        context,
                        controller: controller,
                        editing: course,
                      );
                    } else if (val == 'delete') {
                      _confirmDelete(context);
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 16.sp),
                          SizedBox(width: 8.w),
                          Text('coursesown13_edit'.tr),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, size: 16.sp, color: const Color(0xFFDC2626)),
                          SizedBox(width: 8.w),
                          Text('coursesown13_delete'.tr, style: context.typography.smRegular.copyWith(color: const Color(0xFFDC2626))),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: appTextDirection,
        child: AlertDialog(
          title: Text('coursesown13_delete_course_title'.tr),
          content: Text('coursesown13_delete_course_confirm'.trParams({'title': course.title})),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('coursesown13_cancel'.tr),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                controller.deleteCourse(course);
              },
              child: Text('coursesown13_delete'.tr, style: context.typography.smRegular.copyWith(color: const Color(0xFFDC2626))),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Chip ─────────────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11.sp, color: color),
            SizedBox(width: 3.w),
            Text(label, style: context.typography.xsRegular.copyWith(color: color)),
          ],
        ),
      );
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 64.sp, color: Colors.grey.shade300),
          SizedBox(height: 12.h),
          Text(
            'coursesown13_no_courses_title'.tr,
            style: context.typography.mdMedium.copyWith(color: Colors.grey.shade500),
          ),
          SizedBox(height: 6.h),
          Text(
            'coursesown13_no_courses_hint'.tr,
            style: context.typography.xsRegular.copyWith(color: Colors.grey.shade400),
          ),
        ],
      );
}
