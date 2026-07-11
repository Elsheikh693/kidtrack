import '../../../../../index/index_main.dart';
import '../teacher_activity_controller.dart';

/// One child row inside the activity states section: avatar, name and a state
/// pill to move the child in/out of a state (sleeping, eating, back to class…).
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

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
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
                        child.firstName.isNotEmpty ? child.firstName[0] : '?',
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
                templates: ctrl.stateTemplates,
                currentLabel: ctrl.stateLabelFor(childId),
                onChanged: (stateId, stateTitle) =>
                    ctrl.updateChildState(childId, stateId, stateTitle),
              ),
          ],
        ),
      );
    });
  }
}
