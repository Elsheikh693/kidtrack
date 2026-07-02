import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Global/widgets/app_network_image.dart';
import '../controller.dart';
import 'journal_meta.dart';

/// Full activity details for a parent — opens with a clean, smooth reveal:
/// the sheet slides up (default modal transition) and its content fades and
/// rises in a gentle stagger.
Future<void> showActivityDetailSheet(
  BuildContext context,
  DayTimelineItem item,
) {
  // Pull the homework attached to this activity's subject so the parent sees,
  // in one place, both what the child did and what's assigned for it.
  List<EduHomework> related = const [];
  if (Get.isRegistered<ParentEducationController>()) {
    final hw = Get.find<ParentEducationController>().homework;
    related = hw.where((h) {
      if (item.subjectId != null && item.subjectId!.isNotEmpty) {
        return h.subjectId == item.subjectId;
      }
      return h.subjectKey.isNotEmpty && h.subjectKey == item.subjectName;
    }).toList();
  }
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (_) => _ActivityDetailSheet(item: item, homework: related),
  );
}

class _ActivityDetailSheet extends StatefulWidget {
  const _ActivityDetailSheet({required this.item, required this.homework});
  final DayTimelineItem item;
  final List<EduHomework> homework;

  @override
  State<_ActivityDetailSheet> createState() => _ActivityDetailSheetState();
}

class _ActivityDetailSheetState extends State<_ActivityDetailSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // Clean fade + slide-up, gently staggered by section index.
  Widget _stagger(int idx, Widget child) {
    final start = (0.15 + idx * 0.12).clamp(0.0, 0.7);
    final end = (start + 0.45).clamp(0.0, 1.0);
    final curve = CurvedAnimation(
      parent: _ctrl,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(curve),
        child: child,
      ),
    );
  }

  // The hero header fades and rises in cleanly.
  Widget _headerEntrance(Widget child) {
    final curve = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0, 0.55, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.14),
          end: Offset.zero,
        ).animate(curve),
        child: child,
      ),
    );
  }

  String get _timeRange => journalClock(widget.item.startedAt);

  // Assembles the ordered detail sections, staggering each one and inserting
  // spacing only between rendered blocks. Falls back to a single empty state
  // when the activity carries no extra detail at all.
  List<Widget> _buildSections({
    required ({String label, Color color, IconData icon})? eval,
    required List<String> reasons,
    required String? childNote,
    required String? groupNote,
    required List<EduHomework> homework,
    required List<String> photos,
    required Color color,
  }) {
    final sections = <Widget>[];

    if (eval != null) {
      sections.add(_EvalBlock(eval: eval, reasons: reasons));
    }
    if (childNote != null && childNote.isNotEmpty) {
      sections.add(_NoteBlock(
        icon: Icons.chat_bubble_rounded,
        title: 'تعليق المعلمة',
        text: childNote,
        color: const Color(0xFF7C3AED),
      ));
    }
    if (groupNote != null && groupNote.isNotEmpty) {
      sections.add(_NoteBlock(
        icon: Icons.campaign_rounded,
        title: 'ملاحظة عامة على النشاط',
        text: groupNote,
        color: const Color(0xFFD97706),
      ));
    }
    if (homework.isNotEmpty) {
      sections.add(_HomeworkBlock(items: homework));
    }
    if (photos.isNotEmpty) {
      sections.add(_PhotosBlock(urls: photos, color: color));
    }

    if (sections.isEmpty) {
      return [_stagger(0, const _EmptyDetails())];
    }

    final widgets = <Widget>[];
    for (var i = 0; i < sections.length; i++) {
      if (i > 0) widgets.add(const SizedBox(height: 14));
      widgets.add(_stagger(i, sections[i]));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final color = journalSubjectColor(item.subjectId ?? item.subjectName);
    final eventIcon = journalEventIcon(item.subjectName);
    final eval = item.evalLevel == null ? null : evalChipMeta(item.evalLevel!);
    final showSubject = item.title.trim().toLowerCase() !=
        item.subjectName.trim().toLowerCase();
    final childNote = item.note?.trim();
    final groupNote = item.groupNote?.trim();
    final photos = item.photos;
    final reasons = item.reasons.where((r) => r.trim().isNotEmpty).toList();
    final homework = widget.homework;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: const BoxDecoration(
          color: kJBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 46,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Flexible(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _headerEntrance(
                      _Header(
                        color: color,
                        icon: eventIcon,
                        subjectName: showSubject ? item.subjectName : null,
                        title: item.title,
                        timeRange: _timeRange,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 36),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        _buildSections(
                          eval: eval,
                          reasons: reasons,
                          childNote: childNote,
                          groupNote: groupNote,
                          homework: homework,
                          photos: photos,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ──────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.color,
    required this.icon,
    required this.subjectName,
    required this.title,
    required this.timeRange,
  });

  final Color color;
  final IconData icon;
  final String? subjectName;
  final String title;
  final String timeRange;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [color, Color.lerp(color, Colors.black, 0.18)!],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (subjectName != null) ...[
                      Text(
                        subjectName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.schedule_rounded,
                      size: 14, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    timeRange,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Evaluation block ────────────────────────────────────────────────────────────

class _EvalBlock extends StatelessWidget {
  const _EvalBlock({required this.eval, required this.reasons});

  final ({String label, Color color, IconData icon}) eval;
  final List<String> reasons;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kJBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: eval.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(eval.icon, size: 24, color: eval.color),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'تقييم المعلمة',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: kJMuted,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    eval.label,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: eval.color,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (reasons.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final r in reasons)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 11, vertical: 7),
                    decoration: BoxDecoration(
                      color: eval.color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: eval.color.withValues(alpha: 0.18)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_rounded, size: 13, color: eval.color),
                        const SizedBox(width: 5),
                        Text(
                          r,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: eval.color,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Homework block ──────────────────────────────────────────────────────────────

class _HomeworkBlock extends StatelessWidget {
  const _HomeworkBlock({required this.items});
  final List<EduHomework> items;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF8E44AD);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kJBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.assignment_rounded,
                    size: 16, color: accent),
              ),
              const SizedBox(width: 10),
              const Text(
                'الواجبات المرتبطة',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _HomeworkRow(item: items[i]),
          ],
        ],
      ),
    );
  }
}

