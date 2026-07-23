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
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: AppColors.backgroundNeutral100,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          toolbarHeight: 76,
          titleSpacing: 16,
          title: AccountHeader(controller: controller),
        ),
        body: ListView(
          padding: const EdgeInsets.only(top: 16, bottom: 16),
          physics: const BouncingScrollPhysics(),
          children: [
            AccountChildCard(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: RoleSwitchCard(),
            ),
            AccountMenuSection(
              titleKey: 'parent_account_support_section',
              items: [
                // "تواصل مع الإدارة" removed — the chat is already reachable
                // from the chat icon in the app bar.
                AccountMenuItem(
                  labelKey: 'parent_account_technical_support',
                  icon: Icons.support_agent_outlined,
                  iconColor: AppColors.blueForeground,
                  onTap: controller.contactSupport,
                ),
                AccountMenuItem(
                  labelKey: 'tutorial_menu_entry',
                  icon: Icons.ondemand_video_outlined,
                  iconColor: const Color(0xFFDC2626),
                  onTap: controller.navigateToTutorial,
                ),
              ],
            ),
            AccountMenuSection(
              titleKey: 'parent_account_kidtrack_section',
              items: [
                AccountMenuItem(
                  labelKey: 'settings_about_us',
                  icon: Icons.info_outline_rounded,
                  iconColor: AppColors.primary,
                  onTap: controller.navigateToAboutUs,
                ),
                AccountMenuItem(
                  labelKey: 'settings_review',
                  icon: Icons.favorite_rounded,
                  iconColor: const Color(0xFFEC4899),
                  onTap: controller.navigateToAppReview,
                ),
                AccountMenuItem(
                  labelKey: 'settings_rate_store',
                  icon: Icons.star_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  onTap: controller.rateOnStore,
                ),
                AccountMenuItem(
                  labelKey: 'settings_language',
                  icon: Icons.language_outlined,
                  iconColor: AppColors.primary,
                  onTap: showLanguageSheet,
                ),
              ],
            ),
            AccountMenuSection(
              titleKey: 'parent_account_title',
              items: [
                AccountMenuItem(
                  labelKey: 'parent_account_edit_profile',
                  icon: Icons.person_outline_rounded,
                  iconColor: AppColors.primary,
                  onTap: controller.editProfile,
                ),
                AccountMenuItem(
                  labelKey: 'parent_account_pickup_section',
                  icon: Icons.how_to_reg_outlined,
                  iconColor: const Color(0xFFF59E0B),
                  onTap: controller.navigateToPickup,
                ),
                // "الإشعارات" removed — the notifications inbox is already
                // reachable from the bell in the app bar. Only the notification
                // *settings* remain here.
                AccountMenuItem(
                  labelKey: 'notif_prefs_menu_item',
                  icon: Icons.notifications_active_outlined,
                  iconColor: AppColors.primary,
                  onTap: controller.navigateToNotificationPrefs,
                ),
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
