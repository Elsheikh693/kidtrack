import '../../../../../index/index_main.dart';
import '../controller.dart';

// ── Subject metadata ──────────────────────────────────────────────────────────

const _subjectColors = <String, Color>{
  'parent_course_arabic': Color(0xFFE67E22),
  'parent_course_english': Color(0xFF2980B9),
  'parent_course_math': Color(0xFF8E44AD),
  'parent_course_quran': Color(0xFF27AE60),
};

const _subjectIcons = <String, IconData>{
  'parent_course_arabic': Icons.menu_book_rounded,
  'parent_course_english': Icons.translate_rounded,
  'parent_course_math': Icons.calculate_rounded,
  'parent_course_quran': Icons.auto_stories_rounded,
};

Color _colorFor(String key) => _subjectColors[key] ?? const Color(0xFF64748B);
IconData _iconFor(String key) => _subjectIcons[key] ?? Icons.school_rounded;

// ── Public entry point ────────────────────────────────────────────────────────

void showTodayActivitiesSheet(BuildContext context, List<TodayActivity> activities) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => Directionality(
      textDirection: appTextDirection,
      child: _TodayActivitiesSheet(activities: activities),
    ),
  );
}

// ── Sheet widget ──────────────────────────────────────────────────────────────

class _TodayActivitiesSheet extends StatefulWidget {
  const _TodayActivitiesSheet({required this.activities});
  final List<TodayActivity> activities;

  @override
  State<_TodayActivitiesSheet> createState() => _TodayActivitiesSheetState();
}

