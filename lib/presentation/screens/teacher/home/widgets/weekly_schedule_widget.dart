import '../../../../../index/index_main.dart';

class WeeklyScheduleWidget extends StatefulWidget {
  const WeeklyScheduleWidget({super.key});

  @override
  State<WeeklyScheduleWidget> createState() => _WeeklyScheduleWidgetState();
}

class _WeeklyScheduleWidgetState extends State<WeeklyScheduleWidget> {
  late final TeacherWeeklyScheduleController _c;

  @override
  void initState() {
    super.initState();
    _c = Get.find<TeacherWeeklyScheduleController>();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(teacherWeeklyScheduleView),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.activityGreen.withValues(alpha: 0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.activityGreen.withValues(alpha: 0.07),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            Obx(() => _buildBody(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.activityGreen.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.calendar_view_week_rounded,
              color: AppColors.activityGreen,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'teacher_schedule_widget_title'.tr,
                  style: context.typography.smSemiBold
                      .copyWith(color: AppColors.activitySlate),
                ),
                Text(
                  'schedule_day_${TeacherWeeklyScheduleController.todayKey}'
                      .tr,
                  style: context.typography.xsRegular
                      .copyWith(color: AppColors.activityMuted),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.activityMuted,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    // Reading isLoading ensures this rebuilds after schedules finish loading,
    // since _scheduleMap is a plain Map (not reactive) and only gets populated
    // after _loadSchedules() completes — which runs after selectedClassroom is set.
    final loading = _c.isLoading.value;
    final classroom = _c.selectedClassroom.value;
    if (loading || classroom == null) return _buildEmpty(context);

    final slots = _c.slotsForTodayInClassroom(classroom.key ?? '');
    if (slots.isEmpty) return _buildEmpty(context);

    final shown = slots.take(3).toList();
    final extra = slots.length - 3;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        children: [
          ...shown.map((slot) => _buildSlotRow(context, slot)),
          if (extra > 0) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '+$extra ${'teacher_schedule_widget_more'.tr}',
                  style: context.typography.xsMedium
                      .copyWith(color: AppColors.activityGreen),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.chevron_right,
                  size: 14,
                  color: AppColors.activityGreen,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSlotRow(BuildContext context, ScheduleModel slot) {
    final accent = ScheduleSlotCard.accentForType(slot.activityType);
    final subject = _c.subjectById(slot.subjectId);
    final title =
        subject?.name ?? 'schedule_activity_${slot.activityType}'.tr;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              ScheduleSlotCard.iconForType(slot.activityType),
              size: 15,
              color: accent,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: context.typography.smRegular
                  .copyWith(color: AppColors.activitySlate),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${slot.startTime} – ${slot.endTime}',
            style: context.typography.xsRegular
                .copyWith(color: AppColors.activityMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          const Icon(
            Icons.event_busy_rounded,
            size: 16,
            color: AppColors.activityMuted,
          ),
          const SizedBox(width: 8),
          Text(
            'teacher_schedule_widget_empty'.tr,
            style: context.typography.xsRegular
                .copyWith(color: AppColors.activityMuted),
          ),
        ],
      ),
    );
  }
}
