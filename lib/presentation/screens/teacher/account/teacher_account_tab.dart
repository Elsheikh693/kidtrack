import '../../../../index/index_main.dart';
import '../../shared/logout_helper.dart';

class TeacherAccountTab extends StatelessWidget {
  const TeacherAccountTab({super.key});

  static const _accent = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    final session = SessionService();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        KidTrackCollapsingHeader(
          title: 'teacher_tab_account'.tr,
          icon: Icons.manage_accounts_rounded,
          accentColor: _accent,
          subtitle: session.currentUser?.displayName,
        ),

        // Profile card
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          sliver: SliverToBoxAdapter(
            child: _TeacherProfileCard(session: session),
          ),
        ),

        // Classroom management section
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          sliver: SliverToBoxAdapter(
            child: _SectionCard(
              titleKey: 'teacher_account_classroom_section',
              tiles: [
                _SettingsTile(
                  icon: Icons.emoji_emotions_rounded,
                  color: const Color(0xFF0891B2),
                  labelKey: 'child_state_templates_menu_item',
                  onTap: () => Get.toNamed(childStatesView),
                ),
              ],
            ),
          ),
        ),

        // Logout
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          sliver: SliverToBoxAdapter(
            child: const _LogoutButton(),
          ),
        ),
      ],
    );
  }
}

// ─── Profile Card ─────────────────────────────────────────────────────────────

class _TeacherProfileCard extends StatelessWidget {
  const _TeacherProfileCard({required this.session});
  final SessionService session;

  static const _accent = Color(0xFF7C3AED);

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
              color: _accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded, color: _accent, size: 26),
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
            onPressed: () => showEditProfileSheet(isStaff: true),
            icon: const Icon(Icons.edit_outlined, size: 15),
            label: Text('settings_edit_profile'.tr),
            style: TextButton.styleFrom(
              foregroundColor: _accent,
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

// ─── Generic section card ──────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.titleKey, required this.tiles});
  final String titleKey;
  final List<_SettingsTile> tiles;

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
              titleKey.tr,
              style: context.typography.xsMedium.copyWith(
                color: AppColors.textSecondaryParagraph,
              ),
            ),
          ),
          ...tiles,
        ],
      ),
    );
  }
}

// ─── Settings Tile ────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.color,
    required this.labelKey,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String labelKey;
  final VoidCallback onTap;

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
                style: context.typography.mdBold
                    .copyWith(color: AppColors.textDefault),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 22,
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
