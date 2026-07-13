import '../../../../index/index_main.dart';
import '../dashboard/widgets/dashboard_item_model.dart';

/// Owner's "More" hub. Everything operational lives one tap deeper here so the
/// four primary tabs stay decision-focused. Three groups: Operations · Business
/// · Account.
class OwnerMoreTab extends StatelessWidget {
  const OwnerMoreTab({super.key});

  static const _nurseryProfile = DashboardSection(
    titleKey: 'owner_section_nursery',
    titleIcon: Icons.storefront_rounded,
    titleColor: Color(0xFFEC4899),
    items: [
      DashboardItem(
        labelKey: 'owner_item_setup_checklist',
        icon: Icons.checklist_rounded,
        color: Color(0xFF5E35B1),
        route: setupChecklistView,
      ),
      // "الفروع" now lives inside "خطوات الإعداد"; "الكورسات" temporarily
      // removed — both dropped from this section for manager/owner.
    ],
  );

  static const _operations = DashboardSection(
    titleKey: 'owner_more_operations',
    titleIcon: Icons.tune_rounded,
    titleColor: Color(0xFF2563EB),
    items: [
      DashboardItem(
        labelKey: 'owner_item_children',
        icon: Icons.child_care_rounded,
        color: Color(0xFF16A34A),
        route: childrenView,
      ),
      DashboardItem(
        labelKey: 'nursery_feedback_view_title',
        icon: Icons.reviews_rounded,
        color: Color(0xFFF5A623),
        route: nurseryFeedbackListView,
      ),
      DashboardItem(
        labelKey: 'manager_more_link_holidays',
        icon: Icons.event_busy_rounded,
        color: Color(0xFFD97706),
        route: holidaysView,
      ),
    ],
  );

  static const _business = DashboardSection(
    titleKey: 'owner_more_business',
    titleIcon: Icons.business_center_rounded,
    titleColor: Color(0xFF7C3AED),
    items: [
      DashboardItem(
        labelKey: 'billing_my_subscription',
        icon: Icons.payments_rounded,
        color: Color(0xFF16A34A),
        route: mySubscriptionView,
      ),
      // "طلبات الالتحاق" item temporarily removed for manager/owner.
    ],
  );

  @override
  Widget build(BuildContext context) {
    final session = SessionService();
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral100,
      appBar: OwnerAppBar(title: 'owner_tab_more'.tr),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 110),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _ProfileCard(session: session),
                const SizedBox(height: 16),
                const _SwitchViewCard(),
                const SizedBox(height: 20),
                const _ListSection(section: _nurseryProfile),
                const _ListSection(section: _operations),
                const _ListSection(section: _business),
                const _AccountCard(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.session});

  final SessionService session;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded,
                color: Color(0xFF7C3AED), size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.currentUser?.displayName ?? '',
                  style: context.typography.displaySmBold
                      .copyWith(color: AppColors.textDefault),
                ),
                if ((session.currentUser?.phone ?? '').isNotEmpty)
                  Text(
                    session.currentUser!.phone!,
                    style: context.typography.xsRegular
                        .copyWith(color: AppColors.textSecondaryParagraph),
                  ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => showEditProfileSheet(isStaff: false),
            icon: const Icon(Icons.edit_outlined, size: 15),
            label: Text('settings_edit_profile'.tr),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF7C3AED),
              textStyle: context.typography.xsMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchViewCard extends StatelessWidget {
  const _SwitchViewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _Tile(
        icon: Icons.sync_alt_rounded,
        color: const Color(0xFF7C3AED),
        labelKey: 'owner_switch_view',
        onTap: showSwitchToBranchSheet,
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _Tile(
            icon: Icons.notifications_active_outlined,
            color: AppColors.primary,
            labelKey: 'owner_item_notifications',
            onTap: () => Get.toNamed(notificationsView),
          ),
          const _RowDivider(),
          _Tile(
            icon: Icons.contact_phone_outlined,
            color: AppColors.blueForeground,
            labelKey: 'owner_item_contact_numbers',
            onTap: () => Get.toNamed(nurseryContactsView),
          ),
          const _RowDivider(),
          _Tile(
            icon: Icons.logout_rounded,
            color: AppColors.errorForeground,
            labelKey: 'owner_logout',
            onTap: showLogoutConfirm,
            danger: true,
          ),
        ],
      ),
    );
  }
}

/// A titled white card that stacks a section's items as full-width list rows —
/// matching the manager More tab, so sparse groups still read as clean lists.
class _ListSection extends StatelessWidget {
  const _ListSection({required this.section});

  final DashboardSection section;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
            child: Text(
              section.titleKey.tr,
              style: context.typography.xsMedium
                  .copyWith(color: AppColors.textSecondaryParagraph),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                for (var i = 0; i < section.items.length; i++) ...[
                  _Tile(
                    icon: section.items[i].icon,
                    color: section.items[i].color,
                    labelKey: section.items[i].labelKey,
                    onTap: () => Get.toNamed(section.items[i].route),
                  ),
                  if (i != section.items.length - 1) const _RowDivider(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Hairline divider between list rows, indented past the leading icon chip.
class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 64),
      child: Divider(
        height: 1,
        thickness: 1,
        color: AppColors.grayLight.withValues(alpha: 0.7),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.color,
    required this.labelKey,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final Color color;
  final String labelKey;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                labelKey.tr,
                style: context.typography.smSemiBold
                    .copyWith(color: danger ? color : AppColors.textDefault),
              ),
            ),
            if (!danger)
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: AppColors.grayMedium),
          ],
        ),
      ),
    );
  }
}
