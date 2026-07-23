import '../../../../../index/index_main.dart';

class SaHeader extends StatelessWidget {
  final SuperAdminDashboardController controller;
  const SaHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(30.r)),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B1B34), Color(0xFF141B33), Color(0xFF0F2244)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Decorative glow — top trailing
            Positioned(
              top: -50.h,
              left: -40.w,
              child: _glow(150.w, const Color(0xFF4FC3F7), 0.18),
            ),
            // Decorative glow — bottom leading
            Positioned(
              bottom: -60.h,
              right: -30.w,
              child: _glow(160.w, const Color(0xFF6366F1), 0.16),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 34.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50.w,
                          height: 50.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF6366F1).withValues(alpha: 0.9),
                                const Color(0xFF0EA5E9).withValues(alpha: 0.9),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                                blurRadius: 16.r,
                                offset: Offset(0, 6.h),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.admin_panel_settings_rounded,
                            color: Colors.white,
                            size: 25.sp,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: showLanguageSheet,
                          child: Container(
                            padding: EdgeInsets.all(9.w),
                            margin: EdgeInsetsDirectional.only(end: 8.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                              ),
                            ),
                            child: Icon(Icons.language_rounded,
                                color: Colors.white70, size: 16.sp),
                          ),
                        ),
                        GestureDetector(
                          onTap: controller.logout,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.logout_rounded, color: Colors.white70, size: 16.sp),
                                SizedBox(width: 6.w),
                                Text(
                                  'sa_logout'.tr,
                                  style: context.typography.smRegular.copyWith(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 22.h),
                    Text(
                      'sa_welcome'.tr,
                      style: context.typography.smRegular.copyWith(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      controller.adminName,
                      style: context.typography.xlBold.copyWith(
                        color: Colors.white,
                        fontSize: 24,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4FC3F7).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: const Color(0xFF4FC3F7).withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shield_rounded, size: 13.sp, color: const Color(0xFF4FC3F7)),
                          SizedBox(width: 5.w),
                          Text(
                            'super_admin_badge'.tr,
                            style: context.typography.smRegular.copyWith(
                              color: const Color(0xFF4FC3F7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glow(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: opacity), color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}
