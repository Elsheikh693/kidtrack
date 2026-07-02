import '../../../../../index/index_main.dart';

/// Two side-by-side primary actions on the receptionist home:
/// check-in/out and register a new child.
class HomeActionCards extends StatelessWidget {
  const HomeActionCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.login_rounded,
            title: 'reception_action_checkinout'.tr,
            subtitle: 'reception_checkin_subtitle'.tr,
            colors: const [Color(0xFF0891B2), Color(0xFF0E7490)],
            onTap: () => Get.toNamed(checkInView),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _ActionCard(
            icon: Icons.person_add_alt_1_rounded,
            title: 'reception_action_register_child'.tr,
            subtitle: 'reception_register_child_subtitle'.tr,
            colors: const [Color(0xFF7C3AED), Color(0xFF6D28D9)],
            onTap: () => Get.toNamed(addChildView),
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> colors;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.3),
              blurRadius: 14.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42.w,
              height: 42.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(13.r),
              ),
              child: Icon(icon, color: Colors.white, size: 22.sp),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.typography.mdBold.copyWith(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.typography.xsMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 11.5,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
