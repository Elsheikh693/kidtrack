import '../../../../../index/index_main.dart';

const _kBlue = Color(0xFF2563EB);
const _kGreen = Color(0xFF16A34A);
const _kAmber = Color(0xFFD97706);
const _kRed = Color(0xFFDC2626);
const _kPurple = Color(0xFF7C3AED);
const _kPink = Color(0xFFEC4899);

// ── Top-level eval helpers ────────────────────────────────────────────────────

Color _evalColor(String? k) => switch (k) {
  'excellent' => _kGreen,
  'needs_follow' => _kAmber,
  'needs_attention' => _kRed,
  _ => Colors.grey,
};

IconData _evalIcon(String? k) => switch (k) {
  'excellent' => Icons.star_rounded,
  'needs_follow' => Icons.remove_circle_rounded,
  'needs_attention' => Icons.warning_rounded,
  _ => Icons.radio_button_unchecked_rounded,
};

String _evalLabel(String? k) => switch (k) {
  'excellent' => 'ممتاز',
  'needs_follow' => 'جيد',
  'needs_attention' => 'يحتاج دعم',
  _ => 'لم يُقيَّم',
};

// ── Main view ─────────────────────────────────────────────────────────────────

class LbActivityDetailView extends StatefulWidget {
  final ClassroomActivityModel activity;
  final List<ChildModel> children;

  const LbActivityDetailView({
    super.key,
    required this.activity,
    required this.children,
  });

  @override
  State<LbActivityDetailView> createState() => _LbActivityDetailViewState();
}

