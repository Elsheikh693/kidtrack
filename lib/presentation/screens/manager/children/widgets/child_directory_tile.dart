import '../../../../../index/index_main.dart';
import '../../widgets/child_initial_avatar.dart';

/// A single child row in the directory list: avatar, name, classroom.
class ChildDirectoryTile extends StatelessWidget {
  const ChildDirectoryTile({
    super.key,
    required this.child,
    required this.classroomName,
    required this.onTap,
  });

  final ChildModel child;
  final String classroomName;
  final VoidCallback onTap;

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
            Icon(Icons.arrow_forward_ios_outlined,
                size: 13, color: AppColors.grayMedium),
          ],
        ),
      ),
    );
  }
}
