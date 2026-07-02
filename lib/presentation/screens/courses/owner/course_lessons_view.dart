import '../../../../Data/models/nursery_course/nursery_course_model.dart';
import '../../../../index/index_main.dart';
import 'course_lessons_controller.dart';
import 'create_lesson_sheet.dart';

class CourseLessonsView extends StatefulWidget {
  const CourseLessonsView({super.key});

  @override
  State<CourseLessonsView> createState() => _CourseLessonsViewState();
}

class _CourseLessonsViewState extends State<CourseLessonsView> {
  late final CourseLessonsController controller;
  late final HandleKeyboardService _keyboardService;
  late final List<String> _keys;

  @override
  void initState() {
    super.initState();
    final course = Get.arguments as NurseryCourse;
    controller = Get.put(CourseLessonsController(course), tag: course.id);
    _keyboardService = HandleKeyboardService();
    _keys = _keyboardService.generateKeys('lessons', 5);
  }

  @override
  Widget build(BuildContext context) {
    final course = controller.course;
    final catColor = course.category.color;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        body: KeyboardActions(
          config: _keyboardService.buildConfig(context, _keys),
          disableScroll: true,
          child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── App bar ─────────────────────────────────────────────────────
            SliverAppBar(
              pinned: true,
              expandedHeight: 140.h,
              backgroundColor: catColor,
              foregroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 14.h),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.typography.mdBold.copyWith(color: Colors.white),
                    ),
                    Text(
                      course.category.label,
                      style: context.typography.xsMedium.copyWith(color: Colors.white.withOpacity(0.80)),
                    ),
                  ],
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [catColor, course.category.accentColor],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                  ),
                ),
              ),
            ),

            // ── Info strip ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Obx(() {
                final count = controller.lessons.length;
                final total = controller.lessons.fold<int>(0, (s, l) => s + l.durationMinutes);
                return Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  child: Row(
                    children: [
                      _InfoChip(
                        icon: Icons.play_lesson_rounded,
                        label: '$count درس',
                        color: catColor,
                      ),
                      SizedBox(width: 10.w),
                      if (total > 0)
                        _InfoChip(
                          icon: Icons.schedule_rounded,
                          label: _formatMinutes(total),
                          color: catColor,
                        ),
                      const Spacer(),
                      Text(
                        'اسحب للترتيب',
                        style: context.typography.xsRegular.copyWith(color: Colors.grey.shade500),
                      ),
                      SizedBox(width: 4.w),
                      Icon(Icons.drag_indicator_rounded, size: 14.sp, color: Colors.grey.shade400),
                    ],
                  ),
                );
              }),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 8.h)),

            // ── Lessons list ─────────────────────────────────────────────────
            Obx(() {
              if (controller.isLoading.value) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (controller.lessons.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(catColor: catColor),
                );
              }
              return SliverReorderableList(
                itemCount: controller.lessons.length,
                onReorder: controller.reorder,
                itemBuilder: (ctx, i) {
                  final lesson = controller.lessons[i];
                  return ReorderableDragStartListener(
                    key: ValueKey(lesson.id),
                    index: i,
                    child: _LessonTile(
                      lesson: lesson,
                      index: i,
                      catColor: catColor,
                      controller: controller,
                      keyboardService: _keyboardService,
                      keys: _keys,
                    ),
                  );
                },
              );
            }),

            SliverToBoxAdapter(child: SizedBox(height: 100.h)),
          ],
        ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => showCreateLessonSheet(
            context,
            controller: controller,
            keyboardService: _keyboardService,
            keys: _keys,
          ),
          backgroundColor: catColor,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text(
            'درس جديد',
            style: context.typography.mdBold.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  String _formatMinutes(int mins) {
    final h = mins ~/ 60;
    final m = mins % 60;
    if (h == 0) return '$m د';
    if (m == 0) return '$h س';
    return '$h س $m د';
  }
}

// ─── Lesson tile ──────────────────────────────────────────────────────────────

class _LessonTile extends StatelessWidget {
  const _LessonTile({
    required this.lesson,
    required this.index,
    required this.catColor,
    required this.controller,
    required this.keyboardService,
    required this.keys,
  });

  final CourseLesson lesson;
  final int index;
  final Color catColor;
  final CourseLessonsController controller;
  final HandleKeyboardService keyboardService;
  final List<String> keys;

  @override
  Widget build(BuildContext context) {
    final ct = lesson.contentType;
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.fromLTRB(14.w, 8.h, 10.w, 8.h),
        leading: Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: ct.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Center(
            child: Icon(ct.icon, color: ct.color, size: 20.sp),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: catColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                '${index + 1}',
                style: context.typography.xsMedium.copyWith(color: catColor),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                lesson.title,
                style: context.typography.smSemiBold,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: ct.color.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  ct.label,
                  style: context.typography.xsRegular.copyWith(color: ct.color),
                ),
              ),
              if (lesson.durationMinutes > 0) ...[
                SizedBox(width: 6.w),
                Icon(Icons.schedule_rounded, size: 11.sp, color: Colors.grey.shade400),
                SizedBox(width: 2.w),
                Text(
                  '${lesson.durationMinutes} د',
                  style: context.typography.xsRegular.copyWith(color: Colors.grey.shade500),
                ),
              ],
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit_outlined, size: 18.sp, color: Colors.grey.shade500),
              onPressed: () => showCreateLessonSheet(
                context,
                controller: controller,
                editing: lesson,
                keyboardService: keyboardService,
                keys: keys,
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, size: 18.sp, color: const Color(0xFFDC2626)),
              onPressed: () => _confirmDelete(context),
            ),
            Icon(Icons.drag_indicator_rounded, size: 20.sp, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حذف الدرس'),
          content: Text('هل تريد حذف "${lesson.title}"؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                controller.deleteLesson(lesson);
              },
              child: Text('حذف', style: context.typography.smRegular.copyWith(color: const Color(0xFFDC2626))),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Info chip ────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12.sp, color: color),
            SizedBox(width: 4.w),
            Text(label, style: context.typography.xsMedium.copyWith(color: color)),
          ],
        ),
      );
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.catColor});
  final Color catColor;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_outlined, size: 64.sp, color: catColor.withOpacity(0.3)),
          SizedBox(height: 12.h),
          Text(
            'لا توجد دروس بعد',
            style: context.typography.mdMedium.copyWith(color: Colors.grey.shade500),
          ),
          SizedBox(height: 6.h),
          Text(
            'اضغط على + لإضافة أول درس',
            style: context.typography.xsRegular.copyWith(color: Colors.grey.shade400),
          ),
        ],
      );
}
