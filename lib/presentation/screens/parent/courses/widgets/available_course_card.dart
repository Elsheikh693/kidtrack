import '../../../../../index/index_main.dart';
import 'course_detail_sheet.dart';

const _kInk = Color(0xFF0F172A);
const _kMuted = Color(0xFF64748B);
const _kBorder = Color(0xFFEEF0F4);

class AvailableCourseCard extends StatelessWidget {
  const AvailableCourseCard({
    super.key,
    required this.course,
    required this.isEnrolled,
    this.progress = 0.0,
    required this.index,
  });

  final NurseryCourse course;
  final bool isEnrolled;
  final double progress;
  final int index;

  @override
  Widget build(BuildContext context) {
    final catColor = course.category.color;
    final accent = course.category.accentColor;

    return GestureDetector(
      onTap: () => showCourseDetail(context, course, isEnrolled: isEnrolled),
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
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top: cover tile + title + price ──────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CoverTile(
                    icon: course.category.icon,
                    colors: [catColor, accent],
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _CategoryPill(label: course.category.label, color: catColor),
                            const Spacer(),
                            _PriceTag(course: course, color: catColor),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          course.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: _kInk,
                            height: 1.25,
                            letterSpacing: -0.2,
                          ),
                        ),
                        if (course.description.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Text(
                            course.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              height: 1.5,
                              color: _kMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 13),
              Container(height: 1, color: _kBorder),
              const SizedBox(height: 12),

              // ── Meta row ─────────────────────────────────────────────────
              Row(
                children: [
                  _Meta(
                    icon: Icons.play_lesson_rounded,
                    label: '${course.lessonCount} ${'course_lessons_count'.tr}',
                  ),
                  _MetaDot(),
                  _Meta(
                    icon: Icons.schedule_rounded,
                    label: course.formattedDuration,
                  ),
                  _MetaDot(),
                  _Meta(
                    icon: Icons.child_care_rounded,
                    label: course.ageGroup,
                  ),
                ],
              ),

              const SizedBox(height: 13),

              // ── CTA / enrolled progress ──────────────────────────────────
              if (isEnrolled)
                _ContinueBar(progress: progress, color: catColor)
              else
                _ExploreButton(color: catColor),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Cover tile ──────────────────────────────────────────────────────────────────

class _CoverTile extends StatelessWidget {
  const _CoverTile({required this.icon, required this.colors});
  final IconData icon;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.32),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -10,
            left: -10,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.18),
              ),
            ),
          ),
          Center(child: Icon(icon, color: Colors.white, size: 28)),
        ],
      ),
    );
  }
}

// ── Category pill ────────────────────────────────────────────────────────────────

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ── Price tag ────────────────────────────────────────────────────────────────────

class _PriceTag extends StatelessWidget {
  const _PriceTag({required this.course, required this.color});
  final NurseryCourse course;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (course.isFree) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFF059669).withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'parentcour21_free'.tr,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Color(0xFF059669),
          ),
        ),
      );
    }
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${course.price.toInt()}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          TextSpan(
            text: ' ${'parentcour21_egp'.tr}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Meta item ────────────────────────────────────────────────────────────────────

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: _kMuted),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: _kMuted,
          ),
        ),
      ],
    );
  }
}

class _MetaDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 9),
        width: 3,
        height: 3,
        decoration: const BoxDecoration(
          color: Color(0xFFCBD5E1),
          shape: BoxShape.circle,
        ),
      );
}

// ── Explore button ────────────────────────────────────────────────────────────────

class _ExploreButton extends StatelessWidget {
  const _ExploreButton({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.86)],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.28),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'course_view_details'.tr,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.arrow_back_rounded, size: 16, color: Colors.white),
        ],
      ),
    );
  }
}

// ── Continue bar (enrolled state) ─────────────────────────────────────────────────

class _ContinueBar extends StatelessWidget {
  const _ContinueBar({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle_rounded, size: 14, color: color),
                  const SizedBox(width: 5),
                  Text(
                    'course_enrolled_badge'.tr,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, _) => LinearProgressIndicator(
                    value: v,
                    minHeight: 7,
                    backgroundColor: color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(Icons.arrow_back_rounded, size: 17, color: color),
        ),
      ],
    );
  }
}
