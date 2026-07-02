import 'dart:async';
import '../../../../../index/index_main.dart';
import '../../../../../Data/models/nursery_course/nursery_course_model.dart';
import '../../../../../Global/services/course_service.dart';
import '../../../courses/parent/lesson_viewer_view.dart';

// ── Entry point ───────────────────────────────────────────────────────────────

void showCourseDetail(
  BuildContext context,
  NurseryCourse course, {
  CourseEnrollment? enrollment,
  void Function(String lessonId)? onLessonCompleted,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    // Slower, more dramatic rise; snappy close.
    sheetAnimationStyle: AnimationStyle(
      duration: const Duration(milliseconds: 560),
      reverseDuration: const Duration(milliseconds: 280),
    ),
    builder: (_) => CourseDetailSheet(
      course: course,
      enrollment: enrollment,
      onLessonCompleted: onLessonCompleted,
    ),
  );
}

// ── Main sheet ────────────────────────────────────────────────────────────────

class CourseDetailSheet extends StatefulWidget {
  const CourseDetailSheet({
    super.key,
    required this.course,
    this.enrollment,
    this.onLessonCompleted,
  });

  final NurseryCourse course;
  final CourseEnrollment? enrollment;
  final void Function(String lessonId)? onLessonCompleted;

  @override
  State<CourseDetailSheet> createState() => _CourseDetailSheetState();
}

class _CourseDetailSheetState extends State<CourseDetailSheet>
    with SingleTickerProviderStateMixin {
  final _service = CourseService();
  List<CourseLesson> _lessons = [];
  bool _loading = true;
  StreamSubscription? _sub;
  late CourseEnrollment? _enrollment;

  late final AnimationController _entrance;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _enrollment = widget.enrollment;

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 640),
    );
    // Springy scale snap (overshoots past 1.0 then settles) → the "pull" feel.
    _scale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _entrance, curve: Curves.easeOutBack),
    );
    _fade = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0, 0.45, curve: Curves.easeOut),
    );
    _entrance.forward();

    _sub = _service.watchLessons(widget.course.id).listen((list) {
      if (mounted) setState(() { _lessons = list; _loading = false; });
    });
  }

  @override
  void dispose() {
    _entrance.dispose();
    _sub?.cancel();
    super.dispose();
  }

  void _openLesson(CourseLesson lesson, int index) {
    final args = LessonViewerArgs(
      course: widget.course,
      lesson: lesson,
      lessonIndex: index,
      totalLessons: _lessons.length,
      onCompleted: () {
        widget.onLessonCompleted?.call(lesson.id);
        if (mounted) {
          setState(() {
            _enrollment = (_enrollment ?? CourseEnrollment(courseId: widget.course.id))
                .withCompleted(lesson.id);
          });
        }
      },
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LessonViewerView(), settings: RouteSettings(arguments: args)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catColor    = widget.course.category.color;
    final accentColor = widget.course.category.accentColor;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) => Directionality(
        textDirection: TextDirection.rtl,
        child: AnimatedBuilder(
          animation: _entrance,
          builder: (context, child) => Opacity(
            opacity: _fade.value.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: _scale.value,
              alignment: Alignment.bottomCenter,
              child: child,
            ),
          ),
          child: Container(
          decoration: const BoxDecoration(
            color: AppColors.backgroundNeutral100,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grayLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 4),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeroSection(
                        course: widget.course,
                        enrollment: _enrollment,
                        lessons: _lessons,
                        catColor: catColor,
                        accentColor: accentColor,
                      ),
                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionHeader(
                              icon: Icons.info_outline_rounded,
                              title: 'course_detail_about'.tr,
                              color: catColor,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              widget.course.description,
                              style: TextStyle(
                                fontSize: 14, height: 1.7,
                                color: AppColors.textPrimaryParagraph,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _SectionHeader(
                              icon: Icons.format_list_numbered_rounded,
                              title: 'course_detail_lessons'.tr,
                              color: catColor,
                            ),
                            const SizedBox(height: 14),
                          ],
                        ),
                      ),

                      if (_loading)
                        const Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_lessons.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Text(
                              'لم تُضف دروس بعد',
                              style: TextStyle(color: AppColors.grayMedium, fontSize: 14),
                            ),
                          ),
                        )
                      else
                        _LessonsTrack(
                          lessons: _lessons,
                          enrollment: _enrollment,
                          catColor: catColor,
                          onTap: _openLesson,
                        ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

// ── Hero section ──────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.course,
    required this.enrollment,
    required this.lessons,
    required this.catColor,
    required this.accentColor,
  });

  final NurseryCourse course;
  final CourseEnrollment? enrollment;
  final List<CourseLesson> lessons;
  final Color catColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final lessonCount    = lessons.length;
    final completedCount = enrollment?.completedCount() ?? 0;
    final progress       = lessonCount == 0 ? 0.0 : completedCount / lessonCount;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [catColor, accentColor],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30, left: -30,
            child: Container(
              width: 140, height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -20, right: -10,
            child: Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.30)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(course.category.icon, color: Colors.white, size: 12),
                      const SizedBox(width: 5),
                      Text(
                        course.category.label,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  course.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.play_lesson_rounded,
                      label: '$lessonCount ${'course_lessons_count'.tr}',
                    ),
                    const SizedBox(width: 8),
                    if (course.formattedDuration != '—')
                      _InfoChip(
                        icon: Icons.schedule_rounded,
                        label: course.formattedDuration,
                      ),
                    if (course.ageGroup.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      _InfoChip(
                        icon: Icons.child_care_rounded,
                        label: '${course.ageGroup} ${'course_age_years'.tr}',
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: course.isFree
                            ? Colors.white.withOpacity(0.22)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        course.priceLabel,
                        style: TextStyle(
                          color: course.isFree ? Colors.white : catColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (enrollment != null && lessonCount > 0) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$completedCount / $lessonCount ${'course_completed_lessons'.tr}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: progress),
                                duration: const Duration(milliseconds: 900),
                                curve: Curves.easeOutCubic,
                                builder: (ctx, v, _) => LinearProgressIndicator(
                                  value: v,
                                  minHeight: 6,
                                  backgroundColor: Colors.white.withOpacity(0.25),
                                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.16),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.22)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 11),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title, required this.color});
  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDefault),
          ),
        ],
      );
}

