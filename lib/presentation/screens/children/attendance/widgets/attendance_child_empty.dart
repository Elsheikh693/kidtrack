import '../../../../../index/index_main.dart';

class AttendanceChildEmpty extends StatelessWidget {
  final VoidCallback onAdd;
  const AttendanceChildEmpty({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Icon(Icons.how_to_reg_outlined, size: 40.sp, color: const Color(0xFF0284C7)),
            ),
            SizedBox(height: 20.h),
            Text(
              'checkin_empty_title'.tr,
              style: context.typography.mdBold.copyWith(
                fontSize: 17,
                color: const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'checkin_empty_subtitle'.tr,
              textAlign: TextAlign.center,
              style: context.typography.smRegular.copyWith(fontSize: 14, color: const Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}
