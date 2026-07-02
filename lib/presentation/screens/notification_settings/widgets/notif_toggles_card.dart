import '../../../../index/index_main.dart';
import '../controller.dart';
import 'notif_toggle_tile.dart';

class NotifTogglesCard extends StatelessWidget {
  const NotifTogglesCard({super.key, required this.controller});

  final NotificationSettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.grayLight.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          NotifToggleTile(
            icon: Icons.receipt_long_rounded,
            iconColor: AppColors.primary,
            iconBg: AppColors.primaryLight,
            title: 'notif_settings_orders'.tr,
            subtitle: 'notif_settings_orders_sub'.tr,
            value: controller.ordersEnabled.value,
            onChanged: controller.setOrders,
          ),
          Divider(height: 1, thickness: 1, indent: 76.w, color: AppColors.grayLight),
          NotifToggleTile(
            icon: Icons.calendar_month_rounded,
            iconColor: AppColors.successForeground,
            iconBg: AppColors.successBackground,
            title: 'notif_settings_reservations'.tr,
            subtitle: 'notif_settings_reservations_sub'.tr,
            value: controller.reservationsEnabled.value,
            onChanged: controller.setReservations,
          ),
          Divider(height: 1, thickness: 1, indent: 76.w, color: AppColors.grayLight),
          NotifToggleTile(
            icon: Icons.local_offer_rounded,
            iconColor: AppColors.yellowForeground,
            iconBg: AppColors.yellowBackground,
            title: 'notif_settings_promos'.tr,
            subtitle: 'notif_settings_promos_sub'.tr,
            value: controller.promosEnabled.value,
            onChanged: controller.setPromos,
          ),
          Divider(height: 1, thickness: 1, indent: 76.w, color: AppColors.grayLight),
          NotifToggleTile(
            icon: Icons.campaign_rounded,
            iconColor: AppColors.blueForeground,
            iconBg: AppColors.blueLightBackground,
            title: 'notif_settings_general'.tr,
            subtitle: 'notif_settings_general_sub'.tr,
            value: controller.generalEnabled.value,
            onChanged: controller.setGeneral,
          ),
        ],
      ),
    );
  }
}
