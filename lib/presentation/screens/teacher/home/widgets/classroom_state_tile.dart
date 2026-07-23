import '../../../../../index/index_main.dart';
import '../../../../../Global/widgets/event_options_sheet.dart';

/// One child row inside the classroom-states sheet: avatar with a live presence
/// dot, name, a presence line, and either a check-in button (absent) or a state
/// pill to move the child between states (sleeping, eating, back to class…).
class ClassroomStateTile extends StatelessWidget {
  const ClassroomStateTile({
    super.key,
    required this.controller,
    required this.child,
  });

  final ClassroomStatesController controller;
  final ChildModel child;

  static const _green = Color(0xFF16A34A);
  static const _ink = Color(0xFF1E293B);
  static const _muted = Color(0xFF94A3B8);
  static const _purple = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    final childId = child.key ?? '';
    return Obx(() {
      final checkedIn = controller.isCheckedIn(childId);
      final currentId = controller.stateIdFor(childId);
      final statusTemplates =
          controller.templates.where((t) => t.isStatus).toList();
      final eventTemplates =
          controller.templates.where((t) => t.isEvent).toList();

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: checkedIn ? Colors.white : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEF2F6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Row(
          children: [
            // Avatar + presence dot
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: _purple.withValues(alpha: 0.1),
                  backgroundImage: child.profileImage != null
                      ? appCachedImageProvider(child.profileImage!)
                      : null,
                  child: child.profileImage == null
                      ? Text(
                          child.firstName.isNotEmpty ? child.firstName[0] : '?',
                          style: context.typography.mdBold
                              .copyWith(color: _purple),
                        )
                      : null,
                ),
                if (checkedIn)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: _green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Name + presence line
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    child.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.typography.smSemiBold
                        .copyWith(color: checkedIn ? _ink : _muted),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: checkedIn ? _green : _muted,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        checkedIn
                            ? 'child_state_present'.tr
                            : 'child_state_not_present'.tr,
                        style: context.typography.xsMedium
                            .copyWith(color: checkedIn ? _green : _muted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Trailing action
            if (!checkedIn)
              GestureDetector(
                onTap: () => controller.markChildPresent(childId),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _green.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.login_rounded, size: 15, color: _green),
                      const SizedBox(width: 5),
                      Text(
                        'teacher_activity_checkin'.tr,
                        style: context.typography.xsMedium
                            .copyWith(color: _green),
                      ),
                    ],
                  ),
                ),
              )
            else
              ChildStateDropdown(
                currentId: currentId,
                templates: statusTemplates,
                currentLabel: controller.stateLabelFor(childId),
                onChanged: (stateId, stateTitle) =>
                    controller.updateState(childId, stateId, stateTitle),
              ),
          ],
        ),
        // Quick instant-event chips — one tap logs the event, no revert.
        if (checkedIn && eventTemplates.isNotEmpty) ...[
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(right: 60),
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
                        controller.updateState(childId, t.key ?? '', t.title);
                      } else {
                        showEventOptionsSheet(
                          context: context,
                          template: t,
                          onPick: (title) => controller.updateState(
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
