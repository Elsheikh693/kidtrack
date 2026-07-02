import '../../../../../index/index_main.dart';

class InvoiceFilterBar extends StatelessWidget {
  final InvoiceController controller;
  const InvoiceFilterBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    const statuses = ['pending', 'paid', 'overdue', 'cancelled'];
    return SizedBox(
      height: 48.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: statuses.length,
        itemBuilder: (_, i) {
          final s = statuses[i];
          return Obx(() {
            final active = controller.selectedStatus.value == s;
            return GestureDetector(
              onTap: () => controller.setStatus(s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(left: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: active ? AppColors.primary : const Color(0xFFE2E8F0)),
                ),
                child: Text('invoice_status_$s'.tr, style: context.typography.xsMedium.copyWith(color: active ? Colors.white : const Color(0xFF475569))),
              ),
            );
          });
        },
      ),
    );
  }
}
