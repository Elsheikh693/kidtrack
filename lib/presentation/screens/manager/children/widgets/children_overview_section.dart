import '../../../../../index/index_main.dart';
import 'overview_kpi_card.dart';

/// Top-of-tab live snapshot: the active roster and who is on-site right now —
/// two KPI tiles side by side. Monthly movement lives in its own section.
class ChildrenOverviewSection extends StatelessWidget {
  const ChildrenOverviewSection({super.key, required this.controller});

  final ManagerChildrenController controller;

  @override
  Widget build(BuildContext context) {
    const spacing = 12.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - spacing) / 2;
        return Obx(
          () => Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              SizedBox(
                width: cardWidth,
                child: OverviewKpiCard(
                  label: 'manager_children_kpi_active'.tr,
                  value: '${controller.activeChildren.value}',
                  icon: Icons.groups_rounded,
                  color: AppColors.activityGreen,
                ),
              ),
              SizedBox(
                width: cardWidth,
                child: OverviewKpiCard(
                  label: 'manager_children_kpi_present'.tr,
                  value: '${controller.presentNow.value}',
                  icon: Icons.how_to_reg_rounded,
                  color: AppColors.activityBlue,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
