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
              titleKey: 'parent_account_finance_section',
              items: [
                AccountMenuItem(
                  labelKey: 'parent_account_finance',
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: const Color(0xFFD97706),
                  onTap: controller.navigateToFinance,
                ),
              ],
            ),
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
