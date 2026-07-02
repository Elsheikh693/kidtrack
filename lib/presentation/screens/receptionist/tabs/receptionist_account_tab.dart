import '../../../../index/index_main.dart';
import '../../owner/dashboard/widgets/dashboard_item_model.dart';
import '../../owner/dashboard/widgets/dashboard_section_widget.dart';

class ReceptionistAccountTab extends StatelessWidget {
  const ReceptionistAccountTab({super.key});

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
    final session = SessionService();
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          sliver: SliverToBoxAdapter(
            child: _StaffProfileCard(session: session),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          sliver: SliverToBoxAdapter(
            child: DashboardSectionWidget(section: _financeSection),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          sliver: SliverToBoxAdapter(child: _SettingsCard()),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          sliver: const SliverToBoxAdapter(
            child: _LogoutButton(),
          ),
        ),
      ],
    );
  }
}

// ── Nanny Account Tab ─────────────────────────────────────────────────────────

class NannyAccountTab extends StatelessWidget {
  const NannyAccountTab({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SessionService();
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          sliver: SliverToBoxAdapter(
            child: _StaffProfileCard(session: session),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          sliver: SliverToBoxAdapter(child: _SettingsCard()),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          sliver: const SliverToBoxAdapter(
            child: _LogoutButton(),
          ),
        ),
      ],
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _StaffProfileCard extends StatelessWidget {
  final SessionService session;

  const _StaffProfileCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.grayLight.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
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
                  style: context.typography.mdBold
                      .copyWith(color: AppColors.textDefault, fontSize: 14),
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
            onPressed: () => showEditProfileSheet(isStaff: true),
            icon: const Icon(Icons.edit_outlined, size: 15),
            label: Text('settings_edit_profile'.tr),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF7C3AED),
              textStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.grayLight.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              'parent_account_settings_section'.tr,
              style: context.typography.xsMedium
                  .copyWith(color: AppColors.textSecondaryParagraph),
            ),
          ),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            color: AppColors.primary,
            labelKey: 'owner_item_notifications',
            onTap: () => Get.toNamed(notificationsView),
          ),
          _SettingsTile(
            icon: Icons.support_agent_outlined,
            color: AppColors.blueForeground,
            labelKey: 'contact_support_title',
            onTap: () => showContactSheet(ContactType.support),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String labelKey;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.color,
    required this.labelKey,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                labelKey.tr,
                style: context.typography.smMedium
                    .copyWith(color: AppColors.textDefault),
              ),
            ),
            Icon(Icons.arrow_back_ios_new_rounded,
                size: 14, color: AppColors.grayMedium),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: showLogoutConfirm,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.errorBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.errorForeground.withValues(alpha: 0.25),
              width: 1.2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded,
                    color: AppColors.errorForeground, size: 20),
                const SizedBox(width: 10),
                Text(
                  'owner_logout'.tr,
                  style: context.typography.mdBold.copyWith(
                    color: AppColors.errorForeground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
