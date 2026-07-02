import '../../../../../index/index_main.dart';

class AuditEmpty extends StatelessWidget {
  const AuditEmpty({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.all(32.w),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 80.w, height: 80.h, decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(20.r)), child: Icon(Icons.history_outlined, size: 40.sp, color: const Color(0xFF94A3B8))),
        SizedBox(height: 20.h),
        Text('audit_empty_title'.tr, style: context.typography.mdBold.copyWith(fontSize: 17, color: const Color(0xFF1E293B))),
        SizedBox(height: 8.h),
        Text('audit_empty_subtitle'.tr, textAlign: TextAlign.center, style: context.typography.smRegular.copyWith(fontSize: 14, color: const Color(0xFF64748B))),
      ]),
    ),
  );
}
