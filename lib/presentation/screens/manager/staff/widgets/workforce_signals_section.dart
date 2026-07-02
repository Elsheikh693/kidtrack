import '../../../../../index/index_main.dart';
import '../../widgets/manager_section_header.dart';
import '../../children/widgets/attention_tile.dart';

/// "Workforce Signals": the manager's staff to-do list — who's absent without
/// leave, leave requests awaiting review, classrooms with no teacher, and
/// teachers not yet assigned to a room. Problems first.
class WorkforceSignalsSection extends StatelessWidget {
  const WorkforceSignalsSection({super.key, required this.controller});

  final ManagerStaffController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final total = controller.absentToday.length +
          controller.pendingLeaves.length +
          controller.coverageGaps.length +
          controller.unassignedTeachers.length;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ManagerSectionHeader(
            title: 'manager_staff_signals_title'.tr,
            icon: Icons.monitor_heart_rounded,
            color: AppColors.activityRed,
            trailing: total > 0 ? '$total' : null,
          ),
          if (!controller.hasSignals)
            _AllClear()
          else ...[
            ..._absentGroup(),
            ..._leaveGroup(),
            ..._coverageGroup(),
            ..._unassignedGroup(),
          ],
        ],
      );
    });
  }

  List<Widget> _absentGroup() {
    if (controller.absentToday.isEmpty) return const [];
    return [
      _GroupLabel(text: 'manager_staff_group_absent'.tr),
      ...controller.absentToday.map((s) => AttentionTile(
            icon: Icons.person_off_rounded,
            color: AppColors.activityRed,
            title: s.name,
            subtitle: s.roleKey.tr,
          )),
    ];
  }

  List<Widget> _leaveGroup() {
    if (controller.pendingLeaves.isEmpty) return const [];
    return [
      _GroupLabel(text: 'manager_staff_group_leaves'.tr),
      ...controller.pendingLeaves.map((l) => AttentionTile(
            icon: Icons.pending_actions_rounded,
            color: AppColors.activityAmberBrand,
            title: l.staffName,
            subtitle: '${l.roleKey.tr} · ${l.typeKey.tr}',
            trailing: 'manager_staff_days'.trParams({'count': '${l.days}'}),
          )),
    ];
  }

  List<Widget> _coverageGroup() {
    if (controller.coverageGaps.isEmpty) return const [];
    return [
      _GroupLabel(text: 'manager_staff_group_coverage'.tr),
      ...controller.coverageGaps.map((c) => AttentionTile(
            icon: Icons.meeting_room_rounded,
            color: AppColors.activityOrange,
            title: c.name,
            subtitle: 'manager_staff_gap_subtitle'.tr,
          )),
    ];
  }

  List<Widget> _unassignedGroup() {
    if (controller.unassignedTeachers.isEmpty) return const [];
    return [
      _GroupLabel(text: 'manager_staff_group_unassigned'.tr),
      ...controller.unassignedTeachers.map((s) => AttentionTile(
            icon: Icons.help_outline_rounded,
            color: AppColors.activityPurple,
            title: s.name,
            subtitle: s.roleKey.tr,
          )),
    ];
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Text(
        text,
        style: context.typography.xsMedium
            .copyWith(color: AppColors.textSecondaryParagraph),
      ),
    );
  }
}

class _AllClear extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 26),
      decoration: BoxDecoration(
        color: AppColors.activityGreenLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.verified_rounded,
              size: 34, color: AppColors.activityGreen),
          const SizedBox(height: 10),
          Text(
            'manager_staff_signals_clear'.tr,
            style: context.typography.smSemiBold
                .copyWith(color: AppColors.activityGreenDark),
          ),
        ],
      ),
    );
  }
}
