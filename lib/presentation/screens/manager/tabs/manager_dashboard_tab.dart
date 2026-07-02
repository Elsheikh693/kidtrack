import '../../../../index/index_main.dart';
import '../dashboard/widgets/dashboard_hero.dart';
import '../dashboard/widgets/dashboard_presence_card.dart';
import '../dashboard/widgets/dashboard_quick_links.dart';
import '../dashboard/widgets/dashboard_teachers_card.dart';
import '../dashboard/widgets/dashboard_finance_summary.dart';
import '../dashboard/widgets/dashboard_shimmer.dart';

class ManagerDashboardTab extends StatefulWidget {
  const ManagerDashboardTab({super.key});

  @override
  State<ManagerDashboardTab> createState() => _ManagerDashboardTabState();
}

class _ManagerDashboardTabState extends State<ManagerDashboardTab> {
  static final _accent = AppColors.primary;

  late final ManagerDashboardController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ManagerDashboardController>();
  }

  @override
  Widget build(BuildContext context) {
    // The whole screen scrolls as one surface — the hero rides along at the top
    // of the scroll view rather than staying pinned, so a short content list
    // can still be pulled up and the header tucks away while browsing.
    return Obx(
      () => RefreshIndicator(
        onRefresh: controller.loadData,
        color: _accent,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: DashboardHero(controller: controller),
            ),
            if (controller.isLoading)
              // The shimmer is plain skeleton content that scrolls with the
              // hero — it must NOT be a scrollable child of SliverFillRemaining.
              // A scroll view (ListView) inside SliverFillRemaining(hasScrollBody:
              // false) leaves the sliver's geometry null and crashes layout at
              // viewport.dart:694 (`child.geometry!`), which seeds the framework's
              // first-frame TimingsCallback flood. SliverToBoxAdapter + a
              // shrink-wrapping skeleton lays out cleanly.
              const SliverToBoxAdapter(child: DashboardShimmer())
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 100.h),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    DashboardPresenceCard(controller: controller),
                    DashboardQuickLinks(controller: controller),
                    SizedBox(height: 22.h),
                    DashboardTeachersCard(controller: controller),
                    SizedBox(height: 22.h),
                    DashboardFinanceSummary(controller: controller),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
