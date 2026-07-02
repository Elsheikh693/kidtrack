import '../../../../../index/index_main.dart';

const _accent = Color(0xFF0891B2);

/// Prominent full-width check-in/out action — the receptionist's primary task.
/// Shown on both Home and Operations.
class OpsCheckInButton extends StatelessWidget {
  const OpsCheckInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(checkInView),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_accent, Color(0xFF0E7490)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: _accent.withValues(alpha: 0.3),
              blurRadius: 14.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46.w,
              height: 46.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(Icons.login_rounded,
                  color: Colors.white, size: 24.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'reception_action_checkinout'.tr,
                    style: context.typography.mdBold.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'reception_checkin_subtitle'.tr,
                    style: context.typography.xsMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 30.w,
              height: 30.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white, size: 14.sp),
            ),
          ],
        ),
      ),
    );
  }
}
