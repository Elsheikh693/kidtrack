import '../../../../../index/index_main.dart';

Color _subjectColor(String? s) {
  if (s == null) return const Color(0xFF2563EB);
  final n = s.toLowerCase();
  if (n.contains('رياضيات') || n.contains('حساب') || n.contains('math')) return const Color(0xFF7C3AED);
  if (n.contains('عرب') || n.contains('لغة') || n.contains('arabic')) return const Color(0xFF2563EB);
  if (n.contains('قرآن') || n.contains('دين') || n.contains('islam')) return const Color(0xFF059669);
  if (n.contains('علوم') || n.contains('science')) return const Color(0xFF0EA5E9);
  if (n.contains('فن') || n.contains('رسم') || n.contains('art')) return const Color(0xFFD97706);
  if (n.contains('موسيق') || n.contains('music')) return const Color(0xFFEC4899);
  if (n.contains('رياضة') || n.contains('sport') || n.contains('بدن')) return const Color(0xFFF97316);
  return const Color(0xFF2563EB);
}

IconData _subjectIcon(String? s) {
  if (s == null) return Icons.assignment_rounded;
  final n = s.toLowerCase();
  if (n.contains('رياضيات') || n.contains('حساب') || n.contains('math')) return Icons.calculate_rounded;
  if (n.contains('عرب') || n.contains('لغة') || n.contains('arabic')) return Icons.menu_book_rounded;
  if (n.contains('قرآن') || n.contains('دين') || n.contains('islam')) return Icons.auto_stories_rounded;
  if (n.contains('علوم') || n.contains('science')) return Icons.science_rounded;
  if (n.contains('فن') || n.contains('رسم') || n.contains('art')) return Icons.palette_rounded;
  if (n.contains('موسيق') || n.contains('music')) return Icons.music_note_rounded;
  if (n.contains('رياضة') || n.contains('sport') || n.contains('بدن')) return Icons.directions_run_rounded;
  return Icons.assignment_rounded;
}

class HwReportCard extends StatelessWidget {
  const HwReportCard({
    super.key,
    required this.homework,
    required this.ctrl,
  });

  final HomeworkModel homework;
  final HomeworkTabController ctrl;

  static String _dateLabel(int? ms) {
    if (ms == null) return '';
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    return '${d.day} ${months[d.month - 1]}';
  }