class _LbActivityDetailViewState extends State<LbActivityDetailView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // ─── Data helpers ─────────────────────────────────────────────────────────

  int get _studentCount => widget.activity.childIds.length;

  IconData get _subjectIcon {
    final s = (widget.activity.subjectName ?? widget.activity.title)
        .toLowerCase();
    if (s.contains('english') || s.contains('إنجليز') || s.contains('لغة'))
      return Icons.abc_rounded;
    if (s.contains('عربي') || s.contains('arabic'))
      return Icons.menu_book_rounded;
    if (s.contains('رياضيات') || s.contains('math'))
      return Icons.calculate_rounded;
    if (s.contains('فن') || s.contains('رسم') || s.contains('art'))
      return Icons.palette_rounded;
    if (s.contains('علوم') || s.contains('science'))
      return Icons.science_rounded;
    if (s.contains('قرآن')) return Icons.import_contacts_rounded;
    if (s.contains('رياضة') || s.contains('sport'))
      return Icons.sports_soccer_rounded;
    return Icons.auto_stories_rounded;
  }

  // ─── Staggered animation ──────────────────────────────────────────────────

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

  // ─── Lifecycle ────────────────────────────────────────────────────────────

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

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final act = widget.activity;
    final startDt = DateTime.fromMillisecondsSinceEpoch(act.startedAt);
    final timeLabel =
        '${startDt.hour.toString().padLeft(2, '0')}:${startDt.minute.toString().padLeft(2, '0')}';
    final durationMin = act.elapsed.inMinutes;
    final photos = act.allPhotoUrls;
    final childMap = {for (final c in widget.children) c.key!: c};

    final attentionIds = act.evaluations.entries
        .where((e) => e.value == 'needs_attention')
        .map((e) => e.key)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App bar ───────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0.5,
            shadowColor: Colors.black12,
            toolbarHeight: 70,
            leadingWidth: 50,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: _kBlue,
                size: 18,
              ),
              onPressed: Get.back,
            ),
            titleSpacing: 0,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: _kBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_subjectIcon, size: 20, color: _kBlue),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        act.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.typography.smSemiBold.copyWith(
                          color: const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          if (act.subjectName != null) act.subjectName!,
                          timeLabel,
                          '$durationMin د',
                        ].join('  •  '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.typography.xsRegular.copyWith(
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: const Color(0xFFE5E7EB)),
            ),
          ),

          // ── Body ──────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Eval breakdown
                  if (act.evaluations.isNotEmpty) ...[
                    _animated(
                      1,
                      _Section(
                        title: 'توزيع التقييمات',
                        icon: Icons.bar_chart_rounded,
                        color: _kBlue,
                        trailing: _CountBadge(
                          count: _studentCount,
                          color: _kBlue,
                        ),
                        child: _EvalBreakdown(
                          evaluations: act.evaluations,
                          childMap: childMap,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Photos
                  if (photos.isNotEmpty) ...[
                    _animated(
                      2,
                      _Section(
                        title: 'لحظات النشاط',
                        icon: Icons.photo_library_rounded,
                        color: _kPink,
                        child: _PhotosGrid(urls: photos),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Student performance
                  _animated(
                    4,
                    _Section(
                      title: 'أداء الطلاب',
                      icon: Icons.people_rounded,
                      color: _kPurple,
                      child: Column(
                        children: act.childIds.map((id) {
                          final child = childMap[id];
                          if (child == null) return const SizedBox.shrink();
                          return _ChildTile(
                            child: child,
                            evalKey: act.evaluations[id],
                            note: act.notes[id],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Needs attention
                  if (attentionIds.isNotEmpty) ...[
                    _animated(
                      5,
                      _Section(
                        title: 'يحتاجون دعماً',
                        icon: Icons.support_agent_rounded,
                        color: _kRed,
                        child: _AttentionSection(
                          childIds: attentionIds,
                          childMap: childMap,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Group note
                  if (act.groupNote != null && act.groupNote!.isNotEmpty) ...[
                    _animated(
                      6,
                      _Section(
                        title: 'ملاحظة عامة',
                        icon: Icons.sticky_note_2_rounded,
                        color: _kAmber,
                        child: _NoteCard(note: act.groupNote!),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section wrapper ───────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;
  final Widget? trailing;

  const _Section({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: context.typography.smSemiBold.copyWith(
                color: const Color(0xFF111827),
              ),
            ),
            if (trailing != null) ...[const Spacer(), trailing!],
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

// ── Count badge ───────────────────────────────────────────────────────────────

class _CountBadge extends StatelessWidget {
  final int count;
  final Color color;

  const _CountBadge({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_rounded, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            '$count طالب',
            style: context.typography.xsMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Eval breakdown (animated bars) ────────────────────────────────────────────

class _EvalBreakdown extends StatelessWidget {
  final Map<String, String> evaluations;
  final Map<String, ChildModel> childMap;

  const _EvalBreakdown({required this.evaluations, required this.childMap});

  List<ChildModel> _childrenFor(String evalKey) => evaluations.entries
      .where((e) => e.value == evalKey)
      .map((e) => childMap[e.key])
      .whereType<ChildModel>()
      .toList();

  @override
  Widget build(BuildContext context) {
    final total = evaluations.length;
    if (total == 0) return const SizedBox.shrink();
    final excellent = evaluations.values.where((v) => v == 'excellent').length;
    final follow = evaluations.values.where((v) => v == 'needs_follow').length;
    final attention = evaluations.values
        .where((v) => v == 'needs_attention')
        .length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _EvalBarRow(
            label: 'ممتاز',
            icon: Icons.star_rounded,
            count: excellent,
            total: total,
            color: _kGreen,
            delay: 0,
            onTap: () => _showChildren(context, 'excellent'),
          ),
          const SizedBox(height: 14),
          _EvalBarRow(
            label: 'جيد',
            icon: Icons.remove_circle_rounded,
            count: follow,
            total: total,
            color: _kAmber,
            delay: 150,
            onTap: () => _showChildren(context, 'needs_follow'),
          ),
          const SizedBox(height: 14),
          _EvalBarRow(
            label: 'يحتاج دعم',
            icon: Icons.warning_rounded,
            count: attention,
            total: total,
            color: _kRed,
            delay: 300,
            onTap: () => _showChildren(context, 'needs_attention'),
          ),
        ],
      ),
    );
  }

  void _showChildren(BuildContext context, String evalKey) {
    final children = _childrenFor(evalKey);
    if (children.isEmpty) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _EvalChildrenSheet(evalKey: evalKey, children: children),
    );
  }
}

class _EvalBarRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final int count;
  final int total;
  final Color color;
  final int delay;
  final VoidCallback onTap;

  const _EvalBarRow({
    required this.label,
    required this.icon,
    required this.count,
    required this.total,
    required this.color,
    required this.delay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : count / total;
    final enabled = count > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              SizedBox(
                width: 86,
                child: Row(
                  children: [
                    Icon(icon, size: 13, color: color),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        label,
                        style: context.typography.xsRegular.copyWith(
                          color: const Color(0xFF374151),
                          fontWeight: FontWeight.w500,
                        ),
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
                  builder: (context, value, _) {
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final filled = constraints.maxWidth * value;
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Stack(
                            children: [
                              Container(
                                height: 11,
                                width: constraints.maxWidth,
                                color: Colors.grey.shade100,
                              ),
                              Container(
                                height: 11,
                                width: filled,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 30,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: enabled
                      ? color.withValues(alpha: 0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$count',
                  style: context.typography.xsMedium.copyWith(
                    color: enabled ? color : Colors.grey.shade400,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: enabled ? color : Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Eval children sheet (animated drill-down) ─────────────────────────────────

class _EvalChildrenSheet extends StatefulWidget {
  final String evalKey;
  final List<ChildModel> children;

  const _EvalChildrenSheet({required this.evalKey, required this.children});

  @override
  State<_EvalChildrenSheet> createState() => _EvalChildrenSheetState();
}

class _EvalChildrenSheetState extends State<_EvalChildrenSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _evalColor(widget.evalKey);
    final icon = _evalIcon(widget.evalKey);
    final label = _evalLabel(widget.evalKey);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.78,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 18),
            // Header
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _ctrl,
                curve: const Interval(0, 0.4, curve: Curves.easeOut),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, size: 22, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: context.typography.lgBold.copyWith(
                            color: const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.children.length} طالب',
                          style: context.typography.xsRegular.copyWith(
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: widget.children.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final start = (0.15 + i * 0.09).clamp(0.0, 0.7);
                  final end = (start + 0.45).clamp(0.0, 1.0);
                  final anim = CurvedAnimation(
                    parent: _ctrl,
                    curve: Interval(start, end, curve: Curves.easeOutBack),
                  );
                  return FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _ctrl,
                      curve: Interval(start, end, curve: Curves.easeOut),
                    ),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.25, 0),
                        end: Offset.zero,
                      ).animate(anim),
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.85, end: 1).animate(anim),
                        alignment: Alignment.centerRight,
                        child: _EvalChildTile(
                          child: widget.children[i],
                          color: color,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EvalChildTile extends StatelessWidget {
  final ChildModel child;
  final Color color;

  const _EvalChildTile({required this.child, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          _ChildAvatar(child: child, size: 40, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              child.fullName,
              style: context.typography.smSemiBold.copyWith(
                color: const Color(0xFF111827),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Photos grid ───────────────────────────────────────────────────────────────

class _PhotosGrid extends StatelessWidget {
  final List<String> urls;

  const _PhotosGrid({required this.urls});

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
          children: display.map((url) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image(
                image: appCachedImageProvider(url),
                width: tile,
                height: tile,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, st) => Container(
                  width: tile,
                  height: tile,
                  color: Colors.grey.shade100,
                  child: Icon(
                    Icons.image_not_supported_rounded,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ── Child performance tile ────────────────────────────────────────────────────

class _ChildTile extends StatelessWidget {
  final ChildModel child;
  final String? evalKey;
  final String? note;

  const _ChildTile({required this.child, this.evalKey, this.note});

  @override
  Widget build(BuildContext context) {
    final color = _evalColor(evalKey);
    final label = _evalLabel(evalKey);
    final icon = _evalIcon(evalKey);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2.5),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: _ChildAvatar(
                              child: child,
                              size: 34,
                              color: color,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  child.fullName,
                                  style: context.typography.smSemiBold.copyWith(
                                    color: const Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Icon(icon, size: 13, color: color),
                                    const SizedBox(width: 4),
                                    Text(
                                      label,
                                      style: context.typography.xsMedium
                                          .copyWith(color: color),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(icon, size: 16, color: color),
                          ),
                        ],
                      ),
                      if (note != null && note!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            note!,
                            style: context.typography.xsRegular.copyWith(
                              color: const Color(0xFF374151),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
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

// ── Attention section ─────────────────────────────────────────────────────────

class _AttentionSection extends StatelessWidget {
  final List<String> childIds;
  final Map<String, ChildModel> childMap;

  const _AttentionSection({required this.childIds, required this.childMap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kRed.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: childIds.map((id) {
          final child = childMap[id];
          if (child == null) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                _ChildAvatar(child: child, size: 32, color: _kRed),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    child.fullName,
                    style: context.typography.smSemiBold.copyWith(
                      color: const Color(0xFF991B1B),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _kRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.support_rounded, size: 12, color: _kRed),
                      const SizedBox(width: 4),
                      Text(
                        'يحتاج دعم',
                        style: context.typography.xsRegular.copyWith(
                          color: _kRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Note card ─────────────────────────────────────────────────────────────────

class _NoteCard extends StatelessWidget {
  final String note;

  const _NoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kAmber.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: _kAmber.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: _kAmber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.sticky_note_2_rounded,
              size: 15,
              color: _kAmber,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              note,
              style: context.typography.smRegular.copyWith(
                color: const Color(0xFF374151),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Child avatar ──────────────────────────────────────────────────────────────

class _ChildAvatar extends StatelessWidget {
  final ChildModel child;
  final double size;
  final Color color;

  const _ChildAvatar({
    required this.child,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: color.withValues(alpha: 0.15),
      backgroundImage: child.hasImage
          ? appCachedImageProvider(child.profileImage!)
          : null,
      child: child.hasImage
          ? null
          : Text(
              child.firstName[0],
              style: context.typography.xsMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
    );
  }
}
