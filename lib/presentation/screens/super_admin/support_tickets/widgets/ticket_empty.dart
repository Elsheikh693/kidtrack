import '../../../../../index/index_main.dart';

class TicketEmpty extends StatelessWidget {
  final VoidCallback onAdd;
  const TicketEmpty({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.all(32.w),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 80.w, height: 80.h, decoration: BoxDecoration(color: const Color(0xFFF5F3FF), borderRadius: BorderRadius.circular(20.r)), child: Icon(Icons.support_agent_outlined, size: 40.sp, color: const Color(0xFF7C3AED))),
        SizedBox(height: 20.h),
        Text('ticket_empty_title'.tr, style: context.typography.mdBold.copyWith(fontSize: 17, color: const Color(0xFF1E293B))),
        SizedBox(height: 8.h),
        Text('ticket_empty_subtitle'.tr, textAlign: TextAlign.center, style: context.typography.smRegular.copyWith(fontSize: 14, color: const Color(0xFF64748B))),
      ]),
    ),
  );
}
