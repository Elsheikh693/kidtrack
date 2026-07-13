import '../../../../../index/index_main.dart';
import '../../widgets/child_initial_avatar.dart';

/// A single child row in the directory list: avatar, name, classroom.
class ChildDirectoryTile extends StatelessWidget {
  const ChildDirectoryTile({
    super.key,
    required this.child,
    required this.classroomName,
    required this.onTap,
    required this.onChat,
    this.chatUnread = 0,
  });

  final ChildModel child;
  final String classroomName;
  final VoidCallback onTap;
  final VoidCallback onChat;
  final int chatUnread;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.grayLight),
        ),
        child: Row(
          children: [
            ChildInitialAvatar(
              name: child.fullName,
              color: AppColors.activityGreen,
              imageUrl: child.profileImage,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    child.fullName,
                    style: context.typography.smSemiBold
                        .copyWith(color: AppColors.textDefault),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.class_outlined,
                          size: 13, color: AppColors.grayMedium),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          classroomName,
                          style: context.typography.xsRegular.copyWith(
                              color: AppColors.textSecondaryParagraph),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _ChatBtn(unread: chatUnread, onTap: onChat),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_outlined,
                size: 13, color: AppColors.grayMedium),
          ],
        ),
      ),
    );
  }
}

class _ChatBtn extends StatelessWidget {
  final int unread;
  final VoidCallback onTap;

  const _ChatBtn({required this.unread, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 17,
              color: AppColors.primary,
            ),
          ),
          if (unread > 0)
            Positioned(
              top: -4,
              right: -4,
              child: ChatUnreadBadge(count: unread),
            ),
        ],
      ),
    );
  }
}
