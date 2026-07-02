import '../../../../../index/index_main.dart';

class InvoiceEmpty extends StatelessWidget {
  final VoidCallback onAdd;
  const InvoiceEmpty({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.all(32.w),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 80.w, height: 80.h, decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(20.r)), child: Icon(Icons.receipt_long_outlined, size: 40.sp, color: const Color(0xFFF59E0B))),
        SizedBox(height: 20.h),
        Text('invoice_empty_title'.tr, style: context.typography.mdBold.copyWith(color: Color(0xFF1E293B))),
        SizedBox(height: 8.h),
        Text('invoice_empty_subtitle'.tr, textAlign: TextAlign.center, style: context.typography.smRegular.copyWith(color: Color(0xFF64748B))),
      ]),
    ),
  );
}
