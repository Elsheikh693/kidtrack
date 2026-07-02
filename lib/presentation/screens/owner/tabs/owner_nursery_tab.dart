import '../../../../index/index_main.dart';
import '../dashboard/widgets/dashboard_item_model.dart';
import '../dashboard/widgets/dashboard_section_widget.dart';

class OwnerNurseryTab extends StatelessWidget {
  const OwnerNurseryTab({super.key});

  static final _nurserySection = DashboardSection(
    titleKey: 'owner_section_nursery',
    titleIcon: Icons.business_rounded,
    titleColor: AppColors.blueForeground,
    items: [
      DashboardItem(
        labelKey: 'manager_more_link_nursery_profile',
        icon: Icons.storefront_rounded,
        color: AppColors.secondary80,
        route: managerNurseryProfileView,
      ),
      DashboardItem(
        labelKey: 'owner_item_branches',
        icon: Icons.account_balance_rounded,
        color: AppColors.blueForeground,
        route: branchesView,
      ),
      DashboardItem(
        labelKey: 'owner_item_packages',
        icon: Icons.card_membership_rounded,
        color: AppColors.primary60,
        route: nurseryPackagesView,
      ),
    ],
  );

  static final _staffSection = DashboardSection(
    titleKey: 'owner_section_staff',
    titleIcon: Icons.badge_rounded,
    titleColor: const Color(0xFF6366F1),
    items: [
      DashboardItem(
        labelKey: 'owner_item_staff_list',
        icon: Icons.people_alt_rounded,
        color: AppColors.blueForeground,
        route: staffView,
      ),
      DashboardItem(
        labelKey: 'owner_item_staff_permissions',
        icon: Icons.shield_rounded,
        color: const Color(0xFF6366F1),
        route: staffView,
      ),
    ],
  );

  static final _hrSection = DashboardSection(
    titleKey: 'owner_section_hr',
    titleIcon: Icons.how_to_reg_rounded,
    titleColor: AppColors.teal,
    items: [
      DashboardItem(
        labelKey: 'owner_item_checkin',
        icon: Icons.login_rounded,
        color: const Color(0xFF0891B2),
        route: checkInView,
      ),
      DashboardItem(
        labelKey: 'owner_item_daily_care',
        icon: Icons.baby_changing_station_rounded,
        color: const Color(0xFF06B6D4),
        route: attendanceDailyView,
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
      DashboardItem(
        labelKey: 'overdue_title',
        icon: Icons.warning_amber_rounded,
        color: const Color(0xFFDC2626),
        route: overdueView,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const KidTrackCollapsingHeader(
              title: 'الحضانة',
              icon: Icons.business_rounded,
              accentColor: Color(0xFF2563EB),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  DashboardSectionWidget(section: _nurserySection),
                  DashboardSectionWidget(section: _staffSection),
                  DashboardSectionWidget(section: _hrSection),
                  DashboardSectionWidget(section: _financeSection),
                ]),
              ),
            ),
          ],
        );
  }
}

