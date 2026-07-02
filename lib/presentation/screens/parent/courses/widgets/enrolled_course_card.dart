import '../../../../../index/index_main.dart';
import 'course_detail_sheet.dart';

const _kInk = Color(0xFF0F172A);
const _kMuted = Color(0xFF64748B);
const _kBorder = Color(0xFFEEF0F4);

class EnrolledCourseCard extends StatelessWidget {
  const EnrolledCourseCard({
    super.key,
    required this.course,
    required this.enrollment,
    required this.index,
  });

  final NurseryCourse course;
  final CourseEnrollment enrollment;
  final int index;

  Color get catColor => course.category.color;

  @override
  Widget build(BuildContext context) {
    final completedCount = enrollment.completedCount();
    final lessonCount = course.lessonCount;
    final progress = lessonCount == 0 ? 0.0 : completedCount / lessonCount;
    final isDone = progress >= 1.0;

    return GestureDetector(
      onTap: () => showCourseDetail(context, course, enrollment: enrollment),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 7, 16, 7),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _kBorder),
          boxShadow: [
            BoxShadow(
              color: catColor.withValues(alpha: 0.07),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  _ProgressRing(
                    progress: progress,
                    catColor: catColor,
                    icon: isDone ? Icons.emoji_events_rounded : course.category.icon,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                            color: catColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            course.category.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: catColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          course.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: _kInk,
                            height: 1.2,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.menu_book_rounded, size: 13, color: _kMuted),
                            const SizedBox(width: 5),
                            Text(
                              '$completedCount / $lessonCount ${'course_completed_lessons'.tr}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _kMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(Icons.arrow_back_rounded, size: 17, color: catColor),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, _) => LinearProgressIndicator(
                    value: v,
                    minHeight: 8,
                    backgroundColor: catColor.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation(catColor),
                  ),
                ),
              ),

              if (isDone) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_events_rounded, size: 16, color: Color(0xFF059669)),
                      SizedBox(width: 8),
                      Text(
                        'أكملت هذا الكورس بنجاح 🎉',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Animated progress ring ────────────────────────────────────────────────────────

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({
    required this.progress,
    required this.catColor,
    required this.icon,
  });

  final double progress;
  final Color catColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 64,
        height: 64,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: const Duration(milliseconds: 1100),
          curve: Curves.easeOutCubic,
          builder: (_, v, _) => Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                  value: v,
                  strokeWidth: 6,
                  backgroundColor: catColor.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation(catColor),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16, color: catColor),
                  const SizedBox(height: 1),
                  Text(
                    '${(v * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: catColor,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
