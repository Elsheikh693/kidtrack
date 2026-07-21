import '../../../../../index/index_main.dart';
import 'activity_state_card.dart';
import '../../home/widgets/class_bulk_actions_bar.dart';

/// Inline section on the active activity screen listing every child in the
/// classroom with their live state, so the teacher can update states (sleeping,
/// eating, back to class…) without leaving the activity.
class ActivityStatesSection extends StatelessWidget {
  const ActivityStatesSection({super.key, required this.ctrl});

  final TeacherActivityController ctrl;

  static const _accent = Color(0xFF16A34A);

  Widget _summ(BuildContext context, int count, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text('$count',
                style: context.typography.smSemiBold
                    .copyWith(color: color, fontSize: 17)),
            const SizedBox(height: 2),
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.typography.xsRegular
                    .copyWith(color: const Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEF2F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.groups_rounded,
                      color: _accent, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'teacher_activity_states_title'.tr,
                        style: context.typography.smSemiBold
                            .copyWith(color: const Color(0xFF1E293B)),
                      ),
                      Obx(() {
                        final name = ctrl.currentTeacherName.value;
                        if (name.isEmpty) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Row(
                            children: [
                              const Icon(Icons.person_outline_rounded,
                                  size: 13, color: Color(0xFF94A3B8)),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  '${'classroom_teacher_label'.tr}: $name',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.typography.xsRegular
                                      .copyWith(color: const Color(0xFF94A3B8)),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                // Present-now count (checked-in children), not the whole roster.
                Obx(() => Text(
                      '${ctrl.presentStateCount}',
                      style: context.typography.xsBold
                          .copyWith(color: _accent),
                    )),
              ],
            ),
          ),
          const Divider(height: 1),
          // Summary first — read the class at a glance before the detail.
          Obx(() => Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 2),
                child: Row(
                  children: [
                    _summ(context, ctrl.inActivityCount,
                        'teacher_activity_summary_in'.tr, _accent),
                    const SizedBox(width: 8),
                    _summ(context, ctrl.attentionStateCount,
                        'teacher_activity_summary_attention'.tr,
                        const Color(0xFFF59E0B)),
                    const SizedBox(width: 8),
                    _summ(context, ctrl.absentStateCount,
                        'teacher_activity_summary_absent'.tr,
                        const Color(0xFF94A3B8)),
                  ],
                ),
              )),
          // Class-level bulk actions (نوم للكل / الكل مع الفصل).
          Obx(() {
            if (ctrl.presentStateCount == 0) return const SizedBox.shrink();
            return ClassBulkActionsBar(
              statuses: ctrl.stateTemplates.where((t) => t.isStatus).toList(),
              onApply: ctrl.applyStatusToAllStates,
              onReturnAll: ctrl.returnAllStatesToClass,
            );
          }),
          Obx(() {
            if (ctrl.stateChildren.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'child_state_no_children'.tr,
                    style: context.typography.smRegular
                        .copyWith(color: const Color(0xFF94A3B8)),
                  ),
                ),
              );
            }
            // Always show every child (attention-first) — never fold anyone
            // behind a toggle.
            final list = ctrl.sortedStateChildren;
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: list.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, indent: 72),
              itemBuilder: (_, i) =>
                  ActivityStateCard(ctrl: ctrl, child: list[i]),
            );
          }),
        ],
      ),
    );
  }
}
