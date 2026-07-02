import '../../../../../index/index_main.dart';
import 'login_blob.dart';

class LoginHero extends StatelessWidget {
  const LoginHero({
    super.key,
    required this.statusH,
    required this.heroAnim,
    this.nursery,
  });

  final double statusH;
  final Animation<double> heroAnim;
  final NurseryModel? nursery;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 315.h + statusH,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary80, AppColors.primary, AppColors.primary60],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background decorative blobs
          Positioned(
            top: -55.h,
            right: -75.w,
            child: LoginBlob(size: 270.w, opacity: 0.07),
          ),
          Positioned(
            bottom: -15.h,
            left: -55.w,
            child: LoginBlob(size: 210.w, opacity: 0.05),
          ),
          Positioned(
            top: statusH + 45.h,
            right: 52.w,
            child: LoginBlob(size: 55.w, opacity: 0.11),
          ),
          Positioned(
            bottom: 72.h,
            right: 22.w,
            child: LoginBlob(size: 28.w, opacity: 0.15),
          ),
          Positioned(
            top: statusH + 18.h,
            left: 26.w,
            child: LoginBlob(size: 38.w, opacity: 0.09),
          ),
          Positioned(
            top: statusH + 105.h,
            left: 18.w,
            child: LoginBlob(size: 18.w, opacity: 0.18),
          ),
          Positioned(
            bottom: 40.h,
            left: 40.w,
            child: LoginBlob(size: 14.w, opacity: 0.12),
          ),

          // Sparkle / star decorations
          Positioned(
            top: statusH + 32.h,
            right: 118.w,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 15.sp,
              color: AppColors.white.withValues(alpha: 0.28),
            ),
          ),
          Positioned(
            bottom: 115.h,
            left: 72.w,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 11.sp,
              color: AppColors.white.withValues(alpha: 0.22),
            ),
          ),
          Positioned(
            top: statusH + 85.h,
            right: 28.w,
            child: Icon(
              Icons.star_rounded,
              size: 9.sp,
              color: AppColors.white.withValues(alpha: 0.18),
            ),
          ),
          Positioned(
            bottom: 90.h,
            right: 80.w,
            child: Icon(
              Icons.star_rounded,
              size: 7.sp,
              color: AppColors.white.withValues(alpha: 0.15),
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: statusH + 12.h),

                // Logo with scale + fade animation
                ScaleTransition(
                  scale: Tween<double>(begin: 0.55, end: 1.0).animate(
                    CurvedAnimation(parent: heroAnim, curve: Curves.elasticOut),
                  ),
                  child: FadeTransition(
                    opacity: heroAnim,
                    child: _LogoCircle(logoUrl: nursery?.logo),
                  ),
                ),

                SizedBox(height: 26.h),

                // App name — fade + slide up
                FadeTransition(
                  opacity: heroAnim,
                  child: SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0, 0.35),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: heroAnim,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                    child: Text(
                      nursery?.name ?? 'customer_login_title'.tr,
                      textAlign: TextAlign.center,
                      style: context.typography.xxlBold.copyWith(
                        color: AppColors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10.h),

                // Subtitle — fade only (slightly delayed)
                FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 0.78).animate(
                    CurvedAnimation(parent: heroAnim, curve: Curves.easeOut),
                  ),
                  child: Text(
                    nursery != null
                        ? 'discovery_login_parent_subtitle'.tr
                        : 'customer_login_subtitle'.tr,
                    textAlign: TextAlign.center,
                    style: context.typography.xsRegular.copyWith(
                      color: AppColors.white,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoCircle extends StatelessWidget {
  const _LogoCircle({this.logoUrl});

  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow ring
        Container(
          width: 110.w,
          height: 110.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.22),
              width: 2,
            ),
          ),
        ),
        // Mid glow ring
        Container(
          width: 100.w,
          height: 100.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white.withValues(alpha: 0.08),
          ),
        ),
        // White logo circle
        Container(
          width: 150.w,
          height: 150.h,
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary80.withValues(alpha: 0.55),
                blurRadius: 36.r,
                offset: const Offset(0, 14),
              ),
              BoxShadow(
                color: AppColors.white.withValues(alpha: 0.12),
                blurRadius: 10.r,
                spreadRadius: 3.r,
              ),
            ],
          ),
          child: ClipOval(
            child: (logoUrl != null && logoUrl!.trim().isNotEmpty)
                ? AppNetworkImage(
                    url: logoUrl,
                    fit: BoxFit.cover,
                    errorWidget:
                        Image.asset(Images.splash, fit: BoxFit.contain),
                  )
                : Image.asset(Images.splash, fit: BoxFit.contain),
          ),
        ),
      ],
    );
  }
}
