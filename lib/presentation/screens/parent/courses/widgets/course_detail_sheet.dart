import 'dart:async';
import '../../../../../index/index_main.dart';
import '../../../../../Data/models/nursery_course/nursery_course_model.dart';
import '../../../../../Data/models/course_enrollment/course_enrollment_model.dart';
import '../../../../../Global/services/course_service.dart';
import '../../../courses/parent/lesson_viewer_view.dart';

String _formatDate(DateTime d) => '${d.day} ${monthName(d.month)} ${d.year}';

// ── Entry point ───────────────────────────────────────────────────────────────

void showCourseDetail(
  BuildContext context,
  NurseryCourse course, {
  bool isEnrolled = false,
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
    builder: (_) => CourseDetailSheet(course: course, isEnrolled: isEnrolled),
  );
}

// ── Main sheet ────────────────────────────────────────────────────────────────

class CourseDetailSheet extends StatefulWidget {
  const CourseDetailSheet({
    super.key,
    required this.course,
    this.isEnrolled = false,
  });

  final NurseryCourse course;
  final bool isEnrolled;

  @override
  State<CourseDetailSheet> createState() => _CourseDetailSheetState();
}

class _CourseDetailSheetState extends State<CourseDetailSheet>
    with SingleTickerProviderStateMixin {
  final _service = CourseService();
  List<CourseLesson> _lessons = [];
  bool _loading = true;
  StreamSubscription? _sub;
  StreamSubscription? _attendanceSub;
  // sessionIndex (1-based) → attendance status (present / absent).
  Map<int, CourseAttendanceStatus> _status = {};

  late final AnimationController _entrance;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  bool get _enrolled => widget.isEnrolled;

  @override
  void initState() {
    super.initState();

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

    // Track is only meaningful when reception has enrolled the active child.
    // Its status is driven by per-session attendance (present / absent).
    final childId = Get.isRegistered<ActiveChildService>()
        ? Get.find<ActiveChildService>().childId.value
        : '';
    if (_enrolled && childId.isNotEmpty) {
      _attendanceSub = _service
          .watchChildAttendance(widget.course.id, childId)
          .listen((records) {
        if (!mounted) return;
        setState(() {
          _status = {for (final r in records) r.sessionIndex: r.status};
        });
      });
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    _sub?.cancel();
    _attendanceSub?.cancel();
    super.dispose();
  }

  void _openLesson(CourseLesson lesson, int index) {
    final args = LessonViewerArgs(
      course: widget.course,
      lesson: lesson,
      lessonIndex: index,
      totalLessons: _lessons.length,
      onCompleted: () {},
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LessonViewerView(), settings: RouteSettings(arguments: args)),
    );
  }

  int get _presentCount =>
      _status.values.where((s) => s == CourseAttendanceStatus.present).length;

  // First session with no attendance record yet (child's standing point).
  int get _currentSession {
    if (!_enrolled) return 0;
    for (var s = 1; s <= _lessons.length; s++) {
      if (!_status.containsKey(s)) return s;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final catColor    = widget.course.category.color;
    final accentColor = widget.course.category.accentColor;
    final hasTrack    = _enrolled && !_loading && _lessons.isNotEmpty &&
        widget.course.totalSessions > 0;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) => Directionality(
        textDirection: appTextDirection,
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
                        presentCount: _presentCount,
                        showProgress: _enrolled,
                        lessons: _lessons,
                        catColor: catColor,
                        accentColor: accentColor,
                      ),
                      const SizedBox(height: 18),

                      // ── Enrolled → the track is the hero of this screen.
                      if (hasTrack)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _TrackStandingCard(
                            lessons: _lessons,
                            status: _status,
                            totalSessions: widget.course.totalSessions,
                            catColor: catColor,
                          ),
                        ),

                      // ── Not enrolled → tell them when the course starts.
                      if (!_enrolled)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _StartDateBanner(
                            course: widget.course,
                            catColor: catColor,
                            accentColor: accentColor,
                          ),
                        ),

                      const SizedBox(height: 22),

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
                              icon: _enrolled
                                  ? Icons.timeline_rounded
                                  : Icons.menu_book_rounded,
                              title: _enrolled
                                  ? 'parentcour21_sessions_track'.tr
                                  : 'parentcour21_course_content'.tr,
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
                              'parentcour21_no_lessons_yet'.tr,
                              style: TextStyle(color: AppColors.grayMedium, fontSize: 14),
                            ),
                          ),
                        )
                      else
                        _LessonsTrack(
                          lessons: _lessons,
                          status: _status,
                          currentSession: _currentSession,
                          enrolled: _enrolled,
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
    required this.presentCount,
    required this.showProgress,
    required this.lessons,
    required this.catColor,
    required this.accentColor,
  });

  final NurseryCourse course;
  final int presentCount;
  final bool showProgress;
  final List<CourseLesson> lessons;
  final Color catColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final lessonCount    = lessons.length;
    final totalSessions  = course.totalSessions;
    final progress       = totalSessions == 0 ? 0.0 : presentCount / totalSessions;

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
                    if (showProgress && totalSessions > 0) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$presentCount / $totalSessions ${'course_completed_lessons'.tr}',
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

