import '../../../../index/index_main.dart';
import '../../owner/dashboard/widgets/dashboard_item_model.dart';
import '../../owner/dashboard/widgets/dashboard_section_widget.dart';

class ReceptionistParentsTab extends StatelessWidget {
  const ReceptionistParentsTab({super.key});

  static final _parentsSection = DashboardSection(
    titleKey: 'reception_section_parents',
    titleIcon: Icons.family_restroom_rounded,
    titleColor: const Color(0xFFDC2626),
    items: [
      DashboardItem(
        labelKey: 'owner_item_guardians',
        icon: Icons.family_restroom_rounded,
        color: const Color(0xFFDC2626),
        route: guardianListView,
      ),
      DashboardItem(
        labelKey: 'reception_item_authorized_pickup',
        icon: Icons.verified_user_rounded,
        color: const Color(0xFF7C3AED),
        route: authorizedPickupView,
      ),
      DashboardItem(
        labelKey: 'reception_item_leave_requests',
        icon: Icons.event_busy_rounded,
        color: const Color(0xFFF97316),
        route: childLeaveRequestsView,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        KidTrackCollapsingHeader(
          title: 'receptioni29_parents_title'.tr,
          icon: Icons.people_rounded,
          accentColor: const Color(0xFF0891B2),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              DashboardSectionWidget(section: _parentsSection),
            ]),
          ),
        ),
      ],
    );
  }
}
