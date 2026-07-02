import '../../../../index/index_main.dart';
import '../dashboard/widgets/dashboard_item_model.dart';
import '../dashboard/widgets/dashboard_section_widget.dart';

class OwnerChildrenTab extends StatelessWidget {
  const OwnerChildrenTab({super.key});

  static final _childrenSection = DashboardSection(
    titleKey: 'owner_section_children',
    titleIcon: Icons.child_care_rounded,
    titleColor: AppColors.successForeground,
    items: [
      DashboardItem(
        labelKey: 'owner_item_children',
        icon: Icons.child_care_rounded,
        color: AppColors.successForeground,
        route: childrenView,
      ),
      DashboardItem(
        labelKey: 'owner_item_enrollments',
        icon: Icons.app_registration_rounded,
        color: const Color(0xFF059669),
        route: enrollmentsView,
      ),
      DashboardItem(
        labelKey: 'owner_item_waiting_list',
        icon: Icons.pending_actions_rounded,
        color: AppColors.primary40,
        route: waitingListView,
      ),
      DashboardItem(
        labelKey: 'owner_item_leave_requests',
        icon: Icons.event_busy_rounded,
        color: const Color(0xFFF97316),
        route: childLeaveRequestsView,
      ),
    ],
  );

  static final _healthSection = DashboardSection(
    titleKey: 'owner_section_health_docs',
    titleIcon: Icons.medical_services_rounded,
    titleColor: AppColors.errorForeground,
    items: [
      DashboardItem(
        labelKey: 'owner_item_medical',
        icon: Icons.medical_services_rounded,
        color: AppColors.errorForeground,
        route: childMedicalView,
      ),
      DashboardItem(
        labelKey: 'owner_item_documents',
        icon: Icons.folder_copy_rounded,
        color: AppColors.yellowForeground,
        route: childDocumentsView,
      ),
      DashboardItem(
        labelKey: 'owner_item_pickup',
        icon: Icons.directions_car_rounded,
        color: AppColors.primary60,
        route: authorizedPickupView,
      ),
      DashboardItem(
        labelKey: 'owner_item_bus_assignment',
        icon: Icons.directions_bus_rounded,
        color: const Color(0xFF2563EB),
        route: busAssignmentView,
      ),
    ],
  );

  static final _parentsSection = DashboardSection(
    titleKey: 'owner_section_parents',
    titleIcon: Icons.family_restroom_rounded,
    titleColor: const Color(0xFFDC2626),
    items: [
      DashboardItem(
        labelKey: 'owner_item_guardians',
        icon: Icons.family_restroom_rounded,
        color: const Color(0xFFDC2626),
        route: guardianListView,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const KidTrackCollapsingHeader(
              title: 'الأطفال',
              icon: Icons.child_care_rounded,
              accentColor: Color(0xFF16A34A),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  DashboardSectionWidget(section: _childrenSection),
                  DashboardSectionWidget(section: _healthSection),
                  DashboardSectionWidget(section: _parentsSection),
                ]),
              ),
            ),
          ],
        );
  }
}