  void _openDetail(BuildContext context) {
    final hwId = homework.key ?? '';
    final statuses = ctrl.statusesFor(hwId);
    final children = ctrl.childrenFor(homework);
    Get.to(
      () => HwDetailView(
        homework: homework,
        children: children,
        initialStatuses: statuses,
        submissions: ctrl.submissionsFor(hwId),
      ),
      transition: Transition.rightToLeft,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hwId = homework.key ?? '';
    final total = ctrl.totalChildren(homework);
    final completed = ctrl.countStatus(hwId, HomeworkStatus.completed);
    final partial = ctrl.countStatus(hwId, HomeworkStatus.partiallyCompleted);
    final notCompleted = ctrl.countStatus(hwId, HomeworkStatus.notCompleted);
    final absent = ctrl.countStatus(hwId, HomeworkStatus.absent);
    final unmarked = ctrl.unmarkedCount(homework);
    final submitted = ctrl.submittedCount(homework);
    final rate = ctrl.completionRate(homework);
    final isDueDateSet = homework.dueDate != null;
    final isOverdue = isDueDateSet &&
        homework.dueDate! < DateTime.now().millisecondsSinceEpoch;

    final color = _subjectColor(homework.subjectName);
    final icon = _subjectIcon(homework.subjectName);

    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
        margin: EdgeInsets.only(bottom: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.09),
              blurRadius: 20.r,
              offset: Offset(0, 4.h),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4.r,
              offset: Offset(0, 1.h),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Accent bar — first child = right side in RTL
                Container(width: 5.w, color: color),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header ──────────────────────────────────────────────
                      Padding(
                        padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 12.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 46.w,
                              height: 46.h,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(13.r),
                              ),
                              child: Icon(icon, color: color, size: 22.sp),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    homework.title,
                                    style: context.typography.smSemiBold.copyWith(
                                      color: const Color(0xFF111827),
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (homework.description != null &&
                                      homework.description!.isNotEmpty) ...[
                                    SizedBox(height: 3.h),
                                    Text(
                                      homework.description!,
                                      style: context.typography.xsMedium.copyWith(
                                        color: const Color(0xFF64748B),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  SizedBox(height: 5.h),
                                  // Date + due date badges row
                                  Wrap(
                                    spacing: 6.w,
                                    children: [
                                      _BadgeChip(
                                        icon: Icons.calendar_today_rounded,
                                        label: _dateLabel(homework.createdAt),
                                        color: const Color(0xFF64748B),
                                        bg: const Color(0xFFF1F5F9),
                                      ),
                                      if (isDueDateSet)
                                        _BadgeChip(
                                          icon: isOverdue
                                              ? Icons.warning_rounded
                                              : Icons.schedule_rounded,
                                          label: _dateLabel(homework.dueDate),
                                          color: isOverdue
                                              ? const Color(0xFFDC2626)
                                              : const Color(0xFF16A34A),
                                          bg: isOverdue
                                              ? const Color(0xFFDC2626).withValues(alpha: 0.08)
                                              : const Color(0xFFF0FDF4),
                                        ),
                                      if (submitted > 0)
                                        _BadgeChip(
                                          icon: Icons.home_rounded,
                                          label: '${'hw_sum_submitted'.tr} $submitted',
                                          color: const Color(0xFF2563EB),
                                          bg: const Color(0xFF2563EB)
                                              .withValues(alpha: 0.08),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Students count pill
                            if (total > 0)
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 9.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '$total',
                                      style: context.typography.mdBold.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: color,
                                      ),
                                    ),
                                    Text(
                                      'hw_students_count'.tr,
                                      style: context.typography.xsMedium.copyWith(
                                        fontSize: 9,
                                        color: color.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      // ── Animated progress bar ────────────────────────────────
                      if (total > 0) ...[
                        Padding(
                          padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 0),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: rate),
                            duration: const Duration(milliseconds: 900),
                            curve: Curves.easeOutQuart,
                            builder: (context, value, _) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6.r),
                                  child: LinearProgressIndicator(
                                    value: value,
                                    minHeight: 6.h,
                                    backgroundColor: const Color(0xFFE2E8F0),
                                    valueColor: AlwaysStoppedAnimation(
                                      value >= 0.8
                                          ? const Color(0xFF16A34A)
                                          : value >= 0.5
                                              ? const Color(0xFFD97706)
                                              : const Color(0xFFDC2626),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  '${(value * 100).round()}% إكمال',
                                  style: context.typography.smSemiBold.copyWith(
                                    fontSize: 10,
                                    color: value >= 0.8
                                        ? const Color(0xFF16A34A)
                                        : value >= 0.5
                                            ? const Color(0xFFD97706)
                                            : const Color(0xFFDC2626),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      Container(
                        height: 1.h,
                        margin: EdgeInsets.only(top: 10.h),
                        color: const Color(0xFFF3F4F6),
                      ),

                      // ── Status stats row ─────────────────────────────────────
                      Padding(
                        padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 12.h),
                        child: Row(
                          children: [
                            _StatDot(value: completed, label: 'أكمل', color: const Color(0xFF16A34A)),
                            SizedBox(width: 10.w),
                            _StatDot(value: partial, label: 'جزئي', color: const Color(0xFFD97706)),
                            SizedBox(width: 10.w),
                            _StatDot(value: notCompleted, label: 'لم يكمل', color: const Color(0xFFDC2626)),
                            SizedBox(width: 10.w),
                            _StatDot(value: absent, label: 'غائب', color: const Color(0xFF6B7280)),
                            if (unmarked > 0) ...[
                              SizedBox(width: 10.w),
                              _StatDot(value: unmarked, label: 'بدون', color: const Color(0xFFCBD5E1)),
                            ],
                            const Spacer(),
                            Container(
                              width: 30.w,
                              height: 30.h,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 12.sp,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

// ── Supporting widgets ─────────────────────────────────────────────────────────

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
  });
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 10.sp, color: color),
            SizedBox(width: 3.w),
            Text(
              label,
              style: context.typography.smSemiBold.copyWith(
                fontSize: 10,
                color: color,
              ),
            ),
          ],
        ),
      );
}

class _StatDot extends StatelessWidget {
  const _StatDot({required this.value, required this.label, required this.color});
  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: context.typography.displaySmBold.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: context.typography.xsMedium.copyWith(
              fontSize: 9,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      );
}