// ── Lessons track ─────────────────────────────────────────────────────────────

class _LessonsTrack extends StatelessWidget {
  const _LessonsTrack({
    required this.lessons,
    required this.enrollment,
    required this.catColor,
    required this.onTap,
  });

  final List<CourseLesson> lessons;
  final CourseEnrollment? enrollment;
  final Color catColor;
  final void Function(CourseLesson lesson, int index) onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(lessons.length, (i) {
          final lesson      = lessons[i];
          final isCompleted = enrollment?.isCompleted(lesson.id) ?? false;
          final isFirst     = i == 0;
          final isLast      = i == lessons.length - 1;
          final isCurrent   = !isCompleted && (i == 0 || (enrollment?.isCompleted(lessons[i - 1].id) ?? false));

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    _StepCircle(
                      index: i + 1,
                      isCompleted: isCompleted,
                      isCurrent: isCurrent,
                      catColor: catColor,
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? catColor.withOpacity(0.35)
                                : AppColors.grayLight,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: _LessonTile(
                    lesson: lesson,
                    isCompleted: isCompleted,
                    isCurrent: isCurrent,
                    catColor: catColor,
                    isLast: isLast,
                    onTap: () => onTap(lesson, i),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ── Step circle ───────────────────────────────────────────────────────────────

class _StepCircle extends StatelessWidget {
  const _StepCircle({
    required this.index,
    required this.isCompleted,
    required this.isCurrent,
    required this.catColor,
  });

  final int index;
  final bool isCompleted;
  final bool isCurrent;
  final Color catColor;

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.6, end: 1),
        duration: const Duration(milliseconds: 400),
        curve: Curves.elasticOut,
        builder: (_, v, child) => Transform.scale(scale: v, child: child),
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle, color: catColor,
            boxShadow: [
              BoxShadow(color: catColor.withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 3)),
            ],
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
        ),
      );
    }

    if (isCurrent) {
      return Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: catColor.withOpacity(0.12),
          border: Border.all(color: catColor, width: 2.5),
        ),
        child: Center(
          child: Container(
            width: 10, height: 10,
            decoration: BoxDecoration(shape: BoxShape.circle, color: catColor),
          ),
        ),
      );
    }

    return Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle, color: AppColors.white,
        border: Border.all(color: AppColors.grayLight, width: 1.5),
      ),
      child: Center(
        child: Text(
          '$index',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.grayMedium),
        ),
      ),
    );
  }
}

// ── Lesson tile ───────────────────────────────────────────────────────────────

class _LessonTile extends StatelessWidget {
  const _LessonTile({
    required this.lesson,
    required this.isCompleted,
    required this.isCurrent,
    required this.catColor,
    required this.isLast,
    required this.onTap,
  });

  final CourseLesson lesson;
  final bool isCompleted;
  final bool isCurrent;
  final Color catColor;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isCompleted
                ? catColor.withOpacity(0.06)
                : isCurrent
                    ? catColor.withOpacity(0.08)
                    : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCompleted
                  ? catColor.withOpacity(0.20)
                  : isCurrent
                      ? catColor.withOpacity(0.30)
                      : AppColors.grayLight,
              width: isCurrent ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Content type icon
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: lesson.contentType.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Icon(lesson.contentType.icon, size: 14, color: lesson.contentType.color),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      lesson.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isCompleted || isCurrent ? FontWeight.w700 : FontWeight.w500,
                        color: isCompleted
                            ? catColor
                            : isCurrent
                                ? AppColors.textDefault
                                : AppColors.textPrimaryParagraph,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (lesson.durationMinutes > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundNeutral100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule_rounded, size: 10, color: AppColors.grayMedium),
                          const SizedBox(width: 3),
                          Text(
                            '${lesson.durationMinutes} د',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.grayMedium),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(width: 6),
                  Icon(
                    isCompleted
                        ? Icons.check_circle_rounded
                        : isCurrent
                            ? Icons.play_circle_rounded
                            : Icons.arrow_forward_ios,
                    size: isCompleted || isCurrent ? 16 : 12,
                    color: isCompleted || isCurrent ? catColor : AppColors.grayMedium,
                  ),
                ],
              ),
              if (lesson.description != null && isCurrent) ...[
                const SizedBox(height: 5),
                Text(
                  lesson.description!,
                  style: TextStyle(fontSize: 11, height: 1.4, color: AppColors.textPrimaryParagraph),
                ),
              ],
              if (isCurrent)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_arrow_rounded, size: 13, color: catColor),
                      const SizedBox(width: 3),
                      Text(
                        'course_current_lesson'.tr,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: catColor),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
