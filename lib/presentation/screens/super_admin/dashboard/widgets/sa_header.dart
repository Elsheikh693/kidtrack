import '../../../../../index/index_main.dart';

class SaHeader extends StatelessWidget {
  final SuperAdminDashboardController controller;
  const SaHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48.w,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: controller.logout,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.logout_rounded, color: Colors.white70, size: 16.sp),
                          SizedBox(width: 6.w),
                          Text(
                            'sa_logout'.tr,
                            style: context.typography.smRegular.copyWith(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),
              Text(
                'sa_welcome'.tr,
                style: context.typography.smRegular.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                controller.adminName,
                style: context.typography.xlBold.copyWith(
                  color: Colors.white,
                  fontSize: 22,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F3460).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_rounded, size: 13.sp, color: const Color(0xFF4FC3F7)),
                    SizedBox(width: 5.w),
                    Text(
                      'super_admin_badge'.tr,
                      style: context.typography.smRegular.copyWith(color: const Color(0xFF4FC3F7), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
