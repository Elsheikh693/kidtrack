import '../../../../../index/index_main.dart';
import '../../../shared/logout_helper.dart';

/// Danger-styled logout action for the More tab.
class ManagerLogoutButton extends StatelessWidget {
  const ManagerLogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: showLogoutConfirm,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.errorBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.errorForeground.withValues(alpha: 0.25),
              width: 1.2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded,
                    color: AppColors.errorForeground, size: 20),
                const SizedBox(width: 10),
                Text(
                  'owner_logout'.tr,
                  style: context.typography.mdBold
                      .copyWith(color: AppColors.errorForeground),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
