import '../../../../../index/index_main.dart';
import '../../events/widgets/create_event_sheet.dart';

/// Primary quick actions on the receptionist home, laid out three-per-row.
/// Columns pair related actions vertically: register-child sits above collect,
/// check-in/out above daily-expenses.
/// row 1 — register a child, check-in/out, invite a guardian (send app code);
/// row 2 — collect money, daily expenses, create an event.
class HomeActionCards extends StatelessWidget {
  const HomeActionCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                  icon: Icons.forward_to_inbox_rounded,
                  title: 'reception_action_invite'.tr,
                  subtitle: 'reception_invite_subtitle'.tr,
                  colors: const [Color(0xFFF59E0B), Color(0xFFD97706)],
                  onTap: () => Get.toNamed(bulkInvitationsView),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.payments_rounded,
                  title: 'reception_action_collect'.tr,
                  subtitle: 'reception_collect_subtitle'.tr,
                  colors: const [Color(0xFF16A34A), Color(0xFF15803D)],
                  onTap: () => Get.find<MainPageViewModel>().changePage(5),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _ActionCard(
                  icon: Icons.receipt_long_rounded,
                  title: 'reception_action_expenses'.tr,
                  subtitle: 'reception_expenses_subtitle'.tr,
                  colors: const [Color(0xFFDB2777), Color(0xFFBE185D)],
                  onTap: () => Get.toNamed(childChargesView),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _ActionCard(
                  icon: Icons.celebration_rounded,
                  title: 'reception_action_event'.tr,
                  subtitle: 'reception_event_subtitle'.tr,
                  colors: const [Color(0xFF4F46E5), Color(0xFF4338CA)],
                  onTap: () => _showCreateEvent(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCreateEvent(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateEventSheet(),
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
