import '../../../../../index/index_main.dart';

// ── Colors ────────────────────────────────────────────────────────────────────
const _kBlue   = Color(0xFF2563EB);
const _kGreen  = Color(0xFF16A34A);
const _kAmber  = Color(0xFFD97706);
const _kPurple = Color(0xFF7C3AED);
const _kRed    = Color(0xFFDC2626);
const _kPink   = Color(0xFFEC4899);

// ─────────────────────────────────────────────────────────────────────────────

class LbChildSummary extends GetView<LinkBookController> {
  const LbChildSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final summary = controller.buildChildSummary();

      final sections = <Widget>[
        _HeroCard(summary: summary),
        _SummaryStatsRow(summary: summary),
        if (summary.participated.isNotEmpty)
          _Section(
            title: 'مسار الأنشطة',
            icon: Icons.timeline_rounded,
            color: _kBlue,
            child: Column(
              children: summary.participated
                  .map((a) =>
                      _ActivityTimelineCard(activity: a, child: summary.child))
                  .toList(),
            ),
          ),
        _Section(
          title: 'معدل المشاركة',
          icon: Icons.donut_large_rounded,
          color: _kBlue,
          child: _EngagementMeter(
            participated: summary.participated.length,
            total: summary.allActivities.length,
            score: summary.engagementScore,
          ),
        ),
        if (summary.allPhotoUrls.isNotEmpty)
          _Section(
            title: 'لحظات اليوم',
            icon: Icons.photo_library_rounded,
            color: _kPink,
            child: _PhotosGallery(urls: summary.allPhotoUrls),
          ),
      ];

      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        sliver: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < sections.length; i++) ...[
                _FadeSlideIn(
                  delay: Duration(milliseconds: 40 + (i * 65).clamp(0, 480)),
                  child: sections[i],
                ),
                if (i != sections.length - 1) const SizedBox(height: 18),
              ],
            ],
          ),
        ),
      );
    });
  }
}

// ─── Section wrapper (header + body) ──────────────────────────────────────────

class _Section extends StatelessWidget {
  final String   title;
  final IconData icon;
  final Color    color;
  final Widget   child;

