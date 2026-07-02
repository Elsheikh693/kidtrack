import '../../../../../index/index_main.dart';

class LbClassroomReport extends GetView<LinkBookController> {
  const LbClassroomReport({super.key});

  static const _kGreen = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          sliver: SliverList.builder(
            itemCount: 3,
            itemBuilder: (context, i) => const _SkeletonCard(),
          ),
        );
      }

      if (controller.activities.isEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _kGreen.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.event_note_rounded,
                    size: 44,
                    color: _kGreen,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'لا توجد أنشطة مكتملة',
                  style: context.typography.smSemiBold.copyWith(
                    color: const Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'لم يتم إنهاء أي نشاط في هذا اليوم',
                  style: context.typography.xsRegular.copyWith(
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final activities = controller.activities.toList();
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        sliver: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FadeSlideIn(
                delay: const Duration(milliseconds: 40),
                child: _SectionHeader(count: controller.totalActivities),
              ),
              const SizedBox(height: 16),
              for (int i = 0; i < activities.length; i++)
                _FadeSlideIn(
                  delay: Duration(milliseconds: 120 + (i * 70).clamp(0, 420)),
                  child: _LbActivityCard(
                    activity: activities[i],
                    children: controller.children,
                    onTap: () => Get.to(
                      () => LbActivityDetailView(
                        activity: activities[i],
                        children: controller.children,
                      ),
                      transition: Transition.cupertino,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}

// ── Staggered fade + slide + scale entry ─────────────────────────────────────

class _FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _FadeSlideIn({required this.child, this.delay = Duration.zero});

  @override
  State<_FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<_FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    final curved = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(curved);
    _scale = Tween<double>(begin: 0.94, end: 1.0).animate(curved);
    Future.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _fade,
    child: SlideTransition(
      position: _slide,
      child: ScaleTransition(scale: _scale, child: widget.child),
    ),
  );
}

// ── Section header ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final int count;
  const _SectionHeader({required this.count});

  static const _kGreen = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'أنشطة اليوم',
            style: context.typography.mdBold.copyWith(
              color: const Color(0xFF111827),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: _kGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                size: 12,
                color: _kGreen,
              ),
              const SizedBox(width: 4),
              Text(
                '$count',
                style: context.typography.xsMedium.copyWith(
                  color: _kGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Skeleton loading card ──────────────────────────────────────────────────────

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      height: 118,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 5, color: Colors.grey.shade200),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 13,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 10,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Activity Card ──────────────────────────────────────────────────────────────

class _LbActivityCard extends StatelessWidget {
  final ClassroomActivityModel activity;
  final List<ChildModel> children;
  final VoidCallback onTap;

  const _LbActivityCard({
    required this.activity,
    required this.children,
    required this.onTap,
  });

  static const _kGreen = Color(0xFF16A34A);
  static const _kAmber = Color(0xFFD97706);
  static const _kRed   = Color(0xFFDC2626);
  static const _kBlue  = Color(0xFF2563EB);
  static const _kPink  = Color(0xFFEC4899);

  int    get _excellent => activity.evaluations.values.where((v) => v == 'excellent').length;
  int    get _follow    => activity.evaluations.values.where((v) => v == 'needs_follow').length;
  int    get _attention => activity.evaluations.values.where((v) => v == 'needs_attention').length;
  int    get _total     => activity.childIds.length;
  int    get _evaluated => activity.evaluations.length;
  double get _evalRate  => _total == 0 ? 0 : (_evaluated / _total) * 100;

  Color get _rateColor {
    if (_evalRate >= 80) return _kGreen;
    if (_evalRate >= 40) return _kAmber;
    return _kRed;
  }

  Color _accentColor() {
    final s = (activity.subjectName ?? activity.title).toLowerCase();
    if (s.contains('english') || s.contains('إنجليز') || s.contains('لغة')) return _kBlue;
    if (s.contains('عربي')    || s.contains('arabic'))                        return const Color(0xFF059669);
    if (s.contains('رياضيات') || s.contains('math'))                           return const Color(0xFF7C3AED);
    if (s.contains('فن')      || s.contains('رسم')   || s.contains('art'))    return _kPink;
    if (s.contains('علوم')    || s.contains('science'))                        return const Color(0xFF0891B2);
    if (s.contains('قرآن'))                                                    return const Color(0xFF065F46);
    if (s.contains('رياضة')   || s.contains('sport'))                          return _kAmber;
    return const Color(0xFF6366F1);
  }

  IconData _accentIcon() {
    final s = (activity.subjectName ?? activity.title).toLowerCase();
    if (s.contains('english') || s.contains('إنجليز') || s.contains('لغة')) return Icons.abc_rounded;
    if (s.contains('عربي')    || s.contains('arabic'))                        return Icons.menu_book_rounded;
    if (s.contains('رياضيات') || s.contains('math'))                           return Icons.calculate_rounded;
    if (s.contains('فن')      || s.contains('رسم')   || s.contains('art'))    return Icons.palette_rounded;
    if (s.contains('علوم')    || s.contains('science'))                        return Icons.science_rounded;
    if (s.contains('قرآن'))                                                    return Icons.import_contacts_rounded;
    if (s.contains('رياضة')   || s.contains('sport'))                          return Icons.sports_soccer_rounded;
    return Icons.auto_stories_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final startDt     = DateTime.fromMillisecondsSinceEpoch(activity.startedAt);
    final timeLabel   = '${startDt.hour.toString().padLeft(2, '0')}:${startDt.minute.toString().padLeft(2, '0')}';
    final durationMin = activity.elapsed.inMinutes;
    final hasPhotos   = activity.photos.isNotEmpty;
    final accent      = _accentColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Accent bar — first child = right side in RTL
                Container(width: 5, color: accent),

                // Card content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Top: icon + title + status badges ─────────────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Subject icon
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: Icon(
                                _accentIcon(),
                                color: accent,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Title + time
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activity.title,
                                    style: context.typography.smSemiBold.copyWith(
                                      color: const Color(0xFF111827),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      if (activity.subjectName != null) ...[
                                        _SubjectBadge(
                                          label: activity.subjectName!,
                                          color: accent,
                                        ),
                                        const SizedBox(width: 6),
                                      ],
                                      Icon(
                                        Icons.schedule_rounded,
                                        size: 11,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        '$timeLabel · $durationMin د',
                                        style: context.typography.xsRegular.copyWith(
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Status badges column
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _kGreen.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.check_rounded,
                                        size: 12,
                                        color: _kGreen,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        'مكتمل',
                                        style: context.typography.xsRegular.copyWith(
                                          color: _kGreen,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (hasPhotos) ...[
                                  const SizedBox(height: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _kPink.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.photo_camera_rounded,
                                          size: 11,
                                          color: _kPink,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          '${activity.photos.length}',
                                          style: context.typography.xsRegular.copyWith(
                                            color: _kPink,
                                            fontWeight: FontWeight.w700,
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

                        const SizedBox(height: 12),
                        Container(height: 1, color: const Color(0xFFF3F4F6)),
                        const SizedBox(height: 10),

                        // ── Bottom: students + eval dots + rate + arrow ────
                        Row(
                          children: [
                            const Icon(
                              Icons.people_rounded,
                              size: 13,
                              color: Color(0xFF9CA3AF),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$_total طالب',
                              style: context.typography.xsRegular.copyWith(
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (_excellent > 0) ...[
                              _EvalDot(count: _excellent, color: _kGreen),
                              const SizedBox(width: 4),
                            ],
                            if (_follow > 0) ...[
                              _EvalDot(count: _follow, color: _kAmber),
                              const SizedBox(width: 4),
                            ],
                            if (_attention > 0)
                              _EvalDot(count: _attention, color: _kRed),
                            const Spacer(),
                            Text(
                              '${_evalRate.round()}%',
                              style: context.typography.xsMedium.copyWith(
                                color: _rateColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: _kBlue.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 11,
                                color: _kBlue,
                              ),
                            ),
                          ],
                        ),
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

// ── Subject badge ──────────────────────────────────────────────────────────────

class _SubjectBadge extends StatelessWidget {
  final String label;
  final Color  color;
  const _SubjectBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: context.typography.xsRegular.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Eval dot ──────────────────────────────────────────────────────────────────

class _EvalDot extends StatelessWidget {
  final int   count;
  final Color color;
  const _EvalDot({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 3),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
