import '../../../../../index/index_main.dart';
import '../../../../../Global/widgets/event_options_sheet.dart';

/// One child row inside the activity states section: avatar, name, a status pill
/// (persistent states: sleeping / bus / back to class…) and a row of quick
/// EVENT chips (toilet, ate, water…) that log an instant event in one tap
/// without changing the child's state — so nothing ever needs reverting.
class ActivityStateCard extends StatelessWidget {
  const ActivityStateCard({
    super.key,
    required this.ctrl,
    required this.child,
  });

  final TeacherActivityController ctrl;
  final ChildModel child;

  @override
  Widget build(BuildContext context) {
    final childId = child.key ?? '';
    return Obx(() {
      final checkedIn = ctrl.isCheckedIn(childId);
      final currentId = ctrl.stateIdFor(childId);
      final statusTemplates =
          ctrl.stateTemplates.where((t) => t.isStatus).toList();
      final eventTemplates =
          ctrl.stateTemplates.where((t) => t.isEvent).toList();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Opacity(
                  opacity: checkedIn ? 1.0 : 0.45,
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor:
                        const Color(0xFF7C3AED).withValues(alpha: 0.1),
                    backgroundImage: child.profileImage != null
                        ? appCachedImageProvider(child.profileImage!)
                        : null,
                    child: child.profileImage == null
                        ? Text(
                            child.firstName.isNotEmpty
                                ? child.firstName[0]
                                : '?',
                            style: context.typography.mdBold.copyWith(
                              color: const Color(0xFF7C3AED),
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Opacity(
                    opacity: checkedIn ? 1.0 : 0.45,
                    child: Text(
                      child.fullName,
                      style: context.typography.smSemiBold.copyWith(
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ),
                if (!checkedIn)
                  GestureDetector(
                    onTap: () => ctrl.markChildPresent(childId),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF16A34A).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.login_rounded,
                              size: 15, color: Color(0xFF16A34A)),
                          const SizedBox(width: 5),
                          Text(
                            'teacher_activity_checkin'.tr,
                            style: context.typography.xsMedium
                                .copyWith(color: const Color(0xFF16A34A)),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ChildStateDropdown(
                    currentId: currentId,
                    templates: statusTemplates,
                    currentLabel: ctrl.stateLabelFor(childId),
                    onChanged: (stateId, stateTitle) =>
                        ctrl.updateChildState(childId, stateId, stateTitle),
                  ),
              ],
            ),
            // Quick instant-event chips — one tap logs the event, no revert.
            if (checkedIn && eventTemplates.isNotEmpty) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(right: 56),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final t in eventTemplates)
                      _EventChip(
                        icon: ChildStateIcons.iconFor(t.icon),
                        label: t.title,
                        onTap: () {
                          if (t.options.isEmpty) {
                            ctrl.updateChildState(childId, t.key ?? '', t.title);
                          } else {
                            showEventOptionsSheet(
                              context: context,
                              template: t,
                              onPick: (title) => ctrl.updateChildState(
                                  childId, t.key ?? '', title),
                            );
                          }
                        },
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _EventChip extends StatelessWidget {
  const _EventChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: const Color(0xFF475569)),
            const SizedBox(width: 5),
            Text(
              label,
              style: context.typography.xsMedium
                  .copyWith(color: const Color(0xFF334155)),
            ),
          ],
        ),
      ),
    );
  }
}
