import '../../../../../index/index_main.dart';

class WaitingEmpty extends StatelessWidget {
  final VoidCallback onAdd;
  const WaitingEmpty({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 80.w, height: 80.h, decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(Icons.hourglass_empty_rounded, size: 40.sp, color: const Color(0xFF8B5CF6))),
            SizedBox(height: 20.h),
            Text('waiting_empty_title'.tr, style: context.typography.mdBold.copyWith(fontSize: 18, color: const Color(0xFF1E293B))),
            SizedBox(height: 8.h),
            Text('waiting_empty_subtitle'.tr, textAlign: TextAlign.center, style: context.typography.smRegular.copyWith(fontSize: 14, color: const Color(0xFF64748B))),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text('waiting_add_fab'.tr),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)), padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h)),
            ),
          ],
        ),
      ),
    );
  }
}
