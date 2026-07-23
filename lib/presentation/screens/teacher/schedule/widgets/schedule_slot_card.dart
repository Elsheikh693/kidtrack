import '../../../../../index/index_main.dart';

class ScheduleSlotCard extends StatelessWidget {
  const ScheduleSlotCard({
    super.key,
    required this.slot,
    required this.controller,
    this.onEdit,
    this.onDelete,
  });

  final ScheduleModel slot;
  final TeacherWeeklyScheduleController controller;
  // Null for the teacher (read-only): the manager owns the timetable now, so the
  // per-slot edit/delete menu is hidden when no callbacks are supplied.
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  static Color accentForType(String type) => switch (type) {
        'lesson' => AppColors.activityBlue,
        'break' => AppColors.activityAmberBrand,
        'outdoor' => AppColors.activityGreen,
        'lunch' => AppColors.activityOrange,
        'nap' => AppColors.activityPurple,
        _ => AppColors.activityMuted,
      };

  static IconData iconForType(String type) => switch (type) {
        'lesson' => Icons.menu_book_rounded,
        'break' => Icons.coffee_rounded,
        'outdoor' => Icons.park_rounded,
        'lunch' => Icons.lunch_dining_rounded,
        'nap' => Icons.bedtime_rounded,
        _ => Icons.event_note_rounded,
      };

  int? _durationMinutes() {
    try {
      final sp = slot.startTime.split(':');
      final ep = slot.endTime.split(':');
      final start = int.parse(sp[0]) * 60 + int.parse(sp[1]);
      final end = int.parse(ep[0]) * 60 + int.parse(ep[1]);
      return end > start ? end - start : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = accentForType(slot.activityType);
    final subject = controller.subjectById(slot.subjectId);
    final duration = _durationMinutes();
    final title = subject?.name ?? 'schedule_activity_${slot.activityType}'.tr;
    final hasNote = slot.note != null && slot.note!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.15)),
        boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 80,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconForType(slot.activityType), color: accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: context.typography.smSemiBold
                              .copyWith(color: AppColors.activitySlate),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (duration != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$duration ${'schedule_min'.tr}',
                            style: context.typography.xsMedium
                                .copyWith(color: accent),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (slot.topic != null && slot.topic!.trim().isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      slot.topic!.trim(),
                      style: context.typography.xsMedium
                          .copyWith(color: accent),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 12, color: AppColors.activityMuted),
                      const SizedBox(width: 4),
                      Text(
                        '${slot.startTime}  –  ${slot.endTime}',
                        style: context.typography.xsRegular
                            .copyWith(color: AppColors.activityMuted),
                      ),
                      if (hasNote) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.activityAmberLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.notes_rounded,
                                  size: 10, color: AppColors.activityAmber),
                              const SizedBox(width: 3),
                              Text(
                                'schedule_note'.tr,
                                style: context.typography.xsRegular
                                    .copyWith(color: AppColors.activityAmber),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (onEdit != null || onDelete != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded,
                  color: AppColors.activityMuted, size: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              onSelected: (v) {
                if (v == 'edit') onEdit?.call();
                if (v == 'delete') onDelete?.call();
              },
              itemBuilder: (_) => [
                if (onEdit != null)
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      const Icon(Icons.edit_rounded, size: 16),
                      const SizedBox(width: 8),
                      Text('schedule_edit'.tr),
                    ]),
                  ),
                if (onDelete != null)
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      const Icon(Icons.delete_rounded,
                          size: 16, color: AppColors.activityRed),
                      const SizedBox(width: 8),
                      Text('schedule_delete'.tr,
                          style: const TextStyle(color: AppColors.activityRed)),
                    ]),
                  ),
              ],
            )
          else
            const SizedBox(width: 12),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
