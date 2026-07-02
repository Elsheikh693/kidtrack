import '../../index/index_main.dart';

class TeacherClassicAppBar extends StatelessWidget {
  const TeacherClassicAppBar({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 64,
      titleSpacing: 20,
      title: Row(
        children: [
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.activityGreen,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: context.typography.lgBold.copyWith(
              color: AppColors.activitySlate,
            ),
          ),
        ],
      ),
      actions: [
        _CircleAction(
          icon: Icons.notifications_outlined,
          onTap: () => Get.toNamed(notificationsView),
        ),
        const SizedBox(width: 10),
        _CircleAction(
          icon: Icons.settings_outlined,
          onTap: () => Get.to(() => const StaffAccountView()),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.activityGreenLight,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.activityGreen.withValues(alpha: 0.12),
          ),
        ),
        child: Icon(
          icon,
          size: 21,
          color: AppColors.activityGreen,
        ),
      ),
    );
  }
}
