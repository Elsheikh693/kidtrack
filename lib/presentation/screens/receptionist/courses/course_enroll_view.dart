import '../../../../index/index_main.dart';
import '../../../../Global/widgets/app_network_image.dart';
import '../../../../Data/models/nursery_course/nursery_course_model.dart';
import 'course_enroll_controller.dart';

class CourseEnrollView extends StatelessWidget {
  const CourseEnrollView({super.key, required this.course});

  final NurseryCourse course;

  @override
  Widget build(BuildContext context) {
    final c = Get.put(CourseEnrollController(course), tag: course.id);
    final accent = course.category.color;

    return Directionality(
      textDirection: TextDirection.rtl,
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
              Text('تسجيل الأطفال',
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
        body: Column(
          children: [
            // Search + enrolled counter
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: c.setSearch,
                      style: context.typography.smRegular
                          .copyWith(color: AppColors.textDefault),
                      decoration: InputDecoration(
                        hintText: 'ابحث عن طفل...',
                        hintStyle: context.typography.smRegular
                            .copyWith(color: AppColors.grayMedium),
                        prefixIcon: Icon(Icons.search_rounded,
                            color: AppColors.grayMedium, size: 20.sp),
                        filled: true,
                        fillColor: AppColors.white,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 14.w, vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide(color: AppColors.grayLight),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide(color: AppColors.grayLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide(color: accent),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Obx(() => Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.people_alt_rounded,
                                size: 15.sp, color: accent),
                            SizedBox(width: 5.w),
                            Text('${c.enrolledTotal}',
                                style: context.typography.smSemiBold
                                    .copyWith(color: accent)),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (c.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (c.children.isEmpty) {
                  return Center(
                    child: Text('لا يوجد أطفال',
                        style: context.typography.smRegular
                            .copyWith(color: AppColors.grayMedium)),
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
                  itemCount: c.children.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8.h),
                  itemBuilder: (_, i) {
                    final child = c.children[i];
                    return Obx(() {
                      final enrolled = c.isEnrolled(child.key ?? '');
                      return _ChildRow(
                        child: child,
                        enrolled: enrolled,
                        accent: accent,
                        onTap: () => c.toggle(child),
                      );
                    });
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChildRow extends StatelessWidget {
  const _ChildRow({
    required this.child,
    required this.enrolled,
    required this.accent,
    required this.onTap,
  });

  final ChildModel child;
  final bool enrolled;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: enrolled ? accent.withValues(alpha: 0.06) : AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: enrolled ? accent : AppColors.grayLight,
            width: enrolled ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22.r,
              backgroundColor: accent.withValues(alpha: 0.12),
              backgroundImage: child.hasImage
                  ? appCachedImageProvider(child.profileImage)
                  : null,
              child: child.hasImage
                  ? null
                  : Icon(Icons.child_care_rounded,
                      color: accent, size: 22.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                child.fullName,
                style: context.typography.smSemiBold
                    .copyWith(color: AppColors.textDefault),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                color: enrolled ? accent : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: enrolled ? accent : AppColors.grayLight,
                  width: 1.5,
                ),
              ),
              child: Icon(
                enrolled ? Icons.check_rounded : Icons.add_rounded,
                size: 17.sp,
                color: enrolled ? Colors.white : AppColors.grayMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
