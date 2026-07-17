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
            AccountMenuSection(
              titleKey: 'parent_account_support_section',
              items: [
                AccountMenuItem(
                  labelKey: 'chat_with_nursery',
                  icon: Icons.forum_outlined,
                  iconColor: const Color(0xFF6366F1),
                  onTap: controller.navigateToChat,
                  badge: Get.find<ActiveChildService>().chatUnread,
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
                  labelKey: 'parent_account_edit_profile',
                  icon: Icons.person_outline_rounded,
                  iconColor: AppColors.primary,
                  onTap: controller.editProfile,
                ),
                AccountMenuItem(
                  labelKey: 'parent_account_notifications',
                  icon: Icons.notifications_outlined,
                  iconColor: const Color(0xFF6366F1),
                  onTap: controller.navigateToNotifications,
                ),
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
