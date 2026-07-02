import '../../../../../index/index_main.dart';
import 'idle_timeline_tile.dart';

class IdleTodayTimeline extends StatelessWidget {
  const IdleTodayTimeline({
    super.key,
    required this.completed,
    required this.upcoming,
    required this.ctrl,
    required this.onStartSchedule,
  });

  final List<ClassroomActivityModel> completed;
  final List<ScheduleModel> upcoming;
  final TeacherActivityController ctrl;
  final void Function(ScheduleModel) onStartSchedule;

  @override
  Widget build(BuildContext context) {
    if (completed.isEmpty && upcoming.isEmpty) return const SizedBox.shrink();

    final totalItems = completed.length + upcoming.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section header ───────────────────────────────────────────────
          Row(
            children: [
              const Icon(
                Icons.format_list_bulleted_rounded,
                size: 15,
                color: AppColors.textSecondaryParagraph,
              ),
              const SizedBox(width: 6),
              Text(
                'أنشطة اليوم',
                style: context.typography.smSemiBold.copyWith(
                  color: AppColors.textSecondaryParagraph,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.backgroundNeutralDefault,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$totalItems',
                  style: context.typography.xsMedium.copyWith(
                    color: AppColors.textSecondaryParagraph,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Timeline items ───────────────────────────────────────────────
          ...List.generate(totalItems, (i) {
            final isLast = i == totalItems - 1;
            if (i < completed.length) {
              final a = completed[i];
              final timeLabel = _epochToTime(a.startedAt);
              final evalCount = a.evaluations.length;
              final total = a.childIds.length;
              final evalLabel =
                  evalCount > 0 ? '$evalCount/$total تقييم' : null;
              return IdleTimelineTile(
                key: ValueKey('comp_${a.key ?? i}'),
                type: IdleTimelineTileType.completed,
                title: a.title,
                timeLabel: timeLabel,
                subtitleLabel: a.subjectName,
                trailingLabel: evalLabel,
                isLast: isLast,
              );
            }
            final si = i - completed.length;
            final s = upcoming[si];
            final isNext = si == 0;
            final title = ctrl.scheduleTitle(s);
            final trailingLabel =
                isNext ? _countdown(s.startTime) : null;
            return IdleTimelineTile(
              key: ValueKey('sched_${s.key ?? i}'),
              type: isNext
                  ? IdleTimelineTileType.next
                  : IdleTimelineTileType.upcoming,
              title: title,
              timeLabel: s.startTime,
              trailingLabel: trailingLabel,
              isLast: isLast,
              onStart: isNext ? () => onStartSchedule(s) : null,
            );
          }),
        ],
      ),
    );
  }

  static String _epochToTime(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  static String _countdown(String startTime) {
    final parts = startTime.split(':');
    if (parts.length < 2) return startTime;
    final now = DateTime.now();
    final target = DateTime(
      now.year,
      now.month,
      now.day,
      int.tryParse(parts[0]) ?? 0,
      int.tryParse(parts[1]) ?? 0,
    );
    final diff = target.difference(now).inMinutes;
    if (diff <= 0) return 'الآن';
    if (diff < 60) return 'يبدأ خلال $diff دقيقة';
    final h = (diff / 60).floor();
    final m = diff % 60;
    return m == 0 ? 'يبدأ خلال $h ساعة' : 'يبدأ خلال $hس $mد';
  }
}
