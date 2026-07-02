import 'dart:io';
import 'package:lottie/lottie.dart';
import '../../../index/index_main.dart';

class ForceUpdateView extends StatelessWidget {
  const ForceUpdateView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ── Lottie animation ───────────────────────────────────────
                SizedBox(
                  height: 250.h,
                  child: Lottie.asset(
                    Animations.commingSoon,
                    repeat: true,
                    fit: BoxFit.contain,
                  ),
                ),

                SizedBox(height: 32.h),

                // ── Icon badge ────────────────────────────────────────────
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.system_update_rounded,
                    color: AppColors.primary,
                    size: 26.sp,
                  ),
                ),

                SizedBox(height: 20.h),

                // ── Title ─────────────────────────────────────────────────
                Text(
                  'force_update_title'.tr,
                  style: context.typography.xlBold.copyWith(
                    color: AppColors.textDefault,
                  ),
                ),

                SizedBox(height: 10.h),

                // ── Subtitle ──────────────────────────────────────────────
                Text(
                  'force_update_msg'.tr,
                  textAlign: TextAlign.center,
                  style: context.typography.smRegular.copyWith(
                    color: AppColors.grayMedium,
                    height: 1.6,
                  ),
                ),

                const Spacer(flex: 2),

                // ── Update button ─────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: _openStore,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(
                      'force_update_btn'.tr,
                      style: context.typography.mdMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 14.h),

                Text(
                  'force_update_required'.tr,
                  style: context.typography.xsRegular.copyWith(
                    color: AppColors.grayMedium,
                  ),
                ),

                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openStore() async {
    final url = Platform.isIOS ? Strings.urlIos : Strings.urlAndroid;
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
