import '../../../../index/index_main.dart';

// ── Subject helpers ────────────────────────────────────────────────────────────

Color _subjectColor(String? s) {
  if (s == null) return const Color(0xFF16A34A);
  final n = s.toLowerCase();
  if (n.contains('رياضيات') || n.contains('حساب') || n.contains('math')) return const Color(0xFF7C3AED);
  if (n.contains('عرب') || n.contains('لغة') || n.contains('arabic')) return const Color(0xFF2563EB);
  if (n.contains('قرآن') || n.contains('دين') || n.contains('islam')) return const Color(0xFF059669);
  if (n.contains('علوم') || n.contains('science')) return const Color(0xFF0EA5E9);
  if (n.contains('فن') || n.contains('رسم') || n.contains('art')) return const Color(0xFFD97706);
  if (n.contains('موسيق') || n.contains('music')) return const Color(0xFFEC4899);
  if (n.contains('رياضة') || n.contains('sport') || n.contains('بدن')) return const Color(0xFFF97316);
  return const Color(0xFF16A34A);
}

IconData _subjectIcon(String? s) {
  if (s == null) return Icons.auto_awesome_rounded;
  final n = s.toLowerCase();
  if (n.contains('رياضيات') || n.contains('حساب') || n.contains('math')) return Icons.calculate_rounded;
  if (n.contains('عرب') || n.contains('لغة') || n.contains('arabic')) return Icons.menu_book_rounded;
  if (n.contains('قرآن') || n.contains('دين') || n.contains('islam')) return Icons.auto_stories_rounded;
  if (n.contains('علوم') || n.contains('science')) return Icons.science_rounded;
  if (n.contains('فن') || n.contains('رسم') || n.contains('art')) return Icons.palette_rounded;
  if (n.contains('موسيق') || n.contains('music')) return Icons.music_note_rounded;
  if (n.contains('رياضة') || n.contains('sport') || n.contains('بدن')) return Icons.directions_run_rounded;
  return Icons.auto_awesome_rounded;
}

// ── Data class ─────────────────────────────────────────────────────────────────

class _ChildEval {
  const _ChildEval({required this.child, required this.evalKey});
  final ChildModel child;
  final String? evalKey;
}

// ── Main view ──────────────────────────────────────────────────────────────────

class ActivityReportView extends StatefulWidget {
  const ActivityReportView({super.key});

  @override
  State<ActivityReportView> createState() => _ActivityReportViewState();
}

