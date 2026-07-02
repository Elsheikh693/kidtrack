import '../../../../index/index_main.dart';
import 'controller.dart';
import 'widgets/account_header.dart';
import 'widgets/account_child_card.dart';
import 'widgets/account_menu_section.dart';

class ParentAccountView extends StatefulWidget {
  const ParentAccountView({super.key});

  @override
  State<ParentAccountView> createState() => _ParentAccountViewState();
}

class _ParentAccountViewState extends State<ParentAccountView> {
  late final ParentAccountController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => ParentAccountController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundNeutral100,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          title: Text(
            'parent_account_title'.tr,
            style: context.typography.lgBold.copyWith(
              color: AppColors.textDefault,
            ),
          ),
          actions: [
            IconButton(
              onPressed: controller.navigateToNotifications,
              icon: const Icon(
                Icons.notifications_outlined,
                color: AppColors.textDefault,
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: AppColors.borderNeutralPrimary.withValues(alpha: 0.3),
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          physics: const BouncingScrollPhysics(),
          children: [
            AccountHeader(controller: controller),
            AccountChildCard(),
            AccountMenuSection(
              titleKey: 'parent_account_children_section',
              items: [
                AccountMenuItem(
                  labelKey: 'chat_with_nursery',
                  icon: Icons.forum_outlined,
                  iconColor: const Color(0xFF6366F1),
                  onTap: controller.navigateToChat,
                ),
                AccountMenuItem(
                  labelKey: 'parent_account_pickup_section',
                  icon: Icons.directions_car_outlined,
                  iconColor: AppColors.blueForeground,
                  onTap: controller.navigateToPickup,
                ),
                AccountMenuItem(
                  labelKey: 'parent_account_finance',
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: const Color(0xFFD97706),
                  onTap: controller.navigateToFinance,
                ),
                AccountMenuItem(
                  labelKey: 'parent_account_home_location',
                  icon: Icons.location_on_outlined,
                  iconColor: AppColors.primary,
                  onTap: controller.navigateToHomeLocation,
                ),
              ],
            ),
            AccountMenuSection(
              titleKey: 'parent_account_settings_section',
              items: [
                AccountMenuItem(
                  labelKey: 'parent_account_notif',
                  icon: Icons.notifications_outlined,
                  iconColor: AppColors.yellowForeground,
                  onTap: controller.navigateToNotifications,
                ),
                AccountMenuItem(
                  labelKey: 'parent_account_theme',
                  icon: Icons.palette_outlined,
                  iconColor: const Color(0xFF7C3AED),
                  onTap: controller.changeTheme,
                ),
              ],
            ),
            AccountMenuSection(
              titleKey: 'parent_account_support_section',
              items: [
                AccountMenuItem(
                  labelKey: 'parent_account_contact_nursery',
                  icon: Icons.school_outlined,
                  iconColor: AppColors.successForeground,
                  onTap: controller.contactNursery,
                ),
                AccountMenuItem(
                  labelKey: 'parent_account_contact_admin',
                  icon: Icons.admin_panel_settings_outlined,
                  iconColor: AppColors.primary,
                  onTap: controller.contactAdmin,
                ),
                AccountMenuItem(
                  labelKey: 'parent_account_technical_support',
                  icon: Icons.support_agent_outlined,
                  iconColor: AppColors.blueForeground,
                  onTap: controller.contactSupport,
                ),
              ],
            ),
            AccountMenuSection(
              titleKey: 'parent_account_title',
              items: [
                AccountMenuItem(
                  labelKey: 'parent_account_logout',
                  icon: Icons.logout_rounded,
                  iconColor: AppColors.errorForeground,
                  onTap: controller.logout,
                  isDestructive: true,
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
