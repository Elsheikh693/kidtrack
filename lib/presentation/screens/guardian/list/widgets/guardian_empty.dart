import '../../../../../index/index_main.dart';

class GuardianEmpty extends StatelessWidget {
  const GuardianEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 80.w, height: 80.h, decoration: BoxDecoration(color: const Color(0xFF6366F1).withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(Icons.family_restroom_rounded, size: 40.sp, color: const Color(0xFF6366F1))),
            SizedBox(height: 20.h),
            Text('guardian_empty_title'.tr, style: context.typography.mdBold.copyWith(fontSize: 18, color: const Color(0xFF1E293B))),
            SizedBox(height: 8.h),
            Text('guardian_empty_subtitle'.tr, textAlign: TextAlign.center, style: context.typography.smRegular.copyWith(fontSize: 14, color: const Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }
}
