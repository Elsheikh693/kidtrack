import '../../../../index/index_main.dart';
import '../../../../Global/widgets/app_network_image.dart';
import '../../../../Data/models/nursery_course/nursery_course_model.dart';
import '../../../../Data/models/course_enrollment/course_enrollment_model.dart';
import 'course_sessions_controller.dart';

class CourseSessionsView extends StatelessWidget {
  const CourseSessionsView({super.key, required this.course});

  final NurseryCourse course;

  @override
  Widget build(BuildContext context) {
    final c = Get.put(CourseSessionsController(course), tag: course.id);
    final accent = course.category.color;

    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: AppColors.backgroundNeutral100,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('receptioni28_attendance_title'.tr,
                  style: context.typography.mdBold
                      .copyWith(color: AppColors.textDefault)),
              Text(course.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.xsRegular
                      .copyWith(color: AppColors.textSecondaryParagraph)),
            ],
          ),
        ),
        body: Obx(() {
          if (c.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (c.totalSessions == 0) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(32.w),
                child: Text(
                  'receptioni28_no_sessions_defined'.tr,
                  textAlign: TextAlign.center,
                  style: context.typography.smRegular
                      .copyWith(color: AppColors.grayMedium),
                ),
              ),
            );
          }
          if (c.enrolled.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(32.w),
                child: Text(
                  'receptioni28_no_enrolled_children'.tr,
                  textAlign: TextAlign.center,
                  style: context.typography.smRegular
                      .copyWith(color: AppColors.grayMedium),
                ),
              ),
            );
          }

          return Column(
            children: [
              _SessionSelector(controller: c, accent: accent),
              _SessionSummary(controller: c, accent: accent),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
                  itemCount: c.enrolled.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8.h),
                  itemBuilder: (_, i) {
                    final e = c.enrolled[i];
                    return _AttendanceTile(
                      controller: c,
                      enrollment: e,
                      accent: accent,
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

// ─── Session selector (1..N chips) ────────────────────────────────────────────

class _SessionSelector extends StatelessWidget {
  const _SessionSelector({required this.controller, required this.accent});
  final CourseSessionsController controller;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60.h,
      child: Obx(() {
        final selected = controller.selectedIndex.value;
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          itemCount: controller.totalSessions,
          itemBuilder: (_, i) {
            final index = i + 1;
            final isSel = index == selected;
            final present = controller.presentCountFor(index);
            return GestureDetector(
              onTap: () => controller.selectSession(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 46.w,
                margin: EdgeInsets.only(right: 8.w),
                decoration: BoxDecoration(
                  color: isSel ? accent : AppColors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: isSel ? accent : AppColors.grayLight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('$index',
                        style: context.typography.smSemiBold.copyWith(
                          color: isSel ? Colors.white : AppColors.textDefault,
                        )),
                    if (present > 0) ...[
                      SizedBox(height: 2.h),
                      Icon(Icons.check_circle_rounded,
                          size: 11.sp,
                          color: isSel ? Colors.white : const Color(0xFF059669)),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

// ─── Selected session summary ─────────────────────────────────────────────────

class _SessionSummary extends StatelessWidget {
  const _SessionSummary({required this.controller, required this.accent});
  final CourseSessionsController controller;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final total = controller.enrolled.length;
      final present = controller.presentCountSelected;
      return Container(
        margin: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [accent, course_accent(accent)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Icon(Icons.event_available_rounded,
                color: Colors.white, size: 22.sp),
            SizedBox(width: 10.w),
            Text(
                'receptioni28_session_number'.trParams(
                    {'index': '${controller.selectedIndex.value}'}),
                style: context.typography.mdBold.copyWith(color: Colors.white)),
            const Spacer(),
            Text(
                'receptioni28_present_ratio'
                    .trParams({'present': '$present', 'total': '$total'}),
                style: context.typography.smSemiBold
                    .copyWith(color: Colors.white)),
          ],
        ),
      );
    });
  }
}

Color course_accent(Color c) {
  final hsl = HSLColor.fromColor(c);
  return hsl.withLightness((hsl.lightness + 0.12).clamp(0.0, 1.0)).toColor();
}

// ─── Per-child attendance tile ────────────────────────────────────────────────

class _AttendanceTile extends StatelessWidget {
  const _AttendanceTile({
    required this.controller,
    required this.enrollment,
    required this.accent,
  });

  final CourseSessionsController controller;
  final CourseChildEnrollment enrollment;
  final Color accent;

  static const _green = Color(0xFF059669);
  static const _red = Color(0xFFDC2626);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final childId = enrollment.childId;
      final present = controller.isPresent(childId);
      final absent = controller.isAbsent(childId);
      final attended = controller.attendedCountForChild(childId);
      final total = controller.totalSessions;

      final tint = present
          ? _green
          : absent
              ? _red
              : null;

      return Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: tint == null
              ? AppColors.white
              : tint.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: tint == null
                ? AppColors.grayLight
                : tint.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22.r,
              backgroundColor: accent.withValues(alpha: 0.12),
              backgroundImage: (enrollment.childImage ?? '').isNotEmpty
                  ? appCachedImageProvider(enrollment.childImage)
                  : null,
              child: (enrollment.childImage ?? '').isNotEmpty
                  ? null
                  : Icon(Icons.child_care_rounded, color: accent, size: 22.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(enrollment.childName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.typography.smSemiBold
                          .copyWith(color: AppColors.textDefault)),
                  SizedBox(height: 3.h),
                  Text(
                      'receptioni28_attended_ratio'.trParams(
                          {'attended': '$attended', 'total': '$total'}),
                      style: context.typography.xsRegular
                          .copyWith(color: AppColors.grayMedium)),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            _Actions(
              controller: controller,
              childId: childId,
              present: present,
              absent: absent,
            ),
          ],
        ),
      );
    });
  }
}

// Explicit present / absent toggle. Tapping the active state again clears it.
class _Actions extends StatelessWidget {
  const _Actions({
    required this.controller,
    required this.childId,
    required this.present,
    required this.absent,
  });

  final CourseSessionsController controller;
  final String childId;
  final bool present;
  final bool absent;

  static const _green = Color(0xFF059669);
  static const _red = Color(0xFFDC2626);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TogglePill(
          label: 'receptioni28_present'.tr,
          icon: Icons.check_rounded,
          color: _green,
          selected: present,
          onTap: () =>
              present ? controller.undo(childId) : controller.checkIn(childId),
        ),
        SizedBox(width: 6.w),
        _TogglePill(
          label: 'receptioni28_absent'.tr,
          icon: Icons.close_rounded,
          color: _red,
          selected: absent,
          onTap: () =>
              absent ? controller.undo(childId) : controller.markAbsent(childId),
        ),
      ],
    );
  }
}

class _TogglePill extends StatelessWidget {
  const _TogglePill({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: selected ? color : color.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.sp, color: selected ? Colors.white : color),
            SizedBox(width: 4.w),
            Text(label,
                style: context.typography.xsMedium.copyWith(
                  color: selected ? Colors.white : color,
                )),
          ],
        ),
      ),
    );
  }
}
