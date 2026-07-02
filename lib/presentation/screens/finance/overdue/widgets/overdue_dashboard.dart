import '../../../../../index/index_main.dart';

/// Shared finance dashboard body — used both by the standalone [OverdueView]
/// route and embedded as the receptionist finance tab.
class OverdueDashboard extends StatelessWidget {
  final OverdueController controller;

  /// First sliver (e.g. a [KidTrackCollapsingHeader] for the tab, or an
  /// empty box for the route where the [AppBar] already shows the title).
  final Widget headerSliver;

  const OverdueDashboard({
    super.key,
    required this.controller,
    required this.headerSliver,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Obx(
          () => CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              headerSliver,
              SliverToBoxAdapter(
                child: OverdueDateBar(controller: controller),
              ),
              SliverToBoxAdapter(
                child: OverdueHeroCard(
                  total: controller.overdueTotal,
                  overdueCount: controller.overdueCount,
                  upcomingTotal: controller.upcomingTotal,
                ),
              ),
              SliverToBoxAdapter(
                child: OverdueFilterBar(controller: controller),
              ),
              SliverToBoxAdapter(
                child: OverdueCategoryBar(controller: controller),
              ),
              if (controller.isLoading.value && controller.items.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 80.h),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                )
              else if (controller.items.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 60.h),
                    child: const OverdueEmpty(),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 120.h),
                  sliver: SliverList.builder(
                    itemCount: controller.items.length,
                    itemBuilder: (_, i) =>
                        OverdueCard(item: controller.items[i]),
                  ),
                ),
            ],
          ),
        ),

        // ── Floating add button ─────────────────────────────────────────────
        Positioned(
          bottom: 20.h,
          left: 20.w,
          child: _AddButton(onTap: controller.openCreate),
        ),
      ],
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(30.r),
      elevation: 4,
      shadowColor: AppColors.primary.withValues(alpha: 0.4),
      child: InkWell(
        borderRadius: BorderRadius.circular(30.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, color: Colors.white, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'overdue_add_fab'.tr,
                style: context.typography.smSemiBold
                    .copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
