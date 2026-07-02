import '../../../../../index/index_main.dart';
import '../../../../../Global/widgets/kidtrack_tab_header.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key, required this.controller});

  final OwnerDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return KidTrackTabHeader(
      titleKey: 'owner_tab_children',
      icon: Icons.child_care_rounded,
      accentColor: const Color(0xFF16A34A),
      subtitle: controller.ownerName,
      trailing: _LogoutButton(onTap: controller.logout),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.28),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.logout_rounded, color: Colors.white, size: 15),
            const SizedBox(width: 5),
            Text(
              'owner_logout'.tr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
