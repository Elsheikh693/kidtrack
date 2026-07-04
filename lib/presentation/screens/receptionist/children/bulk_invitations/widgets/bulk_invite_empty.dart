import '../../../../../../index/index_main.dart';

class BulkInviteEmpty extends StatelessWidget {
  const BulkInviteEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.w,
              height: 72.h,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mark_email_read_outlined,
                size: 34.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'rc_bulk_invite_empty_title'.tr,
              textAlign: TextAlign.center,
              style: context.typography.mdBold.copyWith(
                fontSize: 16,
                color: const Color(0xFF334155),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'rc_bulk_invite_empty_sub'.tr,
              textAlign: TextAlign.center,
              style: context.typography.smRegular.copyWith(
                fontSize: 13,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
