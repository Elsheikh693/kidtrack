import '../../../../index/index_main.dart';
import 'models/owner_dashboard_data.dart';
import 'widgets/executive_widgets.dart';
import 'widgets/owner_exec_shimmer.dart';
import 'widgets/owner_withdrawn_card.dart';

/// The owner's home tab. A DECISION surface, not an operations console:
/// Daily Brief → Needs Attention → Business Snapshot (incl. growth) → Finance.
/// Strictly display-only — every action belongs to staff, not the owner.
class OwnerExecutiveDashboard extends StatefulWidget {
  const OwnerExecutiveDashboard({super.key});

  @override
  State<OwnerExecutiveDashboard> createState() =>
      _OwnerExecutiveDashboardState();
}

class _OwnerExecutiveDashboardState extends State<OwnerExecutiveDashboard> {
  late final OwnerExecutiveController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OwnerExecutiveController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral100,
      appBar: OwnerAppBar(
        title: 'owner_exec_title'.tr,
        showScopeSwitcher: true,
      ),
      body: Obx(() {
        final data = controller.data.value;
        final firstLoading = controller.isFirstLoading.value;

        return RefreshIndicator(
          onRefresh: controller.reload,
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              if (firstLoading && data == null)
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(16, 10, 16, 110),
                  sliver: SliverToBoxAdapter(child: OwnerExecShimmer()),
                )
              else if (data != null)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(_sections(data)),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  List<Widget> _sections(OwnerDashboardData data) {
    return [
      // 3 ── Business snapshot (vital signs + growth, merged)
      const ExecSectionLabel(
        titleKey: 'owner_exec_business',
        icon: Icons.insights_rounded,
        color: Color(0xFF7C3AED),
      ),
      BusinessSnapshotCard(
        business: data.business,
        growth: data.growth,
        isNetwork: data.isNetwork,
      ),
      OwnerWithdrawnCard(controller: controller),

      SizedBox(height: 22.h),
      const UnpaidSubscriptionCard(),

      // 4 ── Financial overview
      const ExecSectionLabel(
        titleKey: 'owner_exec_finance',
        icon: Icons.account_balance_wallet_rounded,
        color: Color(0xFFD97706),
      ),
      FinanceSnapshotCard(finance: data.finance),
    ];
  }
}