class _HomeworkRow extends StatelessWidget {
  const _HomeworkRow({required this.item});
  final EduHomework item;

  @override
  Widget build(BuildContext context) {
    final done = item.isCompleted;
    final title = (item.displayTitle?.trim().isNotEmpty == true)
        ? item.displayTitle!.trim()
        : item.subjectKey;
    final accent = done ? const Color(0xFF059669) : const Color(0xFFD97706);
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kJBorder),
      ),
      child: Row(
        children: [
          Icon(
            done
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 20,
            color: accent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: kJInk,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  done ? 'تم الإنجاز' : 'موعد التسليم: ${item.dueDate}',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: accent,
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

// ── Note block ──────────────────────────────────────────────────────────────────

class _NoteBlock extends StatelessWidget {
  const _NoteBlock({
    required this.icon,
    required this.title,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kJBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Photos block ────────────────────────────────────────────────────────────────

class _PhotosBlock extends StatelessWidget {
  const _PhotosBlock({required this.urls, required this.color});
  final List<String> urls;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.photo_library_rounded, size: 18, color: color),
            const SizedBox(width: 8),
            const Text(
              'صور النشاط',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: kJInk,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${urls.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 8.0;
            final tile = (constraints.maxWidth - spacing * 2) / 3;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final url in urls)
                  GestureDetector(
                    onTap: () => _openViewer(context, url),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image(
                        image: appCachedImageProvider(url),
                        width: tile,
                        height: tile,
                        fit: BoxFit.cover,
                        loadingBuilder: (ctx, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            width: tile,
                            height: tile,
                            color: Colors.grey.shade100,
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          );
                        },
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
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _openViewer(BuildContext context, String url) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (_) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 4,
          child: Center(
            child: Image(
              image: appCachedImageProvider(url),
              fit: BoxFit.contain,
              errorBuilder: (ctx, err, st) => const Icon(
                Icons.broken_image_rounded,
                color: Colors.white54,
                size: 48,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Empty state ─────────────────────────────────────────────────────────────────

class _EmptyDetails extends StatelessWidget {
  const _EmptyDetails();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kJBorder),
      ),
      child: const Column(
        children: [
          Icon(Icons.spa_rounded, size: 30, color: kJMuted),
          SizedBox(height: 10),
          Text(
            'لا توجد تفاصيل إضافية لهذا النشاط',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kJMuted,
            ),
          ),
        ],
      ),
    );
  }
}
