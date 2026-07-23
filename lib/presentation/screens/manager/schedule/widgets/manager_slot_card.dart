import '../../../../../index/index_main.dart';

/// One timetable slot in the manager editor: a colour-accented card showing the
/// time, subject, assigned teacher and the optional lesson topic. Tap to edit;
/// the ⋮ menu edits or deletes.
class ManagerSlotCard extends StatelessWidget {
  const ManagerSlotCard({
    super.key,
    required this.slot,
    required this.controller,
    required this.onTap,
  });

  final ScheduleModel slot;
  final ManagerScheduleController controller;
  final VoidCallback onTap;

  // A stable per-subject colour so the same subject always reads the same.
  static const _palette = [
    AppColors.activityBlue,
    AppColors.activityGreen,
    AppColors.activityPurple,
    AppColors.activityOrange,
    AppColors.activityAmber,
  ];

  Color get _accent {
    final seed = (slot.subjectId ?? slot.topic ?? slot.startTime);
    return _palette[seed.hashCode.abs() % _palette.length];
  }

  int? get _durationMinutes {
    final s = _toMin(slot.startTime);
    final e = _toMin(slot.endTime);
    if (s == null || e == null || e <= s) return null;
    return e - s;
  }

  static int? _toMin(String hhmm) {
    final p = hhmm.split(':');
    if (p.length < 2) return null;
    final h = int.tryParse(p[0]);
    final m = int.tryParse(p[1]);
    if (h == null || m == null) return null;
    return h * 60 + m;
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accent;
    final subject = controller.subjectName(slot.subjectId);
    final teacher = controller.teacherName(slot.teacherId);
    final topic = slot.topic?.trim() ?? '';
    final hasTopic = topic.isNotEmpty;
    final title =
        subject.isNotEmpty ? subject : 'schedule_activity_${slot.activityType}'.tr;
    final duration = _durationMinutes;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.08),
              blurRadius: 16.r,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Accent spine (leading edge in RTL).
              Container(
                width: 5.w,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(20.r),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(12.w, 12.h, 14.w, 12.h),
                  child: Row(
                    children: [
                      _TimePill(
                        start: slot.startTime,
                        end: slot.endTime,
                        accent: accent,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    title,
                                    style: context.typography.smSemiBold
                                        .copyWith(color: AppColors.textDefault),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (duration != null) ...[
                                  SizedBox(width: 6.w),
                                  Text(
                                    '$duration ${'schedule_min'.tr}',
                                    style: context.typography.xsRegular.copyWith(
                                      color: AppColors.textSecondaryParagraph,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              hasTopic ? topic : 'schedule_topic_teacher_fills'.tr,
                              style: context.typography.xsMedium.copyWith(
                                color:
                                    hasTopic ? accent : AppColors.activityMuted,
                                fontStyle:
                                    hasTopic ? null : FontStyle.italic,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (teacher.isNotEmpty) ...[
                              SizedBox(height: 5.h),
                              Row(
                                children: [
                                  Icon(Icons.person_rounded,
                                      size: 13.sp,
                                      color: AppColors.activityMuted),
                                  SizedBox(width: 4.w),
                                  Flexible(
                                    child: Text(
                                      teacher,
                                      style: context.typography.xsRegular
                                          .copyWith(
                                              color: AppColors.activityMuted),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      _Menu(
                        onEdit: onTap,
                        onDelete: () => _confirmDelete(context),
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

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r)),
        title: Text('schedule_delete_confirm_title'.tr,
            style: context.typography.lgBold),
        content: Text('schedule_delete_confirm_body'.tr,
            style: context.typography.smRegular),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('cancel'.tr,
                style: context.typography.smMedium
                    .copyWith(color: AppColors.textSecondaryParagraph)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteSlot(slot);
            },
            child: Text('delete'.tr,
                style: context.typography.smSemiBold
                    .copyWith(color: AppColors.errorForeground)),
          ),
        ],
      ),
    );
  }
}

class _TimePill extends StatelessWidget {
  const _TimePill({
    required this.start,
    required this.end,
    required this.accent,
  });

  final String start;
  final String end;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58.w,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        children: [
          Text(start,
              style: context.typography.smSemiBold.copyWith(color: accent)),
          Container(
            margin: EdgeInsets.symmetric(vertical: 3.h),
            width: 16.w,
            height: 1,
            color: accent.withValues(alpha: 0.3),
          ),
          Text(end,
              style: context.typography.xsRegular
                  .copyWith(color: AppColors.textSecondaryParagraph)),
        ],
      ),
    );
  }
}

class _Menu extends StatelessWidget {
  const _Menu({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded,
          size: 20.sp, color: AppColors.activityMuted),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(children: [
            Icon(Icons.edit_rounded, size: 16.sp, color: AppColors.textDefault),
            SizedBox(width: 8.w),
            Text('schedule_edit'.tr),
          ]),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(Icons.delete_outline_rounded,
                size: 16.sp, color: AppColors.errorForeground),
            SizedBox(width: 8.w),
            Text('schedule_delete'.tr,
                style: const TextStyle(color: AppColors.errorForeground)),
          ]),
        ),
      ],
    );
  }
}
