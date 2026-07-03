import '../../../../../index/index_main.dart';

/// Three side-by-side primary actions on the receptionist home:
/// check-in/out, register a new child, and collect money.
class HomeActionCards extends StatelessWidget {
  const HomeActionCards({super.key});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
          SizedBox(width: 10.w),
          Expanded(
            child: _ActionCard(
              icon: Icons.person_add_alt_1_rounded,
              title: 'reception_action_register_child'.tr,
              subtitle: 'reception_register_child_subtitle'.tr,
              colors: const [Color(0xFF7C3AED), Color(0xFF6D28D9)],
              onTap: () => Get.toNamed(addChildView),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _ActionCard(
              icon: Icons.payments_rounded,
              title: 'reception_action_collect'.tr,
              subtitle: 'reception_collect_subtitle'.tr,
              colors: const [Color(0xFF16A34A), Color(0xFF15803D)],
              onTap: () => Get.find<MainPageViewModel>().changePage(5),
            ),
          ),
        ],
      ),
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
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
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
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: Colors.white, size: 20.sp),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.typography.mdBold.copyWith(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.typography.xsMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 10.5,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
