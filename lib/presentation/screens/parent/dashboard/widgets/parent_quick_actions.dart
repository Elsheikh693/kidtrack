import '../../../../../index/index_main.dart';
import '../../attention/parent_attention_view.dart';

/// Four compact quick-action tiles on the parent home — Assessments, "needs
/// attention" (badged), Events and the Link Book — laid out in a single row.
/// Icon-over-title, centred, no subtitle, for a clean professional look.
class ParentQuickActions extends StatelessWidget {
  const ParentQuickActions({super.key, required this.controller});

  final ParentDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _QuickCard(
              icon: Icons.menu_book_rounded,
              title: 'parent_action_linkbook'.tr,
              colors: const [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
              onTap: () => Get.to(() => const LinkBookView()),
            ),
          ),
          SizedBox(width: 9.w),
          Expanded(
            child: _QuickCard(
              icon: Icons.celebration_rounded,
              title: 'parent_action_events'.tr,
              colors: const [Color(0xFF6366F1), Color(0xFF4F46E5)],
              onTap: () => Get.toNamed(parentEventsView),
            ),
          ),
          SizedBox(width: 9.w),
          Expanded(
            child: Obx(() {
              final n = controller.attentionCount;
              return _QuickCard(
                icon: Icons.notifications_active_rounded,
                title: 'parent_action_attention'.tr,
                colors: const [Color(0xFFF43F5E), Color(0xFFE11D48)],
                badge: n > 0 ? n : null,
                onTap: () => Get.to(() => const ParentAttentionView()),
              );
            }),
          ),
          SizedBox(width: 9.w),
          Expanded(
            child: Obx(() {
              final n = controller.newAssessmentsCount.value;
              return _QuickCard(
                icon: Icons.assignment_turned_in_rounded,
                title: 'parent_action_assessments'.tr,
                colors: const [Color(0xFF3B82F6), Color(0xFF2563EB)],
                badge: n > 0 ? n : null,
                onTap: () => Get.toNamed(parentAssessmentsView),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.icon,
    required this.title,
    required this.colors,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String title;
  final List<Color> colors;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 14.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: colors.last.withValues(alpha: 0.32),
              blurRadius: 16.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(icon, color: Colors.white, size: 21.sp),
                ),
                if (badge != null)
                  PositionedDirectional(
                    top: -7.h,
                    end: -7.w,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                      constraints: BoxConstraints(minWidth: 19.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 4.r,
                            offset: Offset(0, 1.h),
                          ),
                        ],
                      ),
                      child: Text(
                        '$badge',
                        textAlign: TextAlign.center,
                        style: context.typography.xsMedium.copyWith(
                          color: colors.last,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              title,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: context.typography.smSemiBold.copyWith(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