  const _Section({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: title, icon: icon, color: color),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

// ─── Staggered fade + slide + scale entry ─────────────────────────────────────

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
    _scale = Tween<double>(begin: 0.96, end: 1.0).animate(curved);
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

// ─── Hero card ────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final ChildDailySummary summary;
  const _HeroCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF2563EB), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _kBlue.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                backgroundImage: summary.child.hasImage
                    ? appCachedImageProvider(summary.child.profileImage!)
                    : null,
                child: summary.child.hasImage
                    ? null
                    : Text(
                        summary.child.firstName[0],
                        style: context.typography.xlBold.copyWith(
                          color: Colors.white,
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.child.fullName,
                      style: context.typography.lgBold.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            summary.avgRatingLabel,
                            style: context.typography.xsMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (summary.engagementScore >= 90) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBBF24).withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '⭐ مثالي',
                              style: context.typography.xsMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.import_contacts_rounded, color: Colors.white54, size: 28),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 14),
          Text(
            summary.heroText,
            style: context.typography.smRegular.copyWith(
              color: Colors.white,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Summary stats row ────────────────────────────────────────────────────────

class _SummaryStatsRow extends StatelessWidget {
  final ChildDailySummary summary;
  const _SummaryStatsRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniStatCard(
            label: 'الأنشطة',
            value: '${summary.participated.length}',
            icon: Icons.play_circle_rounded,
            color: _kGreen,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStatCard(
            label: 'التقييم',
            value: summary.avgRatingLabel,
            icon: Icons.star_rounded,
            color: _kAmber,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStatCard(
            label: 'المشاركة',
            value: '${summary.engagementScore.round()}%',
            icon: Icons.donut_large_rounded,
            color: _kBlue,
          ),
        ),
        if (summary.bestActivityTitle != null) ...[
          const SizedBox(width: 10),
          Expanded(
            child: _MiniStatCard(
              label: 'الأفضل',
              value: summary.bestActivityTitle!,
              icon: Icons.emoji_events_rounded,
              color: _kPurple,
              small: true,
            ),
          ),
        ],
      ],
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool small;

  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: context.typography.displaySmBold.copyWith(
              fontSize: small ? 11 : null,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: context.typography.xsRegular.copyWith(
              color: const Color(0xFF9CA3AF),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Activity timeline card ───────────────────────────────────────────────────

class _ActivityTimelineCard extends StatelessWidget {
  final ClassroomActivityModel activity;
  final ChildModel child;

  const _ActivityTimelineCard({required this.activity, required this.child});

  @override
  Widget build(BuildContext context) {
    final eval  = activity.evalFor(child.key!);
    final color = _evalColor(eval);
    final label = _evalLabel(eval);
    final icon  = _evalIcon(eval);
    final note  = activity.notes[child.key!];

    final startDt = DateTime.fromMillisecondsSinceEpoch(activity.startedAt);
    final timeLabel =
        '${startDt.hour.toString().padLeft(2, '0')}:${startDt.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          activity.title,
                          style: context.typography.displaySmBold.copyWith(
                            color: const Color(0xFF111827),
                          ),
                        ),
                      ),
                      Text(
                        timeLabel,
                        style: context.typography.xsRegular.copyWith(
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (activity.subjectName != null) ...[
                        Text(
                          activity.subjectName!,
                          style: context.typography.xsRegular.copyWith(
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          label,
                          style: context.typography.xsMedium.copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (note != null && note.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        note,
                        style: context.typography.xsRegular.copyWith(
                          color: const Color(0xFF374151),
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
    );
  }

  static Color _evalColor(EvalLevel? e) {
    switch (e) {
      case EvalLevel.excellent:      return _kGreen;
      case EvalLevel.needsFollow:    return _kAmber;
      case EvalLevel.needsAttention: return _kRed;
      default:                       return Colors.grey;
    }
  }

  static IconData _evalIcon(EvalLevel? e) {
    switch (e) {
      case EvalLevel.excellent:      return Icons.star_rounded;
      case EvalLevel.needsFollow:    return Icons.remove_circle_rounded;
      case EvalLevel.needsAttention: return Icons.warning_rounded;
      default:                       return Icons.help_rounded;
    }
  }

  static String _evalLabel(EvalLevel? e) {
    switch (e) {
      case EvalLevel.excellent:      return 'ممتاز';
      case EvalLevel.needsFollow:    return 'جيد';
      case EvalLevel.needsAttention: return 'يحتاج دعم';
      default:                       return 'غير مقيّم';
    }
  }
}

// ─── Engagement meter ─────────────────────────────────────────────────────────

class _EngagementMeter extends StatelessWidget {
  final int    participated;
  final int    total;
  final double score;

  const _EngagementMeter({
    required this.participated,
    required this.total,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final rate = total == 0 ? 0.0 : participated / total;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$participated من أصل $total ${total == 1 ? "نشاط" : "أنشطة"}',
                      style: context.typography.displaySmBold.copyWith(
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${score.round()}% نسبة المشاركة',
                      style: context.typography.xsRegular.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _engagementColor(score).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _engagementLabel(score),
                  style: context.typography.xsMedium.copyWith(
                    color: _engagementColor(score),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: rate,
              minHeight: 10,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation(_engagementColor(score)),
            ),
          ),
        ],
      ),
    );
  }

  static Color  _engagementColor(double s) =>
      s >= 80 ? _kGreen : s >= 50 ? _kAmber : _kRed;
  static String _engagementLabel(double s) =>
      s >= 80 ? 'ممتاز' : s >= 50 ? 'جيد' : 'يحتاج متابعة';
}

// ─── Photos gallery ───────────────────────────────────────────────────────────

class _PhotosGallery extends StatelessWidget {
  final List<String> urls;
  const _PhotosGallery({required this.urls});

  @override
  Widget build(BuildContext context) {
    final display = urls.take(6).toList();
    const spacing = 8.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final tile = (constraints.maxWidth - spacing * 2) / 3;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: display
              .map((url) => ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image(
                      image: appCachedImageProvider(url),
                      width: tile,
                      height: tile,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, st) => Container(
                        width: tile,
                        height: tile,
                        color: Colors.grey.shade200,
                        child: Icon(Icons.image_not_supported_rounded,
                            color: Colors.grey.shade400),
                      ),
                    ),
                  ))
              .toList(),
        );
      },
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String   title;
  final IconData icon;
  final Color    color;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: context.typography.smSemiBold.copyWith(
            color: const Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}
