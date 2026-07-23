import '../../../../../index/index_main.dart';
import '../../../parent/education/widgets/journal_meta.dart';

/// The heart of the redesigned child profile: every activity the child actually
/// attended in the selected window, each with the teacher's evaluation, her
/// per-child comment, any general note, the linked homework and the photos.
class ActivitiesSection extends StatelessWidget {
  final ChildProfileController controller;
  const ActivitiesSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: 'childrenpr12_activities_attended'.tr,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
        child: Obx(() {
          if (controller.isRangeLoading.value) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                ),
              ),
            );
          }
          final items = controller.activities;
          if (items.isEmpty) return const _Empty();
          return Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                _ActivityCard(
                  activity: items[i],
                  childId: controller.childId,
                  homework: controller.homeworkForActivity(items[i]),
                ),
              ],
            ],
          );
        }),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(Icons.spa_rounded, size: 28, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text(
            'childrenpr12_activities_empty'.tr,
            style: context.typography.xsMedium
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final ClassroomActivityModel activity;
  final String childId;
  final List<HomeworkModel> homework;
  const _ActivityCard({
    required this.activity,
    required this.childId,
    required this.homework,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        journalSubjectColor(activity.subjectId ?? activity.subjectName ?? activity.title);
    final icon = journalEventIcon(activity.subjectName ?? activity.title);
    final subject = activity.subjectName?.isNotEmpty == true
        ? activity.subjectName!
        : activity.title;
    final evalKey = activity.evaluations[childId];
    final eval = evalKey == null ? null : evalChipMeta(evalKey);
    final reasons =
        (activity.childReasons[childId] ?? const []).where((r) => r.trim().isNotEmpty).toList();
    final note = activity.notes[childId]?.trim();
    final groupNote = activity.groupNote?.trim();
    final photos = activity.approvedUrlsForChild(childId);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEF0F4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
                  padding: const EdgeInsets.all(13),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(icon, color: color, size: 22),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  subject,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.typography.smSemiBold
                                      .copyWith(color: AppColors.textDefault),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  journalClock(activity.startedAt),
                                  style: context.typography.xsRegular.copyWith(
                                      color: AppColors.textSecondaryParagraph),
                                ),
                              ],
                            ),
                          ),
                          if (eval != null) _EvalPill(eval: eval),
                        ],
                      ),
                      if (reasons.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final r in reasons)
                              _Chip(text: r, color: eval?.color ?? color),
                          ],
                        ),
                      ],
                      if (note != null && note.isNotEmpty)
                        _NoteRow(
                          icon: Icons.chat_bubble_rounded,
                          title: 'childrenpr12_teacher_comment'.tr,
                          text: note,
                          color: const Color(0xFF7C3AED),
                        ),
                      if (groupNote != null && groupNote.isNotEmpty)
                        _NoteRow(
                          icon: Icons.campaign_rounded,
                          title: 'childrenpr12_group_note'.tr,
                          text: groupNote,
                          color: const Color(0xFFD97706),
                        ),
                      if (homework.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        for (int i = 0; i < homework.length; i++) ...[
                          if (i > 0) const SizedBox(height: 6),
                          _HomeworkRow(item: homework[i]),
                        ],
                      ],
                      if (photos.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _PhotoStrip(urls: photos),
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

class _EvalPill extends StatelessWidget {
  final ({String label, Color color, IconData icon}) eval;
  const _EvalPill({required this.eval});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
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
              fontWeight: FontWeight.w700,
              color: eval.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  const _Chip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_rounded, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  final Color color;
  const _NoteRow({
    required this.icon,
    required this.title,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
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
              height: 1.5,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeworkRow extends StatelessWidget {
  final HomeworkModel item;
  const _HomeworkRow({required this.item});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF8E44AD);
    final title = item.title.trim().isNotEmpty
        ? item.title.trim()
        : (item.subjectName ?? 'childrenpr12_homework_fallback'.tr);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          const Icon(Icons.assignment_rounded, size: 17, color: accent),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (item.description != null &&
                    item.description!.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.description!.trim(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoStrip extends StatelessWidget {
  final List<String> urls;
  const _PhotoStrip({required this.urls});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) => GestureDetector(
          onTap: () => _openViewer(context, urls[i]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AppNetworkImage(
              url: urls[i],
              width: 64,
              height: 64,
            ),
          ),
        ),
      ),
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
