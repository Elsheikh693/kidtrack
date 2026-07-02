import '../../../../../index/index_main.dart';

class SaActionsSection extends StatelessWidget {
  final SuperAdminDashboardController controller;

  const SaActionsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'sa_management_title'.tr,
            style: context.typography.mdBold.copyWith(
              fontSize: 18,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 16.h),
          SaActionCard(
            icon: Icons.account_balance_rounded,
            color: const Color(0xFF6366F1),
            title: 'sa_nurseries_title'.tr,
            subtitle: 'sa_nurseries_subtitle'.tr,
            onTap: controller.goNurseries,
          ),
          SizedBox(height: 12.h),
          SaActionCard(
            icon: Icons.payments_rounded,
            color: const Color(0xFF16A34A),
            title: 'sa_billing_title'.tr,
            subtitle: 'sa_billing_subtitle'.tr,
            onTap: controller.goBilling,
          ),
          SizedBox(height: 12.h),
          SaActionCard(
            icon: Icons.dashboard_customize_rounded,
            color: const Color(0xFF0EA5E9),
            title: 'sa_content_title'.tr,
            subtitle: 'sa_content_subtitle'.tr,
            onTap: controller.goPlatformContent,
          ),
        ],
      ),
    );
  }
}
