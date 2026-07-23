import '../../../../../index/index_main.dart';
import '../controller.dart';

/// Profile row shown as the account screen's app-bar title:
/// avatar + guardian name + phone. Matches the staff account design.
class AccountHeader extends StatelessWidget {
  const AccountHeader({super.key, required this.controller});

  final ParentAccountController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.person_rounded, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.parentName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.typography.mdBold
                    .copyWith(color: AppColors.textDefault),
              ),
              const SizedBox(height: 2),
              Text(
                controller.parentPhone,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.typography.xsRegular
                    .copyWith(color: AppColors.textSecondaryParagraph),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
