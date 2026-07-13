import '../../../../../index/index_main.dart';

class AttendanceSection extends StatelessWidget {
  final ChildProfileController controller;
  const AttendanceSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: 'child_profile_attendance'.tr,
      onAction: controller.goToAttendance,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Obx(() {
          final days = controller.windowDaysStatus;
          final absent = controller.absentCount;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    absent == 0
                        ? Icons.verified_rounded
                        : Icons.event_busy_rounded,
                    size: 16,
                    color: absent == 0
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFDC2626),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    absent == 0 ? 'لا غياب في هذه الفترة' : 'غاب $absent يوم',
                    style: context.typography.xsMedium.copyWith(
                      color: absent == 0
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFDC2626),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // A whole month is too many dots to line up, so summarise it as
              // present / late / absent totals instead of a per-day row.
              if (controller.isMonthView)
                Row(
                  children: [
                    _StatChip(
                      label: 'حضر',
                      count: controller.presentCount,
                      color: const Color(0xFF16A34A),
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      label: 'متأخر',
                      count: controller.lateCount,
                      color: const Color(0xFFD97706),
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      label: 'غاب',
                      count: absent,
                      color: const Color(0xFFDC2626),
                    ),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: days.length > 3
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.start,
                  children: [
                    for (final e in days)
                      Padding(
                        padding:
                            EdgeInsets.only(left: days.length <= 3 ? 14 : 0),
                        child: _DayDot(dateKey: e.key, status: e.value),
                      ),
                  ],
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: context.typography.mdBold.copyWith(color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: context.typography.xsMedium.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  final String dateKey;
  final String status;
  const _DayDot({required this.dateKey, required this.status});

  Color get _color {
    switch (status) {
      case 'present': return const Color(0xFF16A34A); // green
      case 'late': return const Color(0xFFD97706); // amber
      case 'absent': return const Color(0xFFDC2626); // red
      case 'not_arrived': return const Color(0xFFCBD5E1); // gray (today, pending)
      case 'holiday': return const Color(0xFFC7D2FE); // indigo (weekly day off)
      default: return const Color(0xFFE2E8F0); // future / unknown
    }
  }

  @override
  Widget build(BuildContext context) {
    final parts = dateKey.split('-');
    final day = parts.length == 3 ? parts[2] : '';
    return Column(
      children: [
        Text(
          day,
          style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
        ),
        const SizedBox(height: 4),
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
        ),
      ],
    );
  }
}