class _ActivityReportViewState extends State<ActivityReportView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _animated(int idx, Widget child) {
    final start = (idx * 0.08).clamp(0.0, 0.85);
    final end = (start + 0.5).clamp(0.0, 1.0);
    final anim = CurvedAnimation(
      parent: _ctrl,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.14),
          end: Offset.zero,
        ).animate(anim),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final activity = args['activity'] as ClassroomActivityModel;
    final children = (args['children'] as List<ChildModel>?) ?? [];

    final startDt = DateTime.fromMillisecondsSinceEpoch(activity.startedAt);
    final timeLabel =
        '${startDt.hour.toString().padLeft(2, '0')}:${startDt.minute.toString().padLeft(2, '0')}';

    final reg = EvalLevelsRegistry.instance;
    final levels = reg.levels;
    final evaluated = activity.evaluations.length;
    final participated = activity.childIds.length;

    // Count per dynamic level + mean-of-scores average.
    final counts = <String, int>{};
    double scoreSum = 0;
    for (final v in activity.evaluations.values) {
      counts[v] = (counts[v] ?? 0) + 1;
      scoreSum += reg.scoreFor(v);
    }
    final avgRating = evaluated == 0 ? 0.0 : scoreSum / evaluated;
    final distribution = [
      for (final l in levels) (level: l, count: counts[l.key] ?? 0),
    ];
    final maxScore = levels.isEmpty
        ? 5.0
        : levels.map((l) => l.score).reduce((a, b) => a > b ? a : b);

    final evalEntries = <_ChildEval>[];
    final childMap = {for (final c in children) c.key ?? '': c};
    for (final childId in activity.childIds) {
      final child = childMap[childId];
      if (child == null) continue;
      evalEntries.add(
          _ChildEval(child: child, evalKey: activity.evaluations[childId]));
    }
    // Highest score first (best performance on top).
    evalEntries.sort(
        (a, b) => reg.scoreFor(b.evalKey).compareTo(reg.scoreFor(a.evalKey)));

    final topStudents = evalEntries
        .where((e) =>
            e.evalKey != null && reg.scoreFor(e.evalKey) >= maxScore - 0.001)
        .take(5)
        .toList();
    final attentionStudents = evalEntries
        .where((e) => e.evalKey != null && reg.scoreFor(e.evalKey) <= 2.0)
        .toList();

    final color = _subjectColor(activity.subjectName);
    final sIcon = _subjectIcon(activity.subjectName);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Gradient SliverAppBar ────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 220.h,
              pinned: true,
              backgroundColor: color,
              surfaceTintColor: Colors.transparent,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Stack(
                  children: [
                    // Gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color,
                            Color.lerp(color, Colors.black, 0.18)!,
                          ],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                      ),
                    ),
                    // Decorative circles
                    Positioned(
                      top: -50.h,
                      left: -40.w,
                      child: Container(
                        width: 180.w,
                        height: 180.h,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -24.h,
                      right: -24.w,
                      child: Container(
                        width: 110.w,
                        height: 110.h,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    // Back button + content
                    SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Back button row
                          Padding(
                            padding: EdgeInsets.fromLTRB(4.w, 4.h, 16.w, 0),
                            child: IconButton(
                              icon: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                              onPressed: Get.back,
                            ),
                          ),
                          const Spacer(),
                          // Subject icon + title
                          Padding(
                            padding:
                                EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.20),
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child:
                                      Icon(sIcon, color: Colors.white, size: 24.sp),
                                ),
                                SizedBox(width: 14.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        activity.title,
                                        style: context.typography.mdBold.copyWith(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          height: 1.2,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (activity.subjectName != null) ...[
                                        SizedBox(height: 6.h),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8.w, vertical: 3.h),
                                          decoration: BoxDecoration(
                                            color: Colors.white
                                                .withValues(alpha: 0.20),
                                            borderRadius:
                                                BorderRadius.circular(6.r),
                                          ),
                                          child: Text(
                                            activity.subjectName!,
                                            style: context.typography.smSemiBold.copyWith(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Meta chips
                          Padding(
                            padding:
                                EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 18.h),
                            child: Row(
                              children: [
                                _HeaderChip(
                                  icon: Icons.access_time_rounded,
                                  label: timeLabel,
                                ),
                                SizedBox(width: 8.w),
                                _HeaderChip(
                                  icon: Icons.timer_rounded,
                                  label: activity.elapsedLabel,
                                ),
                                SizedBox(width: 8.w),
                                _HeaderChip(
                                  icon: Icons.people_rounded,
                                  label: '$participated طالب',
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

            // ── Body ────────────────────────────────────────────────────────
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 48.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Stat cards
                  _animated(
                    0,
                    _StatRow(
                      participated: participated,
                      evaluated: evaluated,
                      avgRating: avgRating,
                      color: color,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Eval breakdown
                  if (evaluated > 0) ...[
                    _animated(
                      1,
                      _EvalSection(
                        distribution: distribution,
                        total: evaluated,
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],

                  // Student performance
                  if (evalEntries.isNotEmpty) ...[
                    _animated(
                      2,
                      _SectionHeader(
                        title: 'teacher_report_detail_students_perf'.tr,
                        icon: Icons.people_rounded,
                        color: color,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    ...evalEntries.asMap().entries.map(
                          (e) => _animated(3 + e.key, _StudentTile(entry: e.value)),
                        ),
                    SizedBox(height: 16.h),
                  ],

                  // Top performers
                  if (topStudents.isNotEmpty) ...[
                    _animated(
                      3 + evalEntries.length,
                      _SectionHeader(
                        title: 'teacher_report_detail_top'.tr,
                        icon: Icons.military_tech_rounded,
                        color: const Color(0xFFD97706),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    _animated(
                      4 + evalEntries.length,
                      _TopStudentsGrid(entries: topStudents, color: color),
                    ),
                    SizedBox(height: 16.h),
                  ],

                  // Needs attention
                  if (attentionStudents.isNotEmpty) ...[
                    _animated(
                      5 + evalEntries.length,
                      _SectionHeader(
                        title: 'teacher_report_detail_attention'.tr,
                        icon: Icons.warning_rounded,
                        color: const Color(0xFFDC2626),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    _animated(
                      6 + evalEntries.length,
                      _AttentionList(entries: attentionStudents),
                    ),
                    SizedBox(height: 16.h),
                  ],

                  // Group note
                  if (activity.groupNote != null &&
                      activity.groupNote!.isNotEmpty) ...[
                    _animated(
                      7 + evalEntries.length,
                      _SectionHeader(
                        title: 'teacher_report_detail_group_note'.tr,
                        icon: Icons.sticky_note_2_rounded,
                        color: const Color(0xFFD97706),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    _animated(
                      8 + evalEntries.length,
                      _NoteCard(text: activity.groupNote!),
                    ),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header chip ────────────────────────────────────────────────────────────────

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12.sp, color: Colors.white),
            SizedBox(width: 5.w),
            Text(
              label,
              style: context.typography.smSemiBold.copyWith(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
}

// ── Stat row ───────────────────────────────────────────────────────────────────

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.participated,
    required this.evaluated,
    required this.avgRating,
    required this.color,
  });
  final int participated;
  final int evaluated;
  final double avgRating;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          _StatCard(
            icon: Icons.people_rounded,
            value: participated.toDouble(),
            label: 'teacher_report_detail_students'.tr,
            color: const Color(0xFF2563EB),
          ),
          SizedBox(width: 10.w),
          _StatCard(
            icon: Icons.check_circle_rounded,
            value: evaluated.toDouble(),
            label: 'teacher_report_detail_evaluated'.tr,
            color: const Color(0xFF16A34A),
          ),
          SizedBox(width: 10.w),
          _StatCard(
            icon: Icons.bar_chart_rounded,
            value: avgRating,
            label: 'teacher_report_detail_avg'.tr,
            color: const Color(0xFF7C3AED),
            isDecimal: true,
          ),
        ],
      );
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.isDecimal = false,
  });
  final IconData icon;
  final double value;
  final String label;
  final Color color;
  final bool isDecimal;

  @override
  Widget build(BuildContext context) => Expanded(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutQuart,
          builder: (context, v, _) => Container(
            padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 10.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.12),
                  blurRadius: 12.r,
                  offset: Offset(0, 4.h),
                ),
              ],
              border: Border(
                bottom: BorderSide(color: color, width: 3),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 18.sp),
                ),
                SizedBox(height: 8.h),
                Text(
                  isDecimal
                      ? (v == 0 ? '—' : v.toStringAsFixed(1))
                      : v.round().toString(),
                  style: context.typography.xlBold.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: color,
                    height: 1.0,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  label,
                  style: context.typography.xsMedium.copyWith(
                    fontSize: 10,
                    color: const Color(0xFF94A3B8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
}

// ── Eval breakdown ─────────────────────────────────────────────────────────────

class _EvalSection extends StatelessWidget {
  const _EvalSection({
    required this.distribution,
    required this.total,
  });
  final List<({EvalLevelTemplateModel level, int count})> distribution;
  final int total;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10.r,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 3.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF374151),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'توزيع التقييمات',
                  style: context.typography.displaySmBold.copyWith(
                    fontSize: 14,
                    color: const Color(0xFF111827),
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            for (int i = 0; i < distribution.length; i++) ...[
              if (i > 0) SizedBox(height: 10.h),
              _EvalBarRow(
                icon: EvalLevelIcons.iconFor(distribution[i].level.icon),
                label: distribution[i].level.title,
                count: distribution[i].count,
                total: total,
                color: Color(distribution[i].level.color),
                delay: i * 150,
              ),
            ],
          ],
        ),
      );
}

class _EvalBarRow extends StatelessWidget {
  const _EvalBarRow({
    required this.icon,
    required this.label,
    required this.count,
    required this.total,
    required this.color,
    required this.delay,
  });
  final IconData icon;
  final String label;
  final int count;
  final int total;
  final Color color;
  final int delay;

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : (count / total).clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
          width: 80.w,
          child: Row(
            children: [
              Icon(icon, size: 13.sp, color: color),
              SizedBox(width: 5.w),
              Text(
                label,
                style: context.typography.smSemiBold.copyWith(
                  fontSize: 12,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: fraction),
            duration: Duration(milliseconds: 900 + delay),
            curve: Curves.easeOutQuart,
            builder: (context, value, _) => LayoutBuilder(
              builder: (context, constraints) => ClipRRect(
                borderRadius: BorderRadius.circular(6.r),
                child: Stack(
                  children: [
                    Container(
                      height: 11.h,
                      width: constraints.maxWidth,
                      color: Colors.grey.shade100,
                    ),
                    Container(
                      height: 11.h,
                      width: constraints.maxWidth * value,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Container(
          width: 28.w,
          height: 22.h,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(6.r),
          ),
          alignment: Alignment.center,
          child: Text(
            '$count',
            style: context.typography.displaySmBold.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Section header ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
  });
  final String title;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 14.sp, color: color),
          ),
          SizedBox(width: 10.w),
          Text(
            title,
            style: context.typography.displaySmBold.copyWith(
              fontSize: 15,
              color: color,
            ),
          ),
        ],
      );
}

// ── Student tile ───────────────────────────────────────────────────────────────

class _StudentTile extends StatelessWidget {
  const _StudentTile({required this.entry});
  final _ChildEval entry;

  @override
  Widget build(BuildContext context) {
    final tpl = EvalLevelsRegistry.instance.byKey(entry.evalKey);
    final Color color =
        tpl != null ? Color(tpl.color) : Colors.grey.shade400;
    final IconData icon = tpl != null
        ? EvalLevelIcons.iconFor(tpl.icon)
        : Icons.radio_button_unchecked_rounded;
    final String label = tpl != null ? tpl.title : 'لم يُقيَّم';

    final avatarColors = [
      const Color(0xFF3B82F6), const Color(0xFF8B5CF6),
      const Color(0xFF16A34A), const Color(0xFFD97706),
      const Color(0xFFEC4899), const Color(0xFFF97316),
    ];
    final avatarColor = avatarColors[
        entry.child.firstName.codeUnits.fold(0, (a, b) => a + b) %
            avatarColors.length];

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4.w, color: color),
              Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  child: Row(
                    children: [
                    Container(
                      width: 36.w,
                      height: 36.h,
                      decoration: BoxDecoration(
                        color: avatarColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: avatarColor.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        entry.child.firstName.isNotEmpty
                            ? entry.child.firstName[0]
                            : '؟',
                        style: context.typography.displaySmBold.copyWith(
                          fontSize: 14,
                          color: avatarColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        entry.child.firstName,
                        style: context.typography.smSemiBold.copyWith(
                          fontSize: 14,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 12.sp, color: color),
                          SizedBox(width: 4.w),
                          Text(
                            label,
                            style: context.typography.smSemiBold.copyWith(
                              fontSize: 11,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Top students grid ──────────────────────────────────────────────────────────

class _TopStudentsGrid extends StatelessWidget {
  const _TopStudentsGrid({required this.entries, required this.color});
  final List<_ChildEval> entries;
  final Color color;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 10.w,
        runSpacing: 10.h,
        children: entries.asMap().entries.map((e) {
          final isFirst = e.key == 0;
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              gradient: isFirst
                  ? const LinearGradient(
                      colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    )
                  : null,
              color: isFirst ? null : Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: isFirst
                  ? null
                  : Border.all(
                      color: const Color(0xFFD97706).withValues(alpha: 0.25)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD97706).withValues(alpha: 0.15),
                  blurRadius: 8.r,
                  offset: Offset(0, 3.h),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.military_tech_rounded,
                  size: 16.sp,
                  color: isFirst ? Colors.white : const Color(0xFFD97706),
                ),
                SizedBox(width: 6.w),
                Text(
                  e.value.child.firstName,
                  style: context.typography.displaySmBold.copyWith(
                    fontSize: 13,
                    color: isFirst ? Colors.white : const Color(0xFF111827),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
}

// ── Attention list ─────────────────────────────────────────────────────────────

class _AttentionList extends StatelessWidget {
  const _AttentionList({required this.entries});
  final List<_ChildEval> entries;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: const Color(0xFFDC2626).withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
              color: const Color(0xFFDC2626).withValues(alpha: 0.15)),
        ),
        child: Column(
          children: entries
              .map(
                (e) => Padding(
                  padding: EdgeInsets.only(bottom: 6.h),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          size: 14.sp, color: const Color(0xFFDC2626)),
                      SizedBox(width: 8.w),
                      Text(
                        e.child.firstName,
                        style: context.typography.smSemiBold.copyWith(
                          fontSize: 13,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      );
}

// ── Note card ──────────────────────────────────────────────────────────────────

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFFDE68A)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD97706).withValues(alpha: 0.08),
              blurRadius: 8.r,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.sticky_note_2_rounded,
                color: const Color(0xFFD97706), size: 18.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                text,
                style: context.typography.xsMedium.copyWith(
                  fontSize: 13,
                  color: const Color(0xFF78350F),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
}
