import '../../../../../index/index_main.dart';

class PickupEmpty extends StatelessWidget {
  final VoidCallback onAdd;
  const PickupEmpty({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 80.w, height: 80.h, decoration: BoxDecoration(color: const Color(0xFFF59E0B).withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(Icons.people_outlined, size: 40.sp, color: const Color(0xFFF59E0B))),
            SizedBox(height: 20.h),
            Text('pickup_empty_title'.tr, style: context.typography.mdBold.copyWith(fontSize: 18, color: const Color(0xFF1E293B))),
            SizedBox(height: 8.h),
            Text('pickup_empty_subtitle'.tr, textAlign: TextAlign.center, style: context.typography.smRegular.copyWith(fontSize: 14, color: const Color(0xFF64748B))),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text('pickup_add_fab'.tr),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)), padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h)),
            ),
          ],
        ),
      ),
    );
  }
}
