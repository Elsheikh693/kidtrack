import 'package:flutter/material.dart';
import '../../../../Global/widgets/app_network_image.dart';
import '../education/widgets/journal_meta.dart';
import 'link_book_controller.dart';
import 'widgets/photo_gallery_viewer.dart';

/// One subject's full journey for the child, opened full-screen: a hero with
/// the latest evaluation + development trend + sparkline, then a vertical
/// timeline of every activity — title, comment, evaluation, reasons and photos.
class SubjectHistoryView extends StatelessWidget {
  const SubjectHistoryView({
    super.key,
    required this.subject,
    required this.childName,
  });

  final SubjectHistory subject;
  final String childName;

  String get _firstName =>
      childName.trim().isEmpty ? 'طفلك' : childName.trim().split(' ').first;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kJBg,
        appBar: AppBar(
          backgroundColor: kJBg,
          surfaceTintColor: kJBg,
          elevation: 0,
          centerTitle: true,
          title: Text(
            subject.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: kJInk,
            ),
          ),
          iconTheme: const IconThemeData(color: kJInk),
        ),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _SubjectHero(subject: subject, firstName: _firstName),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                child: Row(
                  children: [
                    const Icon(Icons.timeline_rounded,
                        size: 18, color: Color(0xFF6C4DDB)),
                    const SizedBox(width: 8),
                    const Text(
                      'الخط الزمني',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: kJInk,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${subject.activityCount} نشاط',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: kJMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _TimelineTile(
                    entry: subject.entries[i],
                    color: journalSubjectColor(subject.name),
                    isFirst: i == 0,
                    isLast: i == subject.entries.length - 1,
                  ),
                  childCount: subject.entries.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectHero extends StatelessWidget {
  const _SubjectHero({required this.subject, required this.firstName});
  final SubjectHistory subject;
  final String firstName;

  @override
  Widget build(BuildContext context) {
    final color = journalSubjectColor(subject.name);
    final icon = journalEventIcon(subject.name);
    final latest = subject.latestEval;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.14),
            color.withValues(alpha: 0.04),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: color.withValues(alpha: 0.25)),
                ),
                child: Icon(icon, size: 30, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'رحلة $firstName في',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: kJMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subject.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _HeroStat(
                icon: Icons.auto_awesome_rounded,
                label: 'نشاط',
                value: '${subject.activityCount}',
                color: const Color(0xFF2563EB),
              ),
              const SizedBox(width: 10),
              _HeroStat(
                icon: Icons.photo_camera_rounded,
                label: 'صورة',
                value: '${subject.photoCount}',
                color: const Color(0xFF0EA5E9),
              ),
              if (latest != null) ...[
                const SizedBox(width: 10),
                Expanded(child: _LatestEvalStat(level: latest)),
              ] else
                const Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: kJMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _LatestEvalStat extends StatelessWidget {
  const _LatestEvalStat({required this.level});
  final String level;

  @override
  Widget build(BuildContext context) {
    final m = evalChipMeta(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: m.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(m.icon, size: 16, color: m.color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              m.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: m.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({
    required this.entry,
    required this.color,
    required this.isFirst,
    required this.isLast,
  });
  final SubjectHistoryEntry entry;
  final Color color;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── rail ────────────────────────────────────────────
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 2,
                  height: 8,
                  color: isFirst ? Colors.transparent : kJBorder,
                ),
                Container(
                  width: 13,
                  height: 13,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2.4),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast ? Colors.transparent : kJBorder,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _EntryCard(entry: entry, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry, required this.color});
  final SubjectHistoryEntry entry;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.fromMillisecondsSinceEpoch(entry.startedAt);
    final hasEval = entry.evalLevel != null && entry.evalLevel!.isNotEmpty;
    final note = entry.note?.trim() ?? '';
    final groupNote = entry.groupNote?.trim() ?? '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
              Icon(Icons.event_rounded, size: 13, color: kJMuted),
              const SizedBox(width: 5),
              Text(
                journalDateLabel(date),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: kJMuted,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                journalClock(entry.startedAt),
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: kJMuted.withValues(alpha: 0.8),
                ),
              ),
              const Spacer(),
              if (hasEval) _EvalChip(level: entry.evalLevel!),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            entry.title.isNotEmpty ? entry.title : 'نشاط',
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: kJInk,
              height: 1.3,
            ),
          ),
          if (note.isNotEmpty) ...[
            const SizedBox(height: 10),
            _NoteBlock(
              icon: Icons.chat_bubble_rounded,
              text: note,
              color: color,
            ),
          ],
          if (entry.reasons.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [for (final r in entry.reasons) _ReasonChip(text: r)],
            ),
          ],
          if (groupNote.isNotEmpty) ...[
            const SizedBox(height: 8),
            _NoteBlock(
              icon: Icons.groups_rounded,
              text: groupNote,
              color: const Color(0xFF64748B),
              label: 'ملاحظة للمجموعة',
            ),
          ],
          if (entry.photos.isNotEmpty) ...[
            const SizedBox(height: 11),
            _EntryPhotos(entry: entry),
          ],
        ],
      ),
    );
  }
}

class _NoteBlock extends StatelessWidget {
  const _NoteBlock({
    required this.icon,
    required this.text,
    required this.color,
    this.label,
  });
  final IconData icon;
  final String text;
  final Color color;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 6),
              Text(
                label ?? 'ملاحظة المعلمة',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              height: 1.55,
              fontWeight: FontWeight.w500,
              color: kJInk,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReasonChip extends StatelessWidget {
  const _ReasonChip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF6C4DDB).withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6C4DDB).withValues(alpha: 0.15)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF6C4DDB),
        ),
      ),
    );
  }
}

class _EvalChip extends StatelessWidget {
  const _EvalChip({required this.level});
  final String level;

  @override
  Widget build(BuildContext context) {
    final m = evalChipMeta(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: m.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(m.icon, size: 12, color: m.color),
          const SizedBox(width: 4),
          Text(
            m.label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: m.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryPhotos extends StatelessWidget {
  const _EntryPhotos({required this.entry});
  final SubjectHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final photos = [
      for (final url in entry.photos)
        LinkBookPhoto(
          url: url,
          activityTitle: entry.title.isNotEmpty ? entry.title : 'نشاط',
          takenAt: entry.startedAt,
        ),
    ];

    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: photos.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          return GestureDetector(
            onTap: () =>
                openPhotoGallery(context, photos: photos, initialIndex: i),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Hero(
                tag: 'lbphoto_${photos[i].url}',
                child: Image(
                  image: appCachedImageProvider(photos[i].url),
                  width: 78,
                  height: 78,
                  fit: BoxFit.cover,
                  loadingBuilder: (ctx, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      width: 78,
                      height: 78,
                      color: kJBorder,
                      child: const Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (ctx, err, st) => Container(
                    width: 78,
                    height: 78,
                    color: kJBorder,
                    child: const Icon(Icons.broken_image_rounded,
                        color: kJMuted, size: 22),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
