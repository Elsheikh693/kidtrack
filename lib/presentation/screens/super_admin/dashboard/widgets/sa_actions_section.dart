import '../../../../../index/index_main.dart';

class SaActionsSection extends StatelessWidget {
  final SuperAdminDashboardController controller;

  const SaActionsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 26.h, 20.w, 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4.w,
                height: 20.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                'sa_management_title'.tr,
                style: context.typography.mdBold.copyWith(
                  fontSize: 18,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
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
            icon: Icons.account_balance_wallet_rounded,
            color: const Color(0xFF6D4AFF),
            title: 'sa_payment_accounts_title'.tr,
            subtitle: 'sa_payment_accounts_subtitle'.tr,
            onTap: controller.goPaymentAccounts,
          ),
          SizedBox(height: 12.h),
          SaActionCard(
            icon: Icons.dashboard_customize_rounded,
            color: const Color(0xFF0EA5E9),
            title: 'sa_content_title'.tr,
            subtitle: 'sa_content_subtitle'.tr,
            onTap: controller.goPlatformContent,
          ),
          SizedBox(height: 12.h),
          SaActionCard(
            icon: Icons.location_city_rounded,
            color: const Color(0xFFEA580C),
            title: 'sa_cities_title'.tr,
            subtitle: 'sa_cities_subtitle'.tr,
            onTap: controller.goCities,
          ),
          SizedBox(height: 12.h),
          SaActionCard(
            icon: Icons.ondemand_video_rounded,
            color: const Color(0xFFDC2626),
            title: 'sa_tutorial_title'.tr,
            subtitle: 'sa_tutorial_subtitle'.tr,
            onTap: controller.goTutorialVideos,
          ),
          SizedBox(height: 12.h),
          SaActionCard(
            icon: Icons.photo_library_rounded,
            color: const Color(0xFF6D4AFF),
            title: 'sa_showcase_title'.tr,
            subtitle: 'sa_showcase_subtitle'.tr,
            onTap: controller.goShowcaseAlbums,
          ),
          SizedBox(height: 12.h),
          SaActionCard(
            icon: Icons.feedback_rounded,
            color: const Color(0xFFF59E0B),
            title: 'sa_feedback_title'.tr,
            subtitle: 'sa_feedback_subtitle'.tr,
            onTap: controller.goFeedbackCampaigns,
          ),
        ],
      ),
    );
  }
}
