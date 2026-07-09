import '../../../../../index/index_main.dart';
import '../teacher_activity_controller.dart';
import 'activity_state_card.dart';

/// Inline section on the active activity screen listing every child in the
/// classroom with their live state, so the teacher can update states (sleeping,
/// eating, back to class…) without leaving the activity.
class ActivityStatesSection extends StatelessWidget {
  const ActivityStatesSection({super.key, required this.ctrl});

  final TeacherActivityController ctrl;

  static const _accent = Color(0xFF16A34A);

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
                  child: Text(
                    'teacher_activity_states_title'.tr,
                    style: context.typography.smSemiBold
                        .copyWith(color: const Color(0xFF1E293B)),
                  ),
                ),
                Obx(() => Text(
                      '${ctrl.children.length}',
                      style: context.typography.xsBold
                          .copyWith(color: _accent),
                    )),
              ],
            ),
          ),
          const Divider(height: 1),
          Obx(() {
            final list = ctrl.sortedStateChildren;
            if (list.isEmpty) {
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
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: list.length,
              separatorBuilder: (_, __) =>
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
