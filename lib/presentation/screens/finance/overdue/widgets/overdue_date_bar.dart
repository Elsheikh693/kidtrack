import 'package:intl/intl.dart';
import '../../../../../index/index_main.dart';

class OverdueDateBar extends StatelessWidget {
  final OverdueController controller;

  const OverdueDateBar({super.key, required this.controller});

  Future<void> _pickMonth(BuildContext context) async {
    final picked = await showAppDatePicker(
      context,
      initialDate: controller.selectedMonth.value,
      minimumDate: DateTime(DateTime.now().year - 2),
      maximumDate: DateTime(DateTime.now().year + 2, 12, 31),
    );
    if (picked != null) controller.setMonth(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
      child: Row(
        children: [
          // ── Month dropdown ──────────────────────────────────────────────────
          Expanded(
            child: GestureDetector(
              onTap: () => _pickMonth(context),
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_rounded,
                        size: 18.sp, color: AppColors.primary),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Obx(
                        () => Text(
                          DateFormat(
                            'MMMM yyyy',
                            Get.locale?.languageCode == 'ar' ? 'ar' : 'en',
                          ).format(controller.selectedMonth.value),
                          style: context.typography.smMedium
                              .copyWith(color: const Color(0xFF1E293B)),
                        ),
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down_rounded,
                        size: 20.sp, color: const Color(0xFF94A3B8)),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          // ── Manage menu ─────────────────────────────────────────────────────
          _ManageMenu(controller: controller),
        ],
      ),
    );
  }
}

class _ManageMenu extends StatelessWidget {
  final OverdueController controller;

  const _ManageMenu({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: PopupMenuButton<int>(
        icon: const Icon(Icons.tune_rounded, color: Color(0xFF475569)),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        onSelected: (v) {
          switch (v) {
            case 0:
              controller.goInvoices();
              break;
            case 1:
              controller.goPayments();
              break;
            case 2:
              controller.goCategories();
              break;
          }
        },
        itemBuilder: (_) => [
          _item(context, 0, Icons.receipt_long_rounded,
              'overdue_manage_invoices'.tr),
          _item(context, 1, Icons.payments_rounded,
              'overdue_manage_payments'.tr),
          _item(context, 2, Icons.category_rounded,
              'overdue_manage_categories'.tr),
        ],
      ),
    );
  }

  PopupMenuItem<int> _item(
      BuildContext context, int value, IconData icon, String label) {
    return PopupMenuItem<int>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: const Color(0xFF475569)),
          SizedBox(width: 10.w),
          Text(label, style: context.typography.smRegular),
        ],
      ),
    );
  }
}