class _TodayActivitiesSheetState extends State<_TodayActivitiesSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<Animation<double>> _fades;
  late List<Animation<Offset>> _slides;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    final count = widget.activities.length;
    _fades = List.generate(count, (i) {
      final start = (i * 0.1).clamp(0.0, 0.6);
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: Interval(start, start + 0.35, curve: Curves.easeOut)),
      );
    });
    _slides = List.generate(count, (i) {
      final start = (i * 0.1).clamp(0.0, 0.6);
      return Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
        CurvedAnimation(parent: _ctrl, curve: Interval(start, start + 0.4, curve: Curves.easeOutCubic)),
      );
    });

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doneCount = widget.activities.where((a) => a.status == ActivityStatus.done).length;
    final activeCount = widget.activities.where((a) => a.status == ActivityStatus.active).length;
    final upcomingCount = widget.activities.where((a) => a.status == ActivityStatus.upcoming).length;
    final total = widget.activities.length;
    final bottomPad = MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 24;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── drag handle ──────────────────────────────────────────
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDDE1E7),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── header ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'parent_edu_today_activities'.tr,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1D23),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _todayLabel(),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8A94A6),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                // completion badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: doneCount == total
                        ? const Color(0xFF059669).withValues(alpha: 0.1)
                        : AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$doneCount/$total',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: doneCount == total
                              ? const Color(0xFF059669)
                              : AppColors.primary,
                        ),
                      ),
                      Text(
                        'parent_edu_activities_done'.tr,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: doneCount == total
                              ? const Color(0xFF059669)
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── progress segments ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _ProgressSegments(activities: widget.activities),
          ),
          const SizedBox(height: 12),

          // ── stats row ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _StatDot(
                  color: const Color(0xFF059669),
                  icon: Icons.check_circle_rounded,
                  label: '$doneCount ${'parent_edu_stat_done'.tr}',
                ),
                const SizedBox(width: 16),
                if (activeCount > 0) ...[
                  _StatDot(
                    color: AppColors.primary,
                    icon: Icons.radio_button_checked_rounded,
                    label: '$activeCount ${'parent_edu_stat_active'.tr}',
                  ),
                  const SizedBox(width: 16),
                ],
                _StatDot(
                  color: const Color(0xFF8A94A6),
                  icon: Icons.schedule_rounded,
                  label: '$upcomingCount ${'parent_edu_stat_upcoming'.tr}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── divider ───────────────────────────────────────────────
          Container(height: 1, color: const Color(0xFFEEF0F4)),

          // ── scrollable activity list ──────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad),
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (context, _) => Column(
                  children: widget.activities.asMap().entries.map((e) {
                    return SlideTransition(
                      position: _slides[e.key],
                      child: FadeTransition(
                        opacity: _fades[e.key],
                        child: _ActivityCard(
                          activity: e.value,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _todayLabel() {
    return arabicFullDate();
  }
}

// ── Progress segments ─────────────────────────────────────────────────────────

class _ProgressSegments extends StatelessWidget {
  const _ProgressSegments({required this.activities});
  final List<TodayActivity> activities;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: activities.asMap().entries.map((e) {
        final i = e.key;
        final a = e.value;
        final color = a.status == ActivityStatus.done
            ? _colorFor(a.subjectKey)
            : a.status == ActivityStatus.active
                ? _colorFor(a.subjectKey).withValues(alpha: 0.5)
                : const Color(0xFFDDE1E7);
        return Expanded(
          child: Container(
            height: 5,
            margin: EdgeInsets.only(left: i < activities.length - 1 ? 4 : 0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Stat dot ──────────────────────────────────────────────────────────────────

class _StatDot extends StatelessWidget {
  const _StatDot({required this.color, required this.icon, required this.label});
  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color),
        ),
      ],
    );
  }
}

// ── Activity card ─────────────────────────────────────────────────────────────

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity});
  final TodayActivity activity;

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(activity.subjectKey);
    final icon = _iconFor(activity.subjectKey);
    final isDone = activity.status == ActivityStatus.done;
    final isActive = activity.status == ActivityStatus.active;
    final isUpcoming = activity.status == ActivityStatus.upcoming;

    final bg = isDone
        ? const Color(0xFFF4F6F9)
        : isActive
            ? color.withValues(alpha: 0.06)
            : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: isActive
            ? Border(right: BorderSide(color: color, width: 3.5))
            : Border.all(
                color: isDone
                    ? Colors.transparent
                    : const Color(0xFFEEF0F4),
                width: 1,
              ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.10),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // status icon
            _StatusIcon(
              status: activity.status,
              color: color,
              icon: icon,
            ),
            const SizedBox(width: 14),
            // content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        activity.subjectKey.tr,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDone ? const Color(0xFFA0AAB8) : color,
                        ),
                      ),
                      const Spacer(),
                      // time badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDone
                              ? const Color(0xFFEEF0F4)
                              : isActive
                                  ? color.withValues(alpha: 0.1)
                                  : const Color(0xFFF4F6F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 11,
                              color: isDone
                                  ? const Color(0xFFA0AAB8)
                                  : isActive
                                      ? color
                                      : const Color(0xFF8A94A6),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              activity.time,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDone
                                    ? const Color(0xFFA0AAB8)
                                    : isActive
                                        ? color
                                        : const Color(0xFF8A94A6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    activity.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDone
                          ? const Color(0xFFA0AAB8)
                          : isUpcoming
                              ? const Color(0xFF4A5568)
                              : const Color(0xFF1A1D23),
                    ),
                  ),
                  if (isDone) ...[
                    const SizedBox(height: 5),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded, size: 12, color: const Color(0xFF059669)),
                        const SizedBox(width: 4),
                        Text(
                          'parent_edu_activity_done'.tr,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (isActive) ...[
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'parent_edu_activity_active'.tr,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                  if (isUpcoming) ...[
                    const SizedBox(height: 5),
                    Text(
                      'parent_edu_activity_upcoming'.tr,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF8A94A6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status icon ───────────────────────────────────────────────────────────────

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({
    required this.status,
    required this.color,
    required this.icon,
  });
  final ActivityStatus status;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    if (status == ActivityStatus.active) {
      return _PulsingStatusIcon(color: color, icon: icon);
    }
    if (status == ActivityStatus.done) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF059669).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.check_rounded, size: 22, color: Color(0xFF059669)),
      );
    }
    // upcoming
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Icon(icon, size: 20, color: color.withValues(alpha: 0.45)),
    );
  }
}

class _PulsingStatusIcon extends StatefulWidget {
  const _PulsingStatusIcon({required this.color, required this.icon});
  final Color color;
  final IconData icon;

  @override
  State<_PulsingStatusIcon> createState() => _PulsingStatusIconState();
}

class _PulsingStatusIconState extends State<_PulsingStatusIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.12 + _ctrl.value * 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: widget.color.withValues(alpha: 0.3 + _ctrl.value * 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: _ctrl.value * 0.2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(widget.icon, size: 22, color: widget.color),
      ),
    );
  }
}
