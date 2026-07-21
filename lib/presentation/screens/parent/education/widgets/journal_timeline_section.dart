import 'package:flutter/material.dart';
import '../../../../../Global/widgets/app_network_image.dart';
import '../controller.dart';
import 'journal_meta.dart';
import 'activity_detail_sheet.dart';
import 'session_note_button.dart';

/// Time-ordered list of the child's activities for the selected day.
class JournalTimelineSection extends StatelessWidget {
  const JournalTimelineSection({
    super.key,
    required this.items,
    this.enableNotes = false,
  });
  final List<DayTimelineItem> items;

  /// When true, each activity card shows the guardian's "add your note" action.
  /// Only the main Link Book tab (education view) opts in — the Link Book
  /// history day pages stay read-only.
  final bool enableNotes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    size: 15, color: Color(0xFF2563EB)),
              ),
              const SizedBox(width: 9),
              const Text(
                'أنشطة اليوم',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800, color: kJInk),
              ),
              const SizedBox(width: 8),
              if (items.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${items.length}',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2563EB)),
                  ),
                ),
            ],
          ),
        ),
        if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: _EmptyTimeline(),
          )
        else
          for (int i = 0; i < items.length; i++)
            _TimelineTile(
              item: items[i],
              isLast: i == items.length - 1,
              enableNotes: enableNotes,
            ),
      ],
    );
  }
}

class _EmptyTimeline extends StatelessWidget {
  const _EmptyTimeline();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kJBorder),
      ),
      child: const Column(
        children: [
          Icon(Icons.event_busy_rounded, size: 30, color: kJMuted),
          SizedBox(height: 10),
          Text(
            'لم يتم تسجيل أنشطة لهذا اليوم',
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: kJMuted),
          ),
        ],
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({
    required this.item,
    required this.isLast,
    this.enableNotes = false,
  });
  final DayTimelineItem item;
  final bool isLast;
  final bool enableNotes;

  @override
  Widget build(BuildContext context) {
    final color = journalSubjectColor(item.subjectId ?? item.subjectName);
    final eventIcon = journalEventIcon(item.subjectName);
    final eval = item.evalLevel == null ? null : evalChipMeta(item.evalLevel!);
    final showTitle = item.title.trim().toLowerCase() !=
        item.subjectName.trim().toLowerCase();

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── timeline spine ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(right: 12, left: 18),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.35),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: const Color(0xFFE2E8F0),
                    ),
                  ),
              ],
            ),
          ),
          // ── activity card ───────────────────────────────────────
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => showActivityDetailSheet(context, item),
              child: Container(
              margin: EdgeInsets.only(left: 16, bottom: isLast ? 0 : 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kJBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Center(
                          child: Icon(eventIcon, size: 19, color: color),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (showTitle) ...[
                                  Flexible(
                                    child: Text(
                                      item.subjectName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w800,
                                          color: color),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text('·',
                                      style: TextStyle(color: kJMuted)),
                                  const SizedBox(width: 6),
                                ],
                                Text(
                                  journalClock(item.startedAt),
                                  style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: kJMuted),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.title,
                              style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: kJInk),
                            ),
                          ],
                        ),
                      ),
                      if (eval != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            color: eval.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(eval.icon, size: 13, color: eval.color),
                              const SizedBox(width: 4),
                              Text(
                                eval.label,
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: eval.color),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (item.photos.isNotEmpty) ...[
                    const SizedBox(height: 11),
                    _ActivityPhotos(
                      photos: item.photos,
                      onTap: () => showActivityDetailSheet(context, item),
                    ),
                  ],
                  if (item.note != null && item.note!.trim().isNotEmpty) ...[
                    const SizedBox(height: 11),
                    _CommentBox(text: item.note!.trim()),
                  ],
                  if (enableNotes) SessionNoteButton(item: item),
                ],
              ),
            ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline strip of the activity's photos shown directly inside the day's
/// timeline card — so each activity carries its own pictures. Tapping any
/// thumbnail opens the full activity detail (with the zoomable photo block).
class _ActivityPhotos extends StatelessWidget {
  const _ActivityPhotos({required this.photos, required this.onTap});
  final List<String> photos;
  final VoidCallback onTap;

  static const _max = 4;

  @override
  Widget build(BuildContext context) {
    final shown = photos.take(_max).toList();
    final overflow = photos.length - shown.length;
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: shown.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final isLast = i == shown.length - 1;
          return GestureDetector(
            onTap: onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image(
                      image: appCachedImageProvider(shown[i]),
                      fit: BoxFit.cover,
                      loadingBuilder: (ctx, child, progress) => progress == null
                          ? child
                          : Container(color: const Color(0xFFEFF2F6)),
                      errorBuilder: (ctx, _, __) => Container(
                        color: const Color(0xFFEFF2F6),
                        child: const Icon(Icons.image_not_supported_rounded,
                            size: 18, color: kJMuted),
                      ),
                    ),
                    if (isLast && overflow > 0)
                      Container(
                        color: Colors.black.withValues(alpha: 0.5),
                        alignment: Alignment.center,
                        child: Text(
                          '+$overflow',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CommentBox extends StatelessWidget {
  const _CommentBox({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kJBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.chat_bubble_outline_rounded,
                  size: 13, color: Color(0xFF7C3AED)),
              SizedBox(width: 6),
              Text(
                'تعليق المعلمة',
                style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF7C3AED)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: const TextStyle(
                fontSize: 12.5, height: 1.55, color: Color(0xFF334155)),
          ),
        ],
      ),
    );
  }
}