// ── Start date banner (not-enrolled parents) ────────────────────────────────────
// When reception hasn't enrolled the child, the parent can only see course
// details and when the course starts.

class _StartDateBanner extends StatelessWidget {
  const _StartDateBanner({
    required this.course,
    required this.catColor,
    required this.accentColor,
  });

  final NurseryCourse course;
  final Color catColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final hasDate = course.hasStartDate;
    final dateLabel =
        hasDate ? _formatDate(course.startDateTime!) : 'parentcour21_not_set_yet'.tr;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: catColor.withOpacity(0.14)),
        boxShadow: [
          BoxShadow(
            color: catColor.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [catColor, accentColor],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.event_available_rounded,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'parentcour21_course_start_date'.tr,
                      style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: AppColors.grayMedium,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasDate
                          ? 'parentcour21_starts_on'.trParams({'date': dateLabel})
                          : 'parentcour21_start_not_set'.tr,
                      style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800,
                        color: AppColors.textDefault,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: catColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: catColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'parentcour21_not_enrolled_hint'.tr,
                    style: TextStyle(
                      fontSize: 12, height: 1.5,
                      color: AppColors.textPrimaryParagraph,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Track standing card ───────────────────────────────────────────────────────
// Attendance-driven "where does my child stand" summary. The hero of the sheet.

class _TrackStandingCard extends StatelessWidget {
  const _TrackStandingCard({
    required this.lessons,
    required this.status,
    required this.totalSessions,
    required this.catColor,
  });

  final List<CourseLesson> lessons;
  final Map<int, CourseAttendanceStatus> status;
  final int totalSessions;
  final Color catColor;

  @override
  Widget build(BuildContext context) {
    final attended = status.values
        .where((s) => s == CourseAttendanceStatus.present)
        .length;
    final absent = status.values
        .where((s) => s == CourseAttendanceStatus.absent)
        .length;
    final progress = totalSessions == 0 ? 0.0 : attended / totalSessions;

    // Next session with no record yet (their standing point).
    int? nextSession;
    for (var s = 1; s <= totalSessions; s++) {
      if (!status.containsKey(s)) { nextSession = s; break; }
    }
    final done = nextSession == null;

    String? nextTitle;
    if (nextSession != null) {
      for (final l in lessons) {
        if (l.orderIndex + 1 == nextSession) { nextTitle = l.title; break; }
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: catColor.withOpacity(0.14)),
        boxShadow: [
          BoxShadow(
            color: catColor.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Progress ring with attended / total.
              SizedBox(
                width: 60, height: 60,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 60, height: 60,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: progress),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutCubic,
                        builder: (_, v, __) => CircularProgressIndicator(
                          value: v,
                          strokeWidth: 5,
                          backgroundColor: catColor.withOpacity(0.12),
                          valueColor: AlwaysStoppedAnimation(catColor),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$attended',
                          style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800,
                            color: catColor, height: 1,
                          ),
                        ),
                        Text(
                          'parentcour21_of_count'.trParams({'count': '$totalSessions'}),
                          style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w600,
                            color: AppColors.grayMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      done
                          ? 'parentcour21_course_sessions_ended'.tr
                          : 'parentcour21_sessions_attended'.tr,
                      style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800,
                        color: AppColors.textDefault,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      done
                          ? 'parentcour21_child_attended_done'.trParams({
                              'attended': '$attended',
                              'total': '$totalSessions',
                            })
                          : 'parentcour21_child_attended_next'.trParams({
                              'attended': '$attended',
                              'total': '$totalSessions',
                              'next': '$nextSession',
                            }),
                      style: TextStyle(
                        fontSize: 12, height: 1.5,
                        color: AppColors.textPrimaryParagraph,
                      ),
                    ),
                    if (absent > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.cancel_rounded,
                              size: 13, color: Color(0xFFDC2626)),
                          const SizedBox(width: 4),
                          Text(
                            '${'parentcour21_absent_from'.tr} $absent ${absent == 1 ? 'parentcour21_session_unit'.tr : 'parentcour21_sessions_unit'.tr}',
                            style: const TextStyle(
                              fontSize: 11.5, fontWeight: FontWeight.w700,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (!done && nextTitle != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: catColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.play_circle_fill_rounded, size: 18, color: catColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'parentcour21_next_session'.tr,
                          style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w700,
                            color: catColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          nextTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700,
                            color: AppColors.textDefault,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
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
    required this.status,
    required this.currentSession,
    required this.enrolled,
    required this.catColor,
    required this.onTap,
  });

  final List<CourseLesson> lessons;
  final Map<int, CourseAttendanceStatus> status;
  final int currentSession; // 0 = none
  final bool enrolled;
  final Color catColor;
  final void Function(CourseLesson lesson, int index) onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(lessons.length, (i) {
          final lesson  = lessons[i];
          // Session index is 1-based; content item i maps to session i+1.
          final s       = i + 1;
          final st      = status[s];
          final isPresent = st == CourseAttendanceStatus.present;
          final isAbsent  = st == CourseAttendanceStatus.absent;
          final isCurrent = enrolled && s == currentSession;
          final isLast    = i == lessons.length - 1;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    _StepCircle(
                      index: s,
                      isPresent: isPresent,
                      isAbsent: isAbsent,
                      isCurrent: isCurrent,
                      catColor: catColor,
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: isPresent
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
                    isPresent: isPresent,
                    isAbsent: isAbsent,
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
    required this.isPresent,
    required this.isAbsent,
    required this.isCurrent,
    required this.catColor,
  });

  final int index;
  final bool isPresent;
  final bool isAbsent;
  final bool isCurrent;
  final Color catColor;

  static const _absentColor = Color(0xFFDC2626);

  @override
  Widget build(BuildContext context) {
    if (isPresent) {
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

    if (isAbsent) {
      return Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _absentColor.withOpacity(0.12),
          border: Border.all(color: _absentColor, width: 2),
        ),
        child: const Icon(Icons.close_rounded, color: _absentColor, size: 18),
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
    required this.isPresent,
    required this.isAbsent,
    required this.isCurrent,
    required this.catColor,
    required this.isLast,
    required this.onTap,
  });

  final CourseLesson lesson;
  final bool isPresent;
  final bool isAbsent;
  final bool isCurrent;
  final Color catColor;
  final bool isLast;
  final VoidCallback onTap;

  static const _absentColor = Color(0xFFDC2626);

  @override
  Widget build(BuildContext context) {
    final borderColor = isPresent
        ? catColor.withOpacity(0.20)
        : isAbsent
            ? _absentColor.withOpacity(0.30)
            : isCurrent
                ? catColor.withOpacity(0.30)
                : AppColors.grayLight;
    final bgColor = isPresent
        ? catColor.withOpacity(0.06)
        : isAbsent
            ? _absentColor.withOpacity(0.05)
            : isCurrent
                ? catColor.withOpacity(0.08)
                : AppColors.white;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
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
                        fontWeight: isPresent || isCurrent || isAbsent
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isPresent
                            ? catColor
                            : isAbsent
                                ? _absentColor
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
                            '${lesson.durationMinutes} ${'parentcour21_min_unit'.tr}',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.grayMedium),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(width: 6),
                  Icon(
                    isPresent
                        ? Icons.check_circle_rounded
                        : isAbsent
                            ? Icons.cancel_rounded
                            : isCurrent
                                ? Icons.play_circle_rounded
                                : Icons.arrow_forward_ios,
                    size: isPresent || isCurrent || isAbsent ? 16 : 12,
                    color: isPresent
                        ? catColor
                        : isAbsent
                            ? _absentColor
                            : isCurrent
                                ? catColor
                                : AppColors.grayMedium,
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
              if (isPresent)
                _FooterTag(
                  icon: Icons.check_circle_rounded,
                  label: 'parentcour21_attended_tag'.tr,
                  color: catColor,
                )
              else if (isAbsent)
                _FooterTag(
                  icon: Icons.cancel_rounded,
                  label: 'parentcour21_absent_tag'.tr,
                  color: _absentColor,
                )
              else if (isCurrent)
                _FooterTag(
                  icon: Icons.schedule_rounded,
                  label: 'parentcour21_next_session'.tr,
                  color: catColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterTag extends StatelessWidget {
  const _FooterTag({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 3),
            Text(
              label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
            ),
          ],
        ),
      );
}
