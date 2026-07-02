import '../../../../index/index_main.dart';
import '../widgets/manager_tab_header.dart';
import '../staff/widgets/staff_overview_section.dart';
import '../staff/widgets/workforce_signals_section.dart';
import '../staff/widgets/salary_center_section.dart';
import '../staff/widgets/staff_directory_section.dart';
import '../staff/widgets/staff_shimmer.dart';

class ManagerStaffTab extends StatefulWidget {
  const ManagerStaffTab({super.key});

  @override
  State<ManagerStaffTab> createState() => _ManagerStaffTabState();
}

class _ManagerStaffTabState extends State<ManagerStaffTab> {
  static const _accent = AppColors.activityBlue;

  late final ManagerStaffController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ManagerStaffController>();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ManagerTabHeader(
          title: 'manager_tab_staff'.tr,
          accent: _accent,
        ),
        Expanded(
          child: Obx(
            () => controller.isLoading.value
                ? const StaffShimmer()
                : RefreshIndicator(
                    onRefresh: controller.loadData,
                    color: _accent,
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              StaffOverviewSection(controller: controller),
                              const SizedBox(height: 24),
                              WorkforceSignalsSection(controller: controller),
                              const SizedBox(height: 24),
                              SalaryCenterSection(controller: controller),
                              const SizedBox(height: 24),
                              StaffDirectorySection(controller: controller),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
