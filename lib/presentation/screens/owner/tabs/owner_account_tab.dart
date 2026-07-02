import '../../../../index/index_main.dart';
import '../dashboard/widgets/dashboard_item_model.dart';
import '../dashboard/widgets/dashboard_section_widget.dart';

class OwnerAccountTab extends StatelessWidget {
  const OwnerAccountTab({super.key});

  static final _pagesSection = DashboardSection(
    titleKey: 'owner_section_account_settings',
    titleIcon: Icons.settings_rounded,
    titleColor: AppColors.primary,
    items: [
      DashboardItem(
        labelKey: 'owner_item_notifications',
        icon: Icons.notifications_active_rounded,
        color: AppColors.primary80,
        route: notificationsView,
      ),
      DashboardItem(
        labelKey: 'eval_reasons_screen_title',
        icon: Icons.label_rounded,
        color: AppColors.activityPurple,
        route: evaluationReasonsView,
      ),
      DashboardItem(
        labelKey: 'child_state_templates_menu_item',
        icon: Icons.emoji_emotions_rounded,
        color: const Color(0xFF0891B2),
        route: childStatesView,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final session = SessionService();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        KidTrackCollapsingHeader(
          title: 'الحساب',
          icon: Icons.manage_accounts_rounded,
          accentColor: const Color(0xFF7C3AED),
          subtitle: session.currentUser?.displayName,
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          sliver: SliverToBoxAdapter(
            child: _OwnerProfileCard(session: session),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          sliver: SliverToBoxAdapter(
            child: DashboardSectionWidget(section: _pagesSection),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          sliver: SliverToBoxAdapter(child: _SettingsCard()),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          sliver: const SliverToBoxAdapter(child: _LogoutButton()),
        ),
      ],
    );
  }
}

// ─── Profile Card ─────────────────────────────────────────────────────────────

class _OwnerProfileCard extends StatelessWidget {
  final SessionService session;

  const _OwnerProfileCard({required this.session});

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
            child: const Icon(
              Icons.person_rounded,
              color: Color(0xFF7C3AED),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.currentUser?.displayName ?? '',
                  style: context.typography.mdBold.copyWith(
                    color: AppColors.textDefault,
                    fontSize: 14,
                  ),
                ),
                if ((session.currentUser?.phone ?? '').isNotEmpty)
                  Text(
                    session.currentUser!.phone!,
                    style: context.typography.xsRegular.copyWith(
                      color: AppColors.textSecondaryParagraph,
                    ),
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
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Settings Card ────────────────────────────────────────────────────────────

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
              style: context.typography.xsMedium.copyWith(
                color: AppColors.textSecondaryParagraph,
              ),
            ),
          ),
          _SettingsTile(
            icon: Icons.contact_phone_outlined,
            color: AppColors.blueForeground,
            labelKey: 'owner_item_contact_numbers',
            onTap: () => Get.toNamed(nurseryContactsView),
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
                style: context.typography.smMedium.copyWith(
                  color: AppColors.textDefault,
                ),
              ),
            ),
            Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 14,
              color: AppColors.grayMedium,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Logout Button ────────────────────────────────────────────────────────────

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
                Icon(
                  Icons.logout_rounded,
                  color: AppColors.errorForeground,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  'owner_logout'.tr,
                  style: TextStyle(
                    color: AppColors.errorForeground,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
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
