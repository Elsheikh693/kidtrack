import '../../../../index/index_main.dart';
import '../../../../Global/widgets/kidtrack_tab_header.dart';
import '../../owner/dashboard/widgets/dashboard_item_model.dart';
import '../../owner/dashboard/widgets/dashboard_section_widget.dart';

class ReceptionistClassesTab extends StatelessWidget {
  const ReceptionistClassesTab({super.key});

  static final _classroomsSection = DashboardSection(
    titleKey: 'owner_section_classrooms',
    titleIcon: Icons.class_rounded,
    titleColor: const Color(0xFFD97706),
    items: [
      DashboardItem(
        labelKey: 'owner_item_classrooms',
        icon: Icons.class_rounded,
        color: const Color(0xFFD97706),
        route: classroomsView,
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
    ],
  );

  static final _eventsSection = DashboardSection(
    titleKey: 'reception_section_events',
    titleIcon: Icons.event_rounded,
    titleColor: const Color(0xFF6366F1),
    items: [
      DashboardItem(
        labelKey: 'reception_item_events',
        icon: Icons.celebration_rounded,
        color: const Color(0xFF6366F1),
        route: receptionistEventsView,
      ),
    ],
  );


  static final _financeSection = DashboardSection(
    titleKey: 'owner_section_finance',
    titleIcon: Icons.account_balance_wallet_rounded,
    titleColor: const Color(0xFFD97706),
    items: [
      DashboardItem(
        labelKey: 'owner_item_invoices',
        icon: Icons.receipt_long_rounded,
        color: const Color(0xFFD97706),
        route: invoicesView,
      ),
      DashboardItem(
        labelKey: 'owner_item_payments',
        icon: Icons.payments_rounded,
        color: const Color(0xFFB45309),
        route: paymentsView,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundNeutral100,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            KidTrackTabHeader(
              titleKey: 'reception_tab_classes',
              icon: Icons.class_rounded,
              accentColor: const Color(0xFFD97706),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  DashboardSectionWidget(section: _classroomsSection),
                  DashboardSectionWidget(section: _eventsSection),
                  DashboardSectionWidget(section: _financeSection),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
